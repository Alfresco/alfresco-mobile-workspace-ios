//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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

private let listItemNodeCellHeight: CGFloat = 64.0
private let listSectionCellHeight: CGFloat = 64.0
private let listSiteCellHeight: CGFloat = 48.0

extension ListComponentViewController: UICollectionViewDelegateFlowLayout,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegate {

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
                      height: (node.nodeType == .site) ? listSiteCellHeight : listItemNodeCellHeight)
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
                                                                withReuseIdentifier: String(describing: ActivityIndicatorFooterView.self),
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
        cell?.node = node
        cell?.delegate = self
        cell?.applyTheme(coordinatorServices?.themingService?.activeTheme)
        cell?.syncStatus = listDataSource?.syncStatus(for: node) ?? .undefined
        cell?.moreButton.isHidden = !(listDataSource?.shouldDisplayMoreButton(node: node) ?? true)

        if node.nodeType == .fileLink || node.nodeType == .folderLink {
            cell?.moreButton.isHidden = true
        }
        if listDataSource?.shouldDisplayNodePath() == false {
            cell?.subtitle.text = ""
        }

        return cell ?? UICollectionViewCell()
    }

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
