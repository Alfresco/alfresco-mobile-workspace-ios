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

class GlobalSearchModel: SearchModel {
    
    override func defaultSearchChips(configurations: [AdvanceSearchConfigurations]) -> [SearchChipItem] {
        if configurations.isEmpty {
            searchChips = [ SearchChipItem(name: LocalizationConstants.Search.filterFiles,
                                           type: .file),
                            SearchChipItem(name: LocalizationConstants.Search.filterFolders,
                                           type: .folder),
                            SearchChipItem(name: LocalizationConstants.Search.filterLibraries,
                                           type: .library,
                                           selected: false)]
        } else {
            if defaultConfigurationIndex(for: configurations) < 0 {
                searchChips = []
            } else {
                return createChipsForAdvanceSearch(for: configurations)
            }
        }
        return searchChips
    }
    
    override func searchChipIndexes(for tappedChip: SearchChipItem) -> [Int] {
        var searchChipIndexes: [Int] = []
        if tappedChip.type == .library {
            for chip in searchChips where chip.type != .library && chip.selected {
                chip.selected = false
                searchChipIndexes.append(searchChips.firstIndex(where: { $0 == chip }) ?? 0)
            }
        } else {
            for chip in searchChips where chip.type == .library && chip.selected {
                chip.selected = false
                searchChipIndexes.append(searchChips.firstIndex(where: { $0 == chip }) ?? 0)
            }
        }
        return searchChipIndexes
    }

    override func isNodePathEnabled() -> Bool {
        for chip in searchChips where chip.selected && chip.type == .library {
            return false
        }
        
        return true
    }

    override func handleSearch(for searchString: String,
                               paginationRequest: RequestPagination?,
                               completionHandler: SearchCompletionHandler) {
        if isSearchForLibraries() {
            performLibrariesSearch(searchString: searchString,
                                   paginationRequest: paginationRequest,
                                   completionHandler: completionHandler)
        } else {
            performFileFolderSearch(searchString: searchString,
                                    paginationRequest: paginationRequest,
                                    completionHandler: completionHandler)
        }
    }
}

// MARK: Advance Search
extension GlobalSearchModel {
    func defaultConfigurationIndex(for configurations: [AdvanceSearchConfigurations]) -> Int {
        if let index = configurations.firstIndex(where: {$0.isDefault == true}) {
              return index
        }
        return -1
    }
    
    func createChipsForAdvanceSearch(for configurations: [AdvanceSearchConfigurations]) -> [SearchChipItem] {
        let index = defaultConfigurationIndex(for: configurations)
        let categories = getCategories(for: configurations, and: index)
        var chipsArray = [SearchChipItem]()
        for category in categories {
            let name = category.name ?? ""
            let searchID = category.searchID
            let type = getCategoryCMType(for: searchID)
            let chip = SearchChipItem(name: name,
                                      type: type,
                                      selected: false)
            chipsArray.append(chip)
        }
        
        return chipsArray
    }
    
    func getCategories(for configurations: [AdvanceSearchConfigurations], and index: Int) -> [SearchCategories] {
        if index >= 0 {
            return configurations[index].categories
        }
        return []
    }
    
    func getCategoryCMType(for categoryId: String?) -> CMType {
        switch categoryId {
        case "queryName":
            return .text
        case "checkList":
            return .checkList
        case "contentSize":
            return .contentSize
        case "contentSizeRange":
            return .contentSizeRange
        case "createdDateRange":
            return .createdDateRange
        case "queryType":
            return .radio
        default:
            AlfrescoLog.debug("No Catgeory Found!")
            return .file
        }
    }
}
