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

protocol SearchViewModelProtocol {
    var delegate: SearchViewModelDelegate? { get set }
    var searchChips: [SearchChipItem] { get set }
    var lastSearchedString: String? { get set }

    func defaultSearchChips() -> [SearchChipItem]
    func searchChipTapped(tappedChip: SearchChipItem) -> [Int]
    func performSearch(for string: String?, paginationRequest: RequestPagination?)
    func performLiveSearch(for string: String?)
    func fetchNextSearchResultsPage(for string: String?, index: IndexPath)
    func shouldDisplaySearchBar() -> Bool
    func shouldDisplaySearchButton() -> Bool
}

extension SearchViewModelProtocol {
    func performSearch(for string: String?) {
        performSearch(for: string, paginationRequest: nil)
    }
}

protocol SearchViewModelDelegate: class {
    /**
     Handle search results
     - results: List of search results
     - pagination: Page information for the returned results
     - error: Error object
     - Note: If the list  is empty,  a view with empty list will appear.  If the list is a nil object then recent searches will appear
     */
    func handle(results: [ListNode]?, pagination: Pagination?, error: Error?)
    func handle(results: [ListNode]?)
}

extension SearchViewModelDelegate {
    func handle(results: [ListNode]?) {
        handle(results: results, pagination: nil, error: nil)
    }
}
