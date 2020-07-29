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
import AlfrescoContentServices

protocol ListComponentDataSourceProtocol: class {
    func isEmpty() -> Bool
    func shouldDisplaySections() -> Bool
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func listNode(for indexPath: IndexPath) -> ListNode
    func titleForSectionHeader(at indexPath: IndexPath) -> String
    func shouldDisplayListLoadingIndicator() -> Bool
    func refreshList()
}

protocol ListComponentActionDelegate: class {
    func elementTapped(node: ListNode)
    func didUpdateList(error: Error?, pagination: Pagination?)
}

protocol ListComponentPaginationDelegate: class {
    func didUpdateList(error: Error?, pagination: Pagination?)
}

class ListComponentViewController: SystemThemableViewController {
    @IBOutlet weak var collectionView: PageFetchableCollectionView!
    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListTitle: UILabel!
    @IBOutlet weak var emptyListSubtitle: UILabel!
    @IBOutlet weak var emptyListImageView: UIImageView!
    var activityIndicator: ActivityIndicatorView?
    var refreshControl: UIRefreshControl?

    var listDataSource: ListComponentDataSourceProtocol?
    weak var listActionDelegate: ListComponentActionDelegate?
    weak var folderDrillDownScreenCoordinatorDelegate: FolderDrilDownScreenCoordinatorDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let activityIndicatorView = ActivityIndicatorView(currentTheme: themingService?.activeTheme,
                                                          configuration: ActivityIndicatorConfiguration(title: "" ,
                                                                                                        radius: 12,
                                                                                                        strokeWidth: 2,
                                                                                                        cycleColors: [themingService?.activeTheme?.primaryVariantColor ?? .black]))
        let refreshIndicatorView = ActivityIndicatorView(currentTheme: themingService?.activeTheme,
                                                         configuration: ActivityIndicatorConfiguration(title: "" ,
                                                                                                       radius: 12,
                                                                                                       strokeWidth: 2,
                                                                                                       cycleColors: [themingService?.activeTheme?.primaryVariantColor ?? .black]))

        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.isHidden = true
        activityIndicator = activityIndicatorView

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .clear
        refreshIndicatorView.center = refreshControl.center
        refreshControl.addSubview(refreshIndicatorView)
        collectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        self.refreshControl = refreshControl

        emptyListView.isHidden = true

        collectionView.register(ActivityIndicatorFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: kCVLoadingIndicatorReuseIdentifier)
        let identifier = String(describing: ListElementCollectionViewCell.self)
        collectionView?.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
    }

    // MARK: - Public interface

    func startLoading() {
        activityIndicator?.state = .isLoading
        collectionView.isUserInteractionEnabled = false
        collectionView.setContentOffset(collectionView.contentOffset, animated: false)
    }

    func stopLoading() {
        activityIndicator?.state = .isIdle
        collectionView.isUserInteractionEnabled = true
    }

    func scrollToSection(_ section: Int) {
        let indexPath = IndexPath(item: 0, section: section)
        if let attributes = collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
            let topOfHeader = CGPoint(x: 0, y: attributes.frame.origin.y - collectionView.contentInset.top)
            collectionView.setContentOffset(topOfHeader, animated: true)
        }
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        if listDataSource?.shouldDisplaySections() ?? false {
            return CGSize(width: self.view.bounds.width, height: listSectionCellHeight)
        } else {
            return CGSize(width: self.view.bounds.width, height: 0)
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return listDataSource?.numberOfSections() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listDataSource?.numberOfItems(in: section) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let node = listDataSource?.listNode(for: indexPath)
            else { return CGSize(width: self.view.bounds.width, height: listItemNodeCellHeight) }
        return CGSize(width: self.view.bounds.width, height: (node.kind == .site) ? listSiteCellHeight : listItemNodeCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {

        if listDataSource?.shouldDisplayListLoadingIndicator() ?? false {
            return CGSize(width: self.view.bounds.width, height: listItemNodeCellHeight)
        }

        return CGSize(width: 0, height: 0)
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let identifier = String(describing: ListSectionCollectionReusableView.self)
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: identifier,
                                                                                   for: indexPath) as? ListSectionCollectionReusableView else {
                                                                                    fatalError("Invalid ListSectionCollectionReusableView type") }
            headerView.titleLabel.text = listDataSource?.titleForSectionHeader(at: indexPath)
            headerView.applyTheme(themingService?.activeTheme)
            return headerView

        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: kCVLoadingIndicatorReuseIdentifier,
                                                                             for: indexPath)
            return footerView

        default:
            assert(false, "Unexpected element kind")
        }

        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let node = listDataSource?.listNode(for: indexPath) else { return UICollectionViewCell() }

        let identifier = String(describing: ListElementCollectionViewCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ListElementCollectionViewCell
        cell?.element = node
        cell?.applyTheme(themingService?.activeTheme)
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let node = listDataSource?.listNode(for: indexPath) else { return }
        if node.kind == .folder || node.kind == .site {
            folderDrillDownScreenCoordinatorDelegate?.showScreen(from: node)
        }
        listActionDelegate?.elementTapped(node: node)
    }
}

// MARK: - PageFetchableDelegate

extension ListComponentViewController: PageFetchableDelegate {
    func fetchNextContentPage(for collectionView: UICollectionView, itemAtIndex: IndexPath) {

    }
}

extension ListComponentViewController: ListComponentPaginationDelegate {
    func didUpdateList(error: Error?, pagination: Pagination?) {
        guard let isDataSourceEmpty = listDataSource?.isEmpty() else { return }

        emptyListView.isHidden = !isDataSourceEmpty
        collectionView.isHidden = isDataSourceEmpty

        if error == nil {
            collectionView.reloadData()
            collectionView.performBatchUpdates(nil, completion: { [weak self] _ in
                guard let sSelf = self else { return }
                sSelf.stopLoading()
            })

            listActionDelegate?.didUpdateList(error: error, pagination: pagination)
        }

        // If loading the first page or missing pagination scroll to top
        if (pagination?.skipCount == 0 || pagination == nil) && error == nil && !isDataSourceEmpty {
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
}

extension ListComponentViewController: StoryboardInstantiable {}
