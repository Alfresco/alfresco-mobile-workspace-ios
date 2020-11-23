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
    func showPreview(from node: ListNode)
    func showActionSheetForListItem(for node: ListNode,
                                    delegate: NodeActionsViewModelDelegate)
    func showActionSheetForCreateFAB(delegate: NodeActionsViewModelDelegate)
    func showCreateNodeDialog(with actionMenu: ActionMenu, delegate: CreateNodeViewModelDelegate?)
}

protocol ListComponentActionDelegate: class {
    func elementTapped(node: ListNode)
    func didUpdateList(error: Error?, pagination: Pagination?)
    func fetchNextListPage(for itemAtIndexPath: IndexPath)
}

protocol ListComponentPageUpdatingDelegate: class {
    func didUpdateList(error: Error?,
                       pagination: Pagination?)
}

class ListComponentViewController: SystemThemableViewController {
    @IBOutlet weak var collectionView: PageFetchableCollectionView!
    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListTitle: UILabel!
    @IBOutlet weak var emptyListSubtitle: UILabel!
    @IBOutlet weak var emptyListImageView: UIImageView!
    @IBOutlet weak var progressView: MDCProgressView!
    @IBOutlet weak var createButton: MDCFloatingButton!

    var refreshControl: UIRefreshControl?

    var listDataSource: ListComponentDataSourceProtocol?
    weak var listActionDelegate: ListComponentActionDelegate?
    weak var listItemActionDelegate: ListItemActionDelegate?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure collectionview data source and delegate
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.pageDelegate = self

        emptyListView.isHidden = true
        createButton.isHidden = !(listDataSource?.shouldDisplayCreateButton() ?? false)

        if listDataSource?.shouldDisplayCreateButton() == true {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0,
                                                       bottom: listBottomInset, right: 0)
        }

        // Set up progress view
        progressView.progress = 0
        progressView.mode = .indeterminate

        // Set up pull to refresh control
        let refreshControl = UIRefreshControl()//RefreshIndicatorView(theme: themingService?.activeTheme)
        collectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh),
                                 for: .valueChanged)
        self.refreshControl = refreshControl

        // Register collection view footer and cell
        collectionView.register(ActivityIndicatorFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: kCVLoadingIndicatorReuseIdentifier)
        let identifier = String(describing: ListElementCollectionViewCell.self)
        collectionView?.register(UINib(nibName: identifier,
                                       bundle: nil),
                                 forCellWithReuseIdentifier: identifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        collectionView.reloadData()
        progressView.progressTintColor = coordinatorServices?.themingService?.activeTheme?.primaryColor
        progressView.trackTintColor =
            coordinatorServices?.themingService?.activeTheme?.primaryColor.withAlphaComponent(0.4)
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
        progressView.progressTintColor = coordinatorServices?.themingService?.activeTheme?.primaryColor
        progressView.trackTintColor =
            coordinatorServices?.themingService?.activeTheme?.primaryColor.withAlphaComponent(0.4)
    }

    // MARK: - IBActions

    @IBAction func createButtonTapped(_ sender: MDCFloatingButton) {
        listItemActionDelegate?.showActionSheetForCreateFAB(delegate: self)
    }

    // MARK: - Public interface

    override func applyComponentsThemes() {
        super.applyComponentsThemes()

        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        emptyListTitle.applyeStyleHeadline6OnSurface(theme: currentTheme)
        emptyListSubtitle.applyStyleBody2OnSurface60(theme: currentTheme)
        emptyListSubtitle.textAlignment = .center

        createButton.backgroundColor = currentTheme.primaryColor
        createButton.tintColor = currentTheme.onPrimaryColor
        refreshControl?.tintColor = currentTheme.primaryColor
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
}

// MARK: - UICollectionView DataSource & Delegate

