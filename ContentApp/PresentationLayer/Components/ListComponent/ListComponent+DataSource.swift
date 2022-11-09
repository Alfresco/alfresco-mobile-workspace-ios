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

let regularCellHeight: CGFloat = 54.0
let sectionCellHeight: CGFloat = 54.0
let compactCellHeight: CGFloat = 44.0

protocol ListComponentDataSourceDelegate: AnyObject {
    func shouldDisplayListLoadingIndicator() -> Bool
    func isPaginationEnabled() -> Bool
}

struct ListComponentDataSourceConfiguration {
    let collectionView: UICollectionView
    let viewModel: ListComponentViewModel
    weak var cellDelegate: ListElementCollectionViewCellDelegate?
    let services: CoordinatorServices
}

class ListComponentDataSource: DataSource {
    var configuration: ListComponentDataSourceConfiguration
    weak var delegate: ListComponentDataSourceDelegate?
    
    init(with configuration: ListComponentDataSourceConfiguration,
         delegate: ListComponentDataSourceDelegate) {
        self.configuration = configuration
        self.delegate = delegate
        super.init(collectionView: configuration.collectionView)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return configuration.viewModel.model.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        let shouldDisplayListLoadingIndicator = delegate?.shouldDisplayListLoadingIndicator() ?? false

        if shouldDisplayListLoadingIndicator &&
            configuration.services.connectivityService?.hasInternetConnection() == true {
            return CGSize(width: collectionView.bounds.width,
                          height: regularCellHeight)
        }

        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
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
        let identifierElement = String(describing: ListElementCollectionViewCell.self)
        let identifierSection = String(describing: ListSectionCollectionViewCell.self)

        let node = configuration.viewModel.model.listNode(for: indexPath)
        if node?.guid == listNodeSectionIdentifier {
            guard let cell = collectionView
                    .dequeueReusableCell(withReuseIdentifier: identifierSection,
                                         for: indexPath) as? ListSectionCollectionViewCell else { return UICollectionViewCell() }
            let title = configuration.viewModel.model.titleForSectionHeader(at: indexPath)
            cell.titleLabel.text = title
            cell.addLocalization(value: title)
            cell.applyTheme(configuration.services.themingService?.activeTheme)
            return cell
        } else {
            guard let cell = collectionView
                    .dequeueReusableCell(withReuseIdentifier: identifierElement,
                                         for: indexPath) as? ListElementCollectionViewCell else { return UICollectionViewCell() }
            let isMoveFiles = appDelegate()?.isMoveFilesAndFolderFlow ?? false
            cell.node = node
            cell.delegate = configuration.cellDelegate
            cell.applyTheme(configuration.services.themingService?.activeTheme)
            cell.syncStatus = configuration.viewModel.model.syncStatusForNode(at: indexPath)
            cell.moreButton.isHidden = !configuration.viewModel.shouldDisplayMoreButton(for: indexPath)

            if node?.nodeType == .fileLink || node?.nodeType == .folderLink {
                cell.moreButton.isHidden = true
            }
            if configuration.viewModel.shouldDisplaySubtitle(for: indexPath) == false {
                cell.subtitle.text = ""
            }

            if isMoveFiles {
                cell.moreButton.isEnabled = false
                cell.disableFilesToMove(configuration.services.themingService?.activeTheme, node: node)
            }
            
            let isPaginationEnabled = delegate?.isPaginationEnabled() ?? true
            if isPaginationEnabled &&
                collectionView.lastItemIndexPath() == indexPath &&
                configuration.services.connectivityService?.hasInternetConnection() == true {
                if let collectionView = collectionView as? PageFetchableCollectionView {
                    collectionView.pageDelegate?.fetchNextContentPage(for: collectionView,
                                                                      itemAtIndexPath: indexPath)
                }
            }
            return cell
        }
    }
}
