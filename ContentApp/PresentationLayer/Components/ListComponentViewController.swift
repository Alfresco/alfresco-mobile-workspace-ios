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

protocol ListComponentDataSourceProtocol: class {
    func isEmpty() -> Bool
    func shouldDisplaySections() -> Bool
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func listNode(for indexPath: IndexPath) -> ListNode
    func titleForSectionHeader(at indexPath: IndexPath) -> String
    func shouldDisplayListLoadingIndicator() -> Bool
    func shouldDisplayMoreButton() -> Bool
    func refreshList()
}

protocol ListComponentActionDelegate: class {
    func elementTapped(node: ListNode)
    func didUpdateList(error: Error?, pagination: Pagination?)
    func fetchNextListPage(for itemAtIndexPath: IndexPath)
}

protocol ListComponentPageUpdatingDelegate: class {
    func didUpdateList(error: Error?,
                       pagination: Pagination?,
                       bypassScrolling: Bool)
}

class ListComponentViewController: SystemThemableViewController {
    @IBOutlet weak var collectionView: PageFetchableCollectionView!
    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListTitle: UILabel!
    @IBOutlet weak var emptyListSubtitle: UILabel!
    @IBOutlet weak var emptyListImageView: UIImageView!
    @IBOutlet weak var progressView: MDCProgressView!
    var refreshControl: UIRefreshControl?

    var listDataSource: ListComponentDataSourceProtocol?
    weak var listActionDelegate: ListComponentActionDelegate?
    weak var listItemActionDelegate: ListItemActionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure collectionview data source and delegate
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.pageDelegate = self

        emptyListView.isHidden = true

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

        addLocalization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        collectionView.reloadData()
        progressView.progressTintColor = themingService?.activeTheme?.primaryColor
        progressView.trackTintColor = themingService?.activeTheme?.primaryColor.withAlphaComponent(0.4)
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
        progressView.progressTintColor = themingService?.activeTheme?.primaryColor
        progressView.trackTintColor = themingService?.activeTheme?.primaryColor.withAlphaComponent(0.4)
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()

        guard let currentTheme = self.themingService?.activeTheme else { return }
        emptyListSubtitle.applyeStyleHeadline5OnSurface(theme: currentTheme)
        emptyListSubtitle.applyStyleSubtitle1OnSurface(theme: currentTheme)
        refreshControl?.tintColor = currentTheme.primaryColor
    }

    func addLocalization() {
        emptyListTitle.text = LocalizationConstants.Search.title
        emptyListSubtitle.text = LocalizationConstants.Search.subtitle
    }

    // MARK: - Public interface

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
                pointToScroll = CGPoint(x: 0, y: attributes.frame.origin.y - collectionView.contentInset.top)
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

extension ListComponentViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

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
            headerView.applyTheme(themingService?.activeTheme)
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
        cell?.applyTheme(themingService?.activeTheme)
        cell?.moreButton.isHidden = !(listDataSource?.shouldDisplayMoreButton() ?? false)
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let node = listDataSource?.listNode(for: indexPath) else { return }
        listItemActionDelegate?.showPreview(from: node)
        listActionDelegate?.elementTapped(node: node)
    }
}

// MARK: - ActionMenuViewModel Delegate

extension ListComponentViewController: NodeActionsViewModelDelegate {
    func nodeActionFinished(with action: ActionMenu?, node: ListNode, error: Error?) {
        var snackBarMessage: String?
        var snackBarType: SnackBarType?
        if error != nil {
            snackBarMessage = LocalizationConstants.Errors.errorUnknown
            snackBarType = .error
        } else {
            guard let action = action else { return }
            switch action.type {
            case .addFavorite:
                snackBarMessage = LocalizationConstants.Approved.removedFavorites
                snackBarType = .approve
            case .removeFavorite:
                snackBarMessage = LocalizationConstants.Approved.addedFavorites
                snackBarType = .approve
            case .moveTrash:
                snackBarMessage = String(format: LocalizationConstants.Approved.movedTrash, node.title)
                snackBarType = .approve
            default: break
            }
        }
        if let message = snackBarMessage, let type = snackBarType {
            let snackBar = Snackbar.init(with: message,
                                         type: type,
                                         automaticallyDismisses: true)
            snackBar.snackBar.presentationHostViewOverride = view
            snackBar.show(completion: nil)
        }
    }
}

// MARK: - ListElementCollectionViewCell Delegate

extension ListComponentViewController: ListElementCollectionViewCellDelegate {
    func moreButtonTapped(for element: ListNode?) {
        if let node = element {
            listItemActionDelegate?.showActionSheetForListItem(node: node, delegate: self)
        }
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
                       pagination: Pagination?,
                       bypassScrolling: Bool) {
        guard let isDataSourceEmpty = listDataSource?.isEmpty() else { return }

        emptyListView.isHidden = !isDataSourceEmpty

        // If loading the first page or missing pagination scroll to top
        let scrollToTop = (pagination?.skipCount == 0 || pagination == nil)
            && error == nil
            && !isDataSourceEmpty
            && !bypassScrolling

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
