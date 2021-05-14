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
import Micro

class ListComponentViewController: SystemThemableViewController {
    @IBOutlet weak var collectionView: PageFetchableCollectionView!
    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListTitle: UILabel!
    @IBOutlet weak var emptyListSubtitle: UILabel!
    @IBOutlet weak var emptyListImageView: UIImageView!
    @IBOutlet weak var progressView: MDCProgressView!
    @IBOutlet weak var createButton: MDCFloatingButton!
    @IBOutlet weak var listActionButton: MDCButton!
    var refreshControl: UIRefreshControl?

    var isPaginationEnabled = true
    var model: ListComponentModelProtocol?
    var dataSource: ListComponentDataSource?

    weak var listActionDelegate: ListComponentActionDelegate?
    weak var listItemActionDelegate: ListItemActionDelegate?

    private var kvoConnectivity: NSKeyValueObservation?
    private let listBottomInset: CGFloat = 70.0

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure collection view data source and delegate
        guard let model = model,
              let services = coordinatorServices else { return }
        let dataSourceConfiguration =
            ListComponentDataSourceConfiguration(collectionView: collectionView,
                                                 model: model,
                                                 isPaginationEnabled: isPaginationEnabled,
                                                 cellDelegate: self,
                                                 services: services)
        let dataSource = ListComponentDataSource(with: dataSourceConfiguration)
        self.dataSource = dataSource

        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        collectionView.pageDelegate = self
        collectionView.isPaginationEnabled = isPaginationEnabled
        collectionView.coordinatorServices = coordinatorServices

        emptyListView.isHidden = true
        createButton.isHidden = !model.shouldDisplayCreateButton()
        listActionButton.isHidden = !model.shouldDisplayListActionButton()
        listActionButton.isUppercaseTitle = false
        listActionButton.setTitle(model.listActionTitle(), for: .normal)
        listActionButton.layer.cornerRadius = listActionButton.frame.height / 2

        if model.shouldDisplayCreateButton() ||
            model.shouldDisplayListActionButton() {
            collectionView.contentInset = UIEdgeInsets(top: 0,
                                                       left: 0,
                                                       bottom: listBottomInset,
                                                       right: 0)
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

        listActionButton.isEnabled = (model?.shouldEnableListActionButton() ?? false)
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
        listActionButton.setTitleFont(currentTheme.subtitle2TextStyle.font, for: .normal)

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

            sSelf.model?.refreshList()
        }
    }

    @objc private func handleReSignIn(notification: Notification) {
        model?.refreshList()
    }

    private func reloadDataSource() {
        if let model = model,
           let dataSource = dataSource {
            let listNodes = model.listNodes()

            dataSource.state = forEach(listNodes) { listNode in
                Cell<ListElementCollectionViewCell>()
                    .onSize { [weak self] context in
                        guard let sSelf = self else { return .zero}
                        return CGSize(width: sSelf.view.safeAreaLayoutGuide.layoutFrame.width,
                                      height: (model.shouldDisplaySubtitle(for: context.indexPath)) ? regularCellHeight : compactCellHeight)
                    }.onSelect { [weak self] context in
                        guard let sSelf = self,
                              let model = sSelf.model,
                              let node = model.listNode(for: context.indexPath) else { return }

                        if model.shouldPreviewNode(at: context.indexPath) == false { return }
                        if node.trashed == false {
                            sSelf.listItemActionDelegate?.showPreview(for: node,
                                                                      from: model)
                            sSelf.listActionDelegate?.elementTapped(node: node)
                        } else {
                            sSelf.listItemActionDelegate?.showActionSheetForListItem(for: node,
                                                                                     from: model,
                                                                                     delegate: sSelf)
                        }
                    }
            }
        }
    }

    // MARK: Connectivity Helpers

    private func observeConnectivity() {
        let connectivityService = coordinatorServices?.connectivityService
        kvoConnectivity = connectivityService?.observe(\.status,
                                                       options: [.new],
                                                       changeHandler: { [weak self] (_, _) in
                                                        guard let sSelf = self else { return }
                                                        sSelf.handleConnectivity()
                                                        sSelf.collectionView.reloadData()
                                                       })
    }

    private func handleConnectivity() {
        let connectivityService = coordinatorServices?.connectivityService
        if connectivityService?.hasInternetConnection() == false {
            didUpdateList(error: NSError(), pagination: nil)

            if model?.shouldDisplayPullToRefreshOffline() == false {
                refreshControl?.removeFromSuperview()
            }
        } else {
            if let refreshControl = self.refreshControl, refreshControl.superview == nil {
                collectionView.addSubview(refreshControl)
            }
        }
        listActionButton.isEnabled = connectivityService?.hasInternetConnection() ?? false
    }
}

// MARK: - ListElementCollectionViewCell Delegate

extension ListComponentViewController: ListElementCollectionViewCellDelegate {
    func moreButtonTapped(for element: ListNode?, in cell: ListElementCollectionViewCell) {
        guard let node = element,
              let model = model else { return }
        listItemActionDelegate?.showActionSheetForListItem(for: node,
                                                           from: model,
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
        guard let isListEmpty = model?.isEmpty() else { return }

        emptyListView.isHidden = !isListEmpty
        if isListEmpty {
            let emptyList = model?.emptyList()
            emptyListImageView.image = emptyList?.icon
            emptyListTitle.text = emptyList?.title
            emptyListSubtitle.text = emptyList?.description
        }

        if model?.shouldDisplayListActionButton() == true {
            listActionButton.isHidden = isListEmpty
        }

        // If loading the first page or missing pagination scroll to top
        let scrollToTop = (pagination?.skipCount == 0 || pagination == nil) &&
            error == nil &&
            !isListEmpty

        let stopLoadingAndScrollToTop = { [weak self] in
            guard let sSelf = self else { return }

            sSelf.stopLoading()
            if scrollToTop {
                sSelf.scrollToSection(0)
            }
        }

        if error == nil {
            reloadDataSource()
            stopLoadingAndScrollToTop()
            listActionDelegate?.didUpdateList(in: self, error: error, pagination: pagination)
        } else {
            stopLoadingAndScrollToTop()
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
