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

protocol SearchViewModelDelegate: class {
    /**
    Update data source with search results
    - results: list of nodes from a search operation
     - Note: If the list  is empty,  a view with empty list will appear.  If the list is a nil object then recent searches will appear
    */
    func search(results: [ListNode]?)
}

class SearchViewModel {
    var nodes: [ListNode] = []
    var accountService: AccountService?
    weak var viewModelDelegate: SearchViewModelDelegate?
    var liveSearchTimer: Timer?

    // MARK: - Init

    init(accountService: AccountService?) {
        self.accountService = accountService
    }

    // MARK: - Public methods

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
        guard let searchString = string?.trimmingCharacters(in: .whitespacesAndNewlines), searchString != "" else {
            self.viewModelDelegate?.search(results: nil)
            return
        }

        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentServicesAPI.customHeaders = authenticationProvider.authorizationHeader()
            SearchAPI.search(queryBody: sSelf.searchRequest(searchString)) { (result, error) in
                if let entries = result?.list?.entries {
                    sSelf.nodes = ListNode.nodes(entries)
                    DispatchQueue.main.async {
                        sSelf.viewModelDelegate?.search(results: sSelf.nodes)
                    }
                } else {
                    if let error = error {
                        AlfrescoLog.error(error)
                    }
                    DispatchQueue.main.async {
                        sSelf.viewModelDelegate?.search(results: [])
                    }
                }
            }
        })
    }

    func performLiveSearch(for string: String?) {
        liveSearchTimer?.invalidate()
        guard let searchString = string?.trimmingCharacters(in: .whitespacesAndNewlines), searchString != "", searchString.count > 2 else {
            self.viewModelDelegate?.search(results: nil)
            return
        }
        liveSearchTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { [weak self] (timer) in
            timer.invalidate()
            guard let sSelf = self else { return }
            sSelf.performSearch(for: searchString)
        })
    }

    // MARK: - Private methods

    private func searchRequest(_ string: String) -> SearchRequest {
        let requestQuery = RequestQuery(language: .afts, userQuery: nil, query: string + "*")
        let defaultRequest = RequestDefaults(textAttributes: nil, defaultFTSOperator: nil, defaultFTSFieldOperator: .and, namespace: nil, defaultFieldName: "keywords")
        let templates = RequestTemplates([RequestTemplatesInner(name: defaultRequest.defaultFieldName, template: "%(cm:name cm:title cm:description TEXT TAG)")])
        let filterQueries = RequestFilterQueries([RequestFilterQueriesInner(query: "+TYPE:'cm:folder' OR +TYPE:'cm:content'", tags: nil),
                                                  RequestFilterQueriesInner(query: "-TYPE:'cm:thumbnail' AND -TYPE:'cm:failedThumbnail' AND -TYPE:'cm:rating'", tags: nil),
                                                  RequestFilterQueriesInner(query: "-cm:creator:System AND -QNAME:comment", tags: nil),
                                                  RequestFilterQueriesInner(query: "-TYPE:'st:site' AND -ASPECT:'st:siteContainer' AND -ASPECT:'sys:hidden'", tags: nil),
                                                  RequestFilterQueriesInner(query: "-TYPE:'dl:dataList' AND -TYPE:'dl:todoList' AND -TYPE:'dl:issue'", tags: nil),
                                                  RequestFilterQueriesInner(query: "-TYPE:'fm:topic' AND -TYPE:'fm:post'", tags: nil),
                                                  RequestFilterQueriesInner(query: "-TYPE:'lnk:link'", tags: nil),
                                                  RequestFilterQueriesInner(query: "-PNAME:'0/wiki'", tags: nil)])
        let sortRequest = RequestSortDefinition([RequestSortDefinitionInner(type: .field, field: "score", ascending: false)])

        let searchRequest = SearchRequest(query: requestQuery, paging: nil, include: ["path"], includeRequest: nil, fields: nil, sort: sortRequest, templates: templates, defaults: defaultRequest, localization: nil, filterQueries: filterQueries, facetQueries: nil, facetFields: nil, facetIntervals: nil, pivots: nil, stats: nil, spellcheck: nil, scope: nil, limits: nil, highlight: nil, ranges: nil)
        return searchRequest
    }
}
