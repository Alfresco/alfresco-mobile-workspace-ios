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
import Micro

let listItemNodeCellHeight: CGFloat = 54.0
let listSectionCellHeight: CGFloat = 54.0
let listSiteCellHeight: CGFloat = 44.0

struct ListComponentDataSourceConfiguration {
    let collectionView: UICollectionView
    let model: ListComponentModelProtocol
    var isPaginationEnabled = true
    weak var cellDelegate: ListElementCollectionViewCellDelegate?
    let services: CoordinatorServices
}

class ListComponentDataSource: DataSource {
    var configuration: ListComponentDataSourceConfiguration

    init(with configuration: ListComponentDataSourceConfiguration) {
        self.configuration = configuration
        super.init(collectionView: configuration.collectionView)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        if configuration.model.shouldDisplaySections() {
            return CGSize(width: collectionView.bounds.width,
                          height: listSectionCellHeight)
        } else {
            return CGSize(width: collectionView.bounds.width,
                          height: 0)
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return configuration.model.numberOfSections()
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return configuration.model.numberOfItems(in: section)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        if configuration.model.numberOfSections() - 1 == section {
            if configuration.model.shouldDisplayListLoadingIndicator() &&
                configuration.services.connectivityService?.hasInternetConnection() == true {
                return CGSize(width: collectionView.bounds.width,
                              height: listItemNodeCellHeight)
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
            headerView.titleLabel.text = configuration.model.titleForSectionHeader(at: indexPath)
            headerView.applyTheme(configuration.services.themingService?.activeTheme)
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

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let node = configuration.model.listNode(for: indexPath)
        let identifier = String(describing: ListElementCollectionViewCell.self)

        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                               for: indexPath) as? ListElementCollectionViewCell
        cell?.node = node
        cell?.delegate = configuration.cellDelegate
        cell?.applyTheme(configuration.services.themingService?.activeTheme)
        cell?.syncStatus = configuration.model.syncStatus(for: node)
        cell?.moreButton.isHidden = !configuration.model.shouldDisplayMoreButton(node: node)
        
        if node.nodeType == .fileLink || node.nodeType == .folderLink {
            cell?.moreButton.isHidden = true
        }
        if configuration.model.shouldDisplayNodePath() == false {
            cell?.subtitle.text = ""
        }

        if configuration.isPaginationEnabled &&
            collectionView.lastItemIndexPath() == indexPath &&
            configuration.services.connectivityService?.hasInternetConnection() == true {
            if let collectionView = collectionView as? PageFetchableCollectionView {
                collectionView.pageDelegate?.fetchNextContentPage(for: collectionView,
                                                                  itemAtIndexPath: indexPath)
            }
        }

        return cell ?? UICollectionViewCell()
    }
    
}
