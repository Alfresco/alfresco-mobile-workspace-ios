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

class ContextualSearchViewModel: PageFetchingViewModel, SearchViewModelProtocol {
    var resultsList: [ListNode] = []
    var accountService: AccountService?
    var searchChips: [SearchChipItem] = []
    var searchChipNode: SearchChipItem?

    weak var delegate: SearchViewModelDelegate?

    private var liveSearchTimer: Timer?
    private var lastSearchedString: String?

    // MARK: - Init

    init(accountService: AccountService?) {
        super.init()
        self.accountService = accountService
    }

    // MARK: - Public methods

    func shouldDisplaySearchBar() -> Bool {
        return false
    }

    func shouldDisplaySearchButton() -> Bool {
        return true
    }

    func defaultSearchChips() -> [SearchChipItem] {
        searchChips = []
        if let searchChipNode = self.searchChipNode {
            searchChipNode.selected = true
            searchChips.append(searchChipNode)
        }
        searchChips.append(SearchChipItem(name: LocalizationConstants.Search.filterFiles, type: .file))
        searchChips.append(SearchChipItem(name: LocalizationConstants.Search.filterFolders, type: .folder))

        return searchChips
    }

    func logicSearchChips(chipTapped: SearchChipItem) -> [Int] {
        return []
    }

    func performSearch(for string: String?, paginationRequest: RequestPagination?) {
        lastSearchedString = string
        if paginationRequest == nil {
            currentPage = 1
            results = []
        }

        liveSearchTimer?.invalidate()
        guard let searchString = string?.trimmingCharacters(in: .whitespacesAndNewlines), searchString != "" else {
            self.delegate?.handle(results: nil)
            return
        }
        pageFetchingGroup.enter()
        performFileFolderSearch(searchString: searchString, paginationRequest: paginationRequest)
    }

    func performLiveSearch(for string: String?) {
        liveSearchTimer?.invalidate()
        guard let searchString = string, searchString.canPerformLiveSearch() else {
            self.delegate?.handle(results: nil)
            return
        }
        liveSearchTimer = Timer.scheduledTimer(withTimeInterval: kSearchTimerBuffer, repeats: false, block: { [weak self] (timer) in
            timer.invalidate()
            guard let sSelf = self else { return }
            sSelf.performSearch(for: searchString)
        })
    }

    func fetchNextSearchResultsPage(for string: String?, index: IndexPath) {
        fetchNextListPage(index: index, userInfo: string ?? "")
    }

    override func fetchItems(with requestPagination: RequestPagination, userInfo: Any?, completionHandler: @escaping PagedResponseCompletionHandler) {
        if let searchTerm = userInfo as? String {
            self.performSearch(for: searchTerm, paginationRequest: requestPagination)
        }
    }

    override func handlePage(results: [ListNode]?, pagination: Pagination?, error: Error?) {
        self.delegate?.handle(results: results, pagination: pagination, error: error)
    }

    // MARK: Private Methods

    private func performFileFolderSearch(searchString: String, paginationRequest: RequestPagination?) {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self, let accountIdentifier = sSelf.accountService?.activeAccount?.identifier else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            let searchChipsState = sSelf.searchChipsState()
            SearchAPI.search(queryBody: SearchRequestBuilder.searchRequest(searchString, chipFilters: sSelf.searchChips, pagination: paginationRequest, accountIdentifier: accountIdentifier)) { (result, error) in

                if let entries = result?.list?.entries {
                    sSelf.resultsList = ResultsNodeMapper.map(entries)
                }

                let paginatedResponse = PaginatedResponse(results: sSelf.resultsList,
                                                          error: error,
                                                          requestPagination: paginationRequest,
                                                          responsePagination: result?.list?.pagination)

                if sSelf.changedSearchChipsState(with: searchChipsState) == false {
                    sSelf.handlePaginatedResponse(response: paginatedResponse)
                } else {
                    sSelf.pageFetchingGroup.leave()
                }
            }
        })
    }

    private func searchChipsState() -> String {
        var state = ""
        for chip in searchChips where chip.selected == true {
            state += chip.type.rawValue
        }
        return state
    }

    private func changedSearchChipsState(with oldState: String) -> Bool {
        // Mixed items displayed in search results list when server is responding slow and user changes the filter
        let state = self.searchChipsState()
        if oldState == state {
            return false
        }
        return true
    }
}

extension ContextualSearchViewModel: ResultsViewModelDelegate {
    func refreshResults() {
        performSearch(for: lastSearchedString, paginationRequest: nil)
    }
}
