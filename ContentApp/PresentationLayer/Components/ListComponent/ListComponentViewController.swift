//
// Copyright (C) 2005-2020 Alfresco Software Limited.
//
// This file is part of the Alfresco Content Mobile iOS App.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import AlfrescoContent
import MaterialComponents.MaterialActivityIndicator
import MaterialComponents.MaterialProgressView

protocol ListItemActionDelegate: class {
    func showPreview(for node: ListNode,
                     from dataSource: ListComponentDataSourceProtocol)
    func showActionSheetForListItem(for node: ListNode,
                                    from dataSource: ListComponentDataSourceProtocol,
                                    delegate: NodeActionsViewModelDelegate)
    func showNodeCreationSheet(delegate: NodeActionsViewModelDelegate)
    func showNodeCreationDialog(with actionMenu: ActionMenu,
                                delegate: CreateNodeViewModelDelegate?)
}

protocol ListComponentActionDelegate: class {
    func elementTapped(node: ListNode)
    func didUpdateList(in listComponentViewController: ListComponentViewController,
                       error: Error?,
                       pagination: Pagination?)
    func fetchNextListPage(in listComponentViewController: ListComponentViewController,
                           for itemAtIndexPath: IndexPath)
    func performListAction()
}

protocol ListComponentPageUpdatingDelegate: class {
    func didUpdateList(error: Error?,
                       pagination: Pagination?)
    func shouldDisplayCreateButton(enable: Bool)
    func didUpdateListActionState(enable: Bool)
}

class ListComponentViewController: SystemThemableViewController {
    @IBOutlet weak var collectionView: PageFetchableCollectionView!
    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListTitle: UILabel!
    @IBOutlet weak var emptyListSubtitle: UILabel!
    @IBOutlet weak var emptyListImageView: UIImageView!
    @IBOutlet weak var progressView: MDCProgressView!
    @IBOutlet weak var createButton: MDCFloatingButton!
    @IBOutlet weak var listActionButton: MDCFloatingButton!
    var refreshControl: UIRefreshControl?

    var listDataSource: ListComponentDataSourceProtocol?

    weak var listActionDelegate: ListComponentActionDelegate?
    weak var listItemActionDelegate: ListItemActionDelegate?

    var isPaginationEnabled: Bool = true

    private var kvoConnectivity: NSKeyValueObservation?
    private let listBottomInset: CGFloat = 70.0

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure collectionview data source and delegate
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.pageDelegate = self
        collectionView.isPaginationEnabled = isPaginationEnabled

        emptyListView.isHidden = true
        createButton.isHidden = !(listDataSource?.shouldDisplayCreateButton() ?? false)
        listActionButton.isHidden = !(listDataSource?.shouldDisplayListActionButton() ?? false)
        listActionButton.mode = .expanded
        listActionButton.isUppercaseTitle = false
        listActionButton.setTitle(listDataSource?.listActionTitle(), for: .normal)

        if listDataSource?.shouldDisplayCreateButton() == true ||
            listDataSource?.shouldDisplayListActionButton() == true {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0,
                                                       bottom: listBottomInset, right: 0)
        }

        // Set up progress view
        progressView.progress = 0
        progressView.mode = .indeterminate

        // Set up pull to refresh control
        let refreshControl = UIRefreshControl()// RefreshIndicatorView(theme: themingService?.activeTheme)
        collectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh),
                                 for: .valueChanged)
        self.refreshControl = refreshControl

        // Register collection view footer and cell
        collectionView.register(ActivityIndicatorFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: String(describing: ActivityIndicatorFooterView.self))
        let identifier = String(describing: ListElementCollectionViewCell.self)
        collectionView?.register(UINib(nibName: identifier,
                                       bundle: nil),
                                 forCellWithReuseIdentifier: identifier)

        // ReSignIn Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleReSignIn(notification:)),
                                               name: Notification.Name(KeyConstants.Notification.reSignin),
                                               object: nil)

        observeConnectivity()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        listActionButton.isEnabled = (listDataSource?.shouldEnableListActionButton() ?? false)
        handleConnectivity()

        if coordinatorServices?.syncService?.syncServiceStatus != .idle {
            listActionButton.isEnabled = false
        }

        collectionView.reloadData()

        let activeTheme = coordinatorServices?.themingService?.activeTheme
        progressView.progressTintColor = activeTheme?.primaryT1Color
        progressView.trackTintColor = activeTheme?.primary30T1Color
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
        progressView.progressTintColor = coordinatorServices?.themingService?.activeTheme?.primaryT1Color
        progressView.trackTintColor =
            coordinatorServices?.themingService?.activeTheme?.primary30T1Color
    }

    // MARK: - Actions

    @IBAction func createButtonTapped(_ sender: MDCFloatingButton) {
        listItemActionDelegate?.showNodeCreationSheet(delegate: self)
    }

    @IBAction func listActionButtonTapped(_ sender: MDCFloatingButton) {
        listActionDelegate?.performListAction()
    }

    // MARK: - Public interface

    override func applyComponentsThemes() {
        super.applyComponentsThemes()

        guard let currentTheme = coordinatorServices?.themingService?.activeTheme
              else { return }
        emptyListTitle.applyeStyleHeadline6OnSurface(theme: currentTheme)
        emptyListTitle.textAlignment = .center
        emptyListSubtitle.applyStyleBody2OnSurface60(theme: currentTheme)
        emptyListSubtitle.textAlignment = .center

        createButton.backgroundColor = currentTheme.primaryT1Color
        createButton.tintColor = currentTheme.onPrimaryColor

        listActionButton.backgroundColor = currentTheme.primaryT1Color
        listActionButton.tintColor = currentTheme.onPrimaryColor

        refreshControl?.tintColor = currentTheme.primaryT1Color
    }

    func startLoading() {
        progressView.startAnimating()
        progressView.setHidden(false, animated: true)
    }

    func stopLoading() {
        progressView.stopAnimating()
        progressView.setHidden(true, animated: false)
        refreshControl?.endRefreshing()
    }

    func scrollToSection(_ section: Int) {
        let indexPath = IndexPath(item: 0, section: section)
        var pointToScroll = CGPoint.zero
        if collectionView.cellForItem(at: indexPath) != nil {
            if let attributes =
                collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader,
                                                                       at: indexPath) {
                pointToScroll =
                    CGPoint(x: 0, y: attributes.frame.origin.y - collectionView.contentInset.top)
            }
        }
        collectionView.setContentOffset(pointToScroll, animated: true)
    }

    // MARK: - Private Interface

    @objc private func handlePullToRefresh() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }

            sSelf.listDataSource?.refreshList()
        }
    }

    @objc private func handleReSignIn(notification: Notification) {
        listDataSource?.refreshList()
    }

    // MARK: Connectivity Helpers

    private func observeConnectivity() {
        let connectivityService = coordinatorServices?.connectivityService
        kvoConnectivity = connectivityService?.observe(\.status,
                                                       options: [.new],
                                                       changeHandler: { [weak self] (_, _) in
                                                        guard let sSelf = self else { return }
                                                        sSelf.handleConnectivity()
                                                       })
    }

    private func handleConnectivity() {
        let connectivityService = coordinatorServices?.connectivityService
        if connectivityService?.hasInternetConnection() == false {
            didUpdateList(error: NSError(), pagination: nil)
        }
        listActionButton.isEnabled = connectivityService?.hasInternetConnection() ?? false
    }
}

