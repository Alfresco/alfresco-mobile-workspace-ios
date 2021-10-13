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

import Foundation
import AlfrescoContent

class ContextualSearchModel: SearchModel {
    var searchChipNode: SearchChipItem?

    override func defaultSearchChips(for configurations: [AdvanceSearchConfigurations], and index: Int) -> [SearchChipItem] {
        searchChips = []
        if configurations.isEmpty {
            if let searchChipNode = self.searchChipNode {
                searchChipNode.selected = true
                searchChips.append(searchChipNode)
            }
            searchChips.append(SearchChipItem(name: LocalizationConstants.Search.filterFiles,
                                              type: .file))
            searchChips.append(SearchChipItem(name: LocalizationConstants.Search.filterFolders,
                                              type: .folder))
            return searchChips
        } else {
            return createChipsForAdvanceSearch(for: configurations, and: index)
        }
    }

    override func handleSearch(for searchString: String,
                               paginationRequest: RequestPagination?,
                               completionHandler: SearchCompletionHandler) {
        performFileFolderSearch(searchString: searchString,
                                paginationRequest: paginationRequest,
                                completionHandler: completionHandler)
    }
}

// MARK: Advance Search
extension ContextualSearchModel {
    func createChipsForAdvanceSearch(for configurations: [AdvanceSearchConfigurations], and index: Int) -> [SearchChipItem] {
        if index < 0 {
            return []
        } else {
            let categories = getCategories(for: configurations, and: index)
            var chipsArray = [SearchChipItem]()
            if let searchChipNode = self.searchChipNode {
                searchChipNode.selected = true
                chipsArray.append(searchChipNode)
            }
            
            for category in categories {
                let name = category.name ?? ""
                let selector = category.component?.selector
                let componentType = getComponentType(for: selector)
                let chip = SearchChipItem(name: name,
                                          selected: false,
                                          componentType: componentType)
                chipsArray.append(chip)
            }
            
            return chipsArray
        }
    }
    
    func getCategories(for configurations: [AdvanceSearchConfigurations], and index: Int) -> [SearchCategories] {
        if index >= 0 {
            return configurations[index].categories
        }
        return []
    }
    
    func getComponentType(for selector: String?) -> ComponentType {
        switch selector {
        case "text":
            return .text
        case "check-list":
            return .checkList
        case "slider":
            return .contentSize
        case "number-range":
            return .contentSizeRange
        case "date-range":
            return .createdDateRange
        case "radio":
            return .radio
        default:
            AlfrescoLog.debug("No Catgeory Found!")
            return .none
        }
    }
}
