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

import Foundation
import AlfrescoContent

struct SearchRequestBuilder {
    static var repository = ApplicationBootstrap.shared().repository
    static var accountService = repository.service(of: AccountService.identifier) as? AccountService

    static func searchRequest(_ string: String,
                              chipFilters: [SearchChipItem],
                              pagination: RequestPagination?,
                              selectedSearchFilter: AdvanceSearchFilters?) -> SimpleSearchRequest {
        return SimpleSearchRequest(querry: string,
                                   parentId: self.searchInNode(chipFilters),
                                   skipCount: pagination?.skipCount ?? 0,
                                   maxItems: pagination?.maxItems ?? APIConstants.pageSize,
                                   searchInclude: self.chipIncluded(chipFilters),
                                   filterQueries: self.queriesIncluded(chipFilters, selectedSearchFilter: selectedSearchFilter))
    }

    static func recentFilesRequest(pagination: RequestPagination?) -> RecentFilesRequest {
        let identifier = accountService?.activeAccount?.identifier ?? ""
        return RecentFilesRequest(userId: identifier,
                                  days: APIConstants.daysModifiedInterval,
                                  skipCount: pagination?.skipCount ?? 0,
                                  maxItems: pagination?.maxItems ?? APIConstants.pageSize)
    }

    private static func chipIncluded(_ chipFilters: [SearchChipItem]) -> [SearchInclude] {
        var includes = [SearchInclude]()
        for chip in chipFilters where chip.selected {
            switch chip.type {
            case .file:
                includes.append(.files)
            case .folder:
                includes.append(.folders)
            default: break
            }
        }
        return includes
    }

    private static func searchInNode(_ chipFilters: [SearchChipItem]) -> String? {
        for chip in chipFilters where chip.selected && chip.type == .node {
            return chip.searchInNodeID
        }
        return nil
    }
    
    private static func queriesIncluded(_ chipFilters: [SearchChipItem],
                                        selectedSearchFilter: AdvanceSearchFilters?) -> [String] {
        var queries = [String]()
        for chip in chipFilters where !chip.selectedValue.isEmpty && chip.componentType != nil {
            let chipQuery = chip.query ?? ""
            if !chipQuery.isEmpty {
                queries.append(chipQuery)
            }
        }
        
        if let selectedSearchFilter = selectedSearchFilter {
            let filterQueries = selectedSearchFilter.filterQueries
            for item in filterQueries {
                let query = item.query ?? ""
                queries.append(query)
            }
        }
        return queries
    }
}