// MARK: - UICollectionViewDelegate

extension ListComponentViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dataSource = listDataSource else { return }
        let node = dataSource.listNode(for: indexPath)
        if dataSource.shouldPreview(node: node) == false { return }
        if node.trashed == false,
           let dataSource = listDataSource {
            listItemActionDelegate?.showPreview(for: node,
                                                from: dataSource)
            listActionDelegate?.elementTapped(node: node)
        } else {
            listItemActionDelegate?.showActionSheetForListItem(for: node,
                                                               from: dataSource,
                                                               delegate: self)
        }
    }
}

// MARK: - ListElementCollectionViewCell Delegate

extension ListComponentViewController: ListElementCollectionViewCellDelegate {
    func moreButtonTapped(for element: ListNode?, in cell: ListElementCollectionViewCell) {
        guard let node = element,
              let dataSource = listDataSource else { return }
        listItemActionDelegate?.showActionSheetForListItem(for: node,
                                                           from: dataSource,
                                                           delegate: self)
    }
}

// MARK: - PageFetchableDelegate

extension ListComponentViewController: PageFetchableDelegate {
    func fetchNextContentPage(for collectionView: UICollectionView, itemAtIndexPath: IndexPath) {
        listActionDelegate?.fetchNextListPage(in: self, for: itemAtIndexPath)
    }
}

// MARK: - ListComponentPageUpdatingDelegate

extension ListComponentViewController: ListComponentPageUpdatingDelegate {
    func didUpdateList(error: Error?,
                       pagination: Pagination?) {
        guard let isDataSourceEmpty = listDataSource?.isEmpty() else { return }

        emptyListView.isHidden = !isDataSourceEmpty
        if isDataSourceEmpty {
            let emptyList = listDataSource?.emptyList()
            emptyListImageView.image = emptyList?.icon
            emptyListTitle.text = emptyList?.title
            emptyListSubtitle.text = emptyList?.description
        }

        if listDataSource?.shouldDisplayListActionButton() == true {
            listActionButton.isHidden = isDataSourceEmpty
        }

        // If loading the first page or missing pagination scroll to top
        let scrollToTop = (pagination?.skipCount == 0 || pagination == nil)
            && error == nil
            && !isDataSourceEmpty

        if error == nil {
            collectionView.reloadData()
            collectionView.performBatchUpdates(nil, completion: { [weak self] _ in
                guard let sSelf = self else { return }
                sSelf.stopLoading()

                if scrollToTop {
                    sSelf.scrollToSection(0)
                }
            })

            listActionDelegate?.didUpdateList(in: self, error: error, pagination: pagination)
        } else {
            stopLoading()

            if scrollToTop {
                scrollToSection(0)
            }
        }
    }

    func shouldDisplayCreateButton(enable: Bool) {
        createButton.isHidden = !enable
        if enable {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0,
                                                       bottom: listBottomInset, right: 0)
        }
    }

    func didUpdateListActionState(enable: Bool) {
        listActionButton.isEnabled = enable
    }
}

// MARK: - Storyboard Instantiable

extension ListComponentViewController: StoryboardInstantiable {}