extension ListComponentViewController: UICollectionViewDelegateFlowLayout,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard listDataSource?.shouldDisplayCreateButton() == true else { return }
        let position = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        createButton.isHidden = !(position.y > 0 )
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {

        if listDataSource?.shouldDisplaySections() ?? false {
            return CGSize(width: self.view.bounds.width, height: listSectionCellHeight)
        } else {
            return CGSize(width: self.view.bounds.width, height: 0)
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return listDataSource?.numberOfSections() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return listDataSource?.numberOfItems(in: section) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let node = listDataSource?.listNode(for: indexPath)
        else { return CGSize(width: view.safeAreaLayoutGuide.layoutFrame.width,
                             height: listItemNodeCellHeight) }
        return CGSize(width: view.safeAreaLayoutGuide.layoutFrame.width,
                      height: (node.kind == .site) ? listSiteCellHeight : listItemNodeCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let dataSource = listDataSource else { return CGSize(width: 0, height: 0) }

        if dataSource.numberOfSections() - 1 == section {
            if listDataSource?.shouldDisplayListLoadingIndicator() ?? false {
                return CGSize(width: self.view.bounds.width, height: listItemNodeCellHeight)
            }
        }
        return CGSize(width: 0, height: 0)
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let identifier = String(describing: ListSectionCollectionReusableView.self)
            guard let headerView =
                    collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                    withReuseIdentifier: identifier,
                                                                    for: indexPath) as? ListSectionCollectionReusableView else {
                fatalError("Invalid ListSectionCollectionReusableView type") }
            headerView.titleLabel.text = listDataSource?.titleForSectionHeader(at: indexPath)
            headerView.applyTheme(coordinatorServices?.themingService?.activeTheme)
            return headerView

        case UICollectionView.elementKindSectionFooter:
            let footerView =
                collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                withReuseIdentifier: kCVLoadingIndicatorReuseIdentifier,
                                                                for: indexPath)
            return footerView

        default:
            assert(false, "Unexpected element kind")
        }

        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let node = listDataSource?.listNode(for: indexPath) else { return UICollectionViewCell() }

        let identifier = String(describing: ListElementCollectionViewCell.self)
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                               for: indexPath) as? ListElementCollectionViewCell
        cell?.element = node
        cell?.delegate = self
        cell?.applyTheme(coordinatorServices?.themingService?.activeTheme)
        cell?.moreButton.isHidden = !(listDataSource?.shouldDisplayMoreButton() ?? false)
        if listDataSource?.shouldDisplayNodePath() == false {
            cell?.subtitle.text = ""
        }
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let node = listDataSource?.listNode(for: indexPath) else { return }
        if node.trashed == false {
            listItemActionDelegate?.showPreview(from: node)
            listActionDelegate?.elementTapped(node: node)
        } else {
            listItemActionDelegate?.showActionSheetForListItem(for: node, delegate: self)
        }
    }
}

// MARK: - CreateNodeViewModel and ActionMenuViewModel Delegates

extension ListComponentViewController: NodeActionsViewModelDelegate, CreateNodeViewModelDelegate {

    func createNode(node: ListNode?, error: Error?) {
        if let error = error {
            self.display(error: error)
        } else {
            displaySnackbar(with: String(format: LocalizationConstants.Approved.created,
                                         node?.truncateTailTitle() ?? ""),
                            type: .approve)
        }
    }

    func nodeActionFinished(with action: ActionMenu?, node: ListNode?, error: Error?) {

        if let error = error {
            self.display(error: error)
        } else {
            var snackBarMessage: String?
            guard let action = action else { return }
            switch action.type {
            case .addFavorite:
                snackBarMessage = LocalizationConstants.Approved.removedFavorites
            case .removeFavorite:
                snackBarMessage = LocalizationConstants.Approved.addedFavorites
            case .moveTrash:
                snackBarMessage = String(format: LocalizationConstants.Approved.movedTrash,
                                         node?.truncateTailTitle() ?? "")
            case .restore:
                snackBarMessage = String(format: LocalizationConstants.Approved.restored,
                                         node?.truncateTailTitle() ?? "")
            case .permanentlyDelete:
                snackBarMessage = String(format: LocalizationConstants.Approved.deleted,
                                         node?.truncateTailTitle() ?? "")
            case .createMSWord, .createMSExcel, .createMSPowerPoint:
                listItemActionDelegate?.showCreateNodeDialog(with: action, delegate: self)
            default: break
            }
            displaySnackbar(with: snackBarMessage, type: .approve)
        }
    }

    func display(error: Error) {
        var snackBarMessage = LocalizationConstants.Errors.errorUnknown
        if error.code == kTimeoutSwaggerErrorCode {
            snackBarMessage = LocalizationConstants.Errors.errorTimeout
        }
        displaySnackbar(with: snackBarMessage, type: .error)
    }

    func displaySnackbar(with message: String?, type: SnackBarType?) {
        if let message = message, let type = type {
            let snackBar = Snackbar(with: message, type: type)
            snackBar.snackBar.presentationHostViewOverride = view
            snackBar.show(completion: nil)
        }
    }
}

// MARK: - ListElementCollectionViewCell Delegate

extension ListComponentViewController: ListElementCollectionViewCellDelegate {
    func moreButtonTapped(for element: ListNode?, in cell: ListElementCollectionViewCell) {
        guard let node = element else { return }
        listItemActionDelegate?.showActionSheetForListItem(for: node, delegate: self)
    }
}

// MARK: - PageFetchableDelegate

extension ListComponentViewController: PageFetchableDelegate {
    func fetchNextContentPage(for collectionView: UICollectionView, itemAtIndexPath: IndexPath) {
        listActionDelegate?.fetchNextListPage(for: itemAtIndexPath)
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

            listActionDelegate?.didUpdateList(error: error, pagination: pagination)
        } else {
            stopLoading()

            if scrollToTop {
                scrollToSection(0)
            }
        }
    }
}

// MARK: - Storyboard Instantiable

extension ListComponentViewController: StoryboardInstantiable {}
