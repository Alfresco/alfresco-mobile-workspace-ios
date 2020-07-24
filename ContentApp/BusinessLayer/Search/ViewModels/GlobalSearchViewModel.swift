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
import AlfrescoContentServices

class GlobalSearchViewModel: SearchViewModelProtocol {
    var resultsList: [ListNode] = []
    var accountService: AccountService?
    var searchChips: [SearchChipItem] = []

    weak var viewModelDelegate: SearchViewModelDelegate?

    private var liveSearchTimer: Timer?
    private var currentPage: Int = 1
    private var searchGroup = DispatchGroup()
    private var hasMoreItems = true

    // MARK: - Init

    init(accountService: AccountService?) {
        self.accountService = accountService
    }

    // MARK: - Public methods

    func defaultSearchChips() -> [SearchChipItem] {
        searchChips = [ SearchChipItem(name: LocalizationConstants.Search.chipFiles, type: .file),
                        SearchChipItem(name: LocalizationConstants.Search.chipFolders, type: .folder),
                        SearchChipItem(name: LocalizationConstants.Search.chipLibraries, type: .library, selected: false)]
        return searchChips
    }

    func logicSearchChips(chipTapped: SearchChipItem) -> [Int] {
        var indexChipsReload: [Int] = []
        if chipTapped.type == .library {
            for chip in searchChips where chip.type != .library && chip.selected {
                chip.selected = false
                indexChipsReload.append(searchChips.firstIndex(where: { $0 == chip }) ?? 0)
            }
        } else {
            for chip in searchChips where chip.type == .library && chip.selected {
                chip.selected = false
                indexChipsReload.append(searchChips.firstIndex(where: { $0 == chip }) ?? 0)
            }
        }
        return indexChipsReload
    }

    func recentSearches() -> [String] {
        return UserDefaults.standard.array(forKey: kSaveRecentSearchesArray) as? [String] ?? []
    }

    func save(recentSearch string: String?) {
        guard let string = string else { return }
        var recents = self.recentSearches()
        if let indexItem = recents.lastIndex(of: string) {
            recents.remove(at: indexItem)
        }
        recents.insert(string, at: 0)
        if recents.count == kMaxElemetsInRecentSearchesArray + 1 {
            recents.removeLast()
        }
        UserDefaults.standard.set(recents, forKey: kSaveRecentSearchesArray)
        UserDefaults.standard.synchronize()
    }

    func performSearch(for string: String?, paginationRequest: RequestPagination?) {
        if paginationRequest == nil {
            currentPage = 1
        }

        liveSearchTimer?.invalidate()
        guard let searchString = string?.trimmingCharacters(in: .whitespacesAndNewlines), searchString != "" else {
            self.viewModelDelegate?.handle(results: nil)
            return
        }

        searchGroup.enter()

        if isSearchForLibraries() {
            performLibrariesSearch(searchString: searchString, paginationRequest: paginationRequest)
        } else {
            performFileFolderSearch(searchString: searchString, paginationRequest: paginationRequest)
        }
    }

    func performLiveSearch(for string: String?) {
        liveSearchTimer?.invalidate()
        guard let searchString = string?.trimmingCharacters(in: .whitespacesAndNewlines), searchString != "",
            searchString.count >= kMinCharactersForLiveSearch else {
                self.viewModelDelegate?.handle(results: nil)
                return
        }
        liveSearchTimer = Timer.scheduledTimer(withTimeInterval: kSearchTimerBuffer, repeats: false, block: { [weak self] (timer) in
            timer.invalidate()
            guard let sSelf = self else { return }
            sSelf.performSearch(for: searchString)
        })
    }

    func fetchNextSearchResultsPage(for string: String?, index: IndexPath) {
        searchGroup.notify(queue: .global()) { [weak self] in
            guard let sSelf = self else { return }

            if sSelf.hasMoreItems {
                let nextPage = RequestPagination(maxItems: kListPageSize, skipCount: sSelf.currentPage * kListPageSize)
                sSelf.performSearch(for: string, paginationRequest: nextPage)
            }
        }
    }

    // MARK: Private Methods

    private func isSearchForLibraries() -> Bool {
        for chip in searchChips where chip.type == .library {
            return chip.selected
        }
        return false
    }

    private func incrementPage(for paginationRequest: RequestPagination?) {
        if let pageSkipCount = paginationRequest?.skipCount {
            currentPage = pageSkipCount / kListPageSize + 1
        }
    }

    private func performLibrariesSearch(searchString: String, paginationRequest: RequestPagination?) {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentServicesAPI.customHeaders = authenticationProvider.authorizationHeader()
            QueriesAPI.findSites(term: searchString, skipCount: paginationRequest?.skipCount, maxItems: paginationRequest?.maxItems ?? kListPageSize) { (results, error) in

                if let entries = results?.list.entries {
                    sSelf.resultsList = SitesNodeMapper.map(entries)
                }

                sSelf.handle(results: sSelf.resultsList,
                             error: error,
                             paginationRequest: paginationRequest,
                             pagination: results?.list.pagination)
            }
        })
    }

    private func performFileFolderSearch(searchString: String, paginationRequest: RequestPagination?) {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentServicesAPI.customHeaders = authenticationProvider.authorizationHeader()
            SearchAPI.search(queryBody: SearchRequestBuilder.searchRequest(searchString, chipFilters: sSelf.searchChips, pagination: paginationRequest)) { (result, error) in

                if let entries = result?.list?.entries {
                    sSelf.resultsList = ResultsNodeMapper.map(entries)
                }

                sSelf.handle(results: sSelf.resultsList,
                             error: error,
                             paginationRequest: paginationRequest,
                             pagination: result?.list?.pagination)
            }
        })
    }

    func handle(results: [ListNode]?, error: Error?, paginationRequest: RequestPagination?, pagination: Pagination?) {
        if let error = error {
            AlfrescoLog.error(error)

            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                sSelf.viewModelDelegate?.handle(results: nil, pagination: nil, error: error)
            }
        } else if let results = results, let skipCount = pagination?.skipCount {
            self.hasMoreItems = (Int64(results.count) + skipCount) == pagination?.totalItems ? false : true

            if paginationRequest != nil && hasMoreItems {
                incrementPage(for: paginationRequest)
            }

            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                sSelf.viewModelDelegate?.handle(results: results, pagination: pagination, error: nil)
            }
        }
        searchGroup.leave()
    }
}
