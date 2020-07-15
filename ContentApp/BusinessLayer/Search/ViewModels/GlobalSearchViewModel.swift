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
    var resultsList: [ListElementProtocol] = []
    var accountService: AccountService?
    var searchChips: [SearchChipItem] = []

    weak var viewModelDelegate: SearchViewModelDelegate?

    private var liveSearchTimer: Timer?

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

    func performSearch(for string: String?) {
        liveSearchTimer?.invalidate()
        guard let searchString = string?.trimmingCharacters(in: .whitespacesAndNewlines), searchString != "" else {
            self.viewModelDelegate?.handle(results: nil)
            return
        }
        if isSearchForLibraries() {
            performLibrariesSearch(searchString: searchString)
        } else {
            performFileFolderSearch(searchString: searchString)
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

    // MARK: Private Methods

    private func isSearchForLibraries() -> Bool {
        for chip in searchChips where chip.type == .library {
            return chip.selected
        }
        return false
    }

    private func performLibrariesSearch(searchString: String) {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentServicesAPI.customHeaders = authenticationProvider.authorizationHeader()
            QueriesAPI.findSites(term: searchString) { (results, error) in
                if let entries = results?.list.entries {
                    DispatchQueue.main.async {
                        sSelf.viewModelDelegate?.handle(results: ListSite.sites(entries))
                    }
                } else {
                    if let error = error {
                        AlfrescoLog.error(error)
                    }
                    DispatchQueue.main.async {
                        sSelf.viewModelDelegate?.handle(results: [])
                    }
                }
            }
        })
    }

    private func performFileFolderSearch(searchString: String) {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentServicesAPI.customHeaders = authenticationProvider.authorizationHeader()
            SearchAPI.search(queryBody: SearchRequestBuilder.searchRequest(searchString, chipFilters: sSelf.searchChips)) { (result, error) in
                if let entries = result?.list?.entries {
                    sSelf.resultsList = ListNode.nodes(entries)
                    DispatchQueue.main.async {
                        sSelf.viewModelDelegate?.handle(results: sSelf.resultsList)
                    }
                } else {
                    if let error = error {
                        AlfrescoLog.error(error)
                    }
                    DispatchQueue.main.async {
                        sSelf.viewModelDelegate?.handle(results: [])
                    }
                }
            }
        })
    }
}
