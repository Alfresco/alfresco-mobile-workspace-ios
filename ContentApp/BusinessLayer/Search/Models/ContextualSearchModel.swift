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

    override func defaultSearchChips(for configurations: [AdvanceSearchFilters], and index: Int) -> [SearchChipItem] {
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
            searchChips = createChipsForAdvanceSearch(for: configurations, and: index)
            return searchChips
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
    func createChipsForAdvanceSearch(for configurations: [AdvanceSearchFilters], and index: Int) -> [SearchChipItem] {
        if index < 0 {
            return []
        } else {
            var chipsArray = [SearchChipItem]()
            if let searchChipNode = self.searchChipNode {
                searchChipNode.selected = true
                chipsArray.append(searchChipNode)
            }
            
            let advanceSearchChips = self.getChipsForAdvanceSearch(for: configurations, and: index)
            chipsArray.append(contentsOf: advanceSearchChips)
            return chipsArray
        }
    }
}
