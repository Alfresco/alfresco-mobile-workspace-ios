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

class SearchModel: SearchModelProtocol {
    internal var supportedNodeTypes: [NodeType] = []
    private var services: CoordinatorServices
    private var liveSearchTimer: Timer?
    private let searchTimerBuffer = 0.7
    private var searchCompletionHandler: PagedResponseCompletionHandler?

    var delegate: ListComponentModelDelegate?
    var rawListNodes: [ListNode] = []
    var searchChips: [SearchChipItem] = []
    var searchString: String?
    var searchType: SearchType = .simple

    init(with services: CoordinatorServices) {
        self.services = services
    }

    // MARK: - SearchModelProtocol
    
    func isNodePathEnabled() -> Bool {
        return true
    }

    func defaultSearchChips() -> [SearchChipItem] {
        return []
    }

    func searchChipIndexes(for tappedChip: SearchChipItem) -> [Int] {
        return []
    }

    func performSearch(for string: String,
                       paginationRequest: RequestPagination?) {
        searchString = string
        if paginationRequest == nil {
            rawListNodes = []
        }

        liveSearchTimer?.invalidate()

        let sString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if sString.isEmpty {
            rawListNodes = []
            delegate?.needsDisplayStateRefresh()
            return
        }

        handleSearch(for: sString, paginationRequest: paginationRequest)

    }
    
    func performLiveSearch(for string: String,
                           paginationRequest: RequestPagination?) {
        liveSearchTimer?.invalidate()
        liveSearchTimer = Timer.scheduledTimer(withTimeInterval: searchTimerBuffer,
                                               repeats: false,
                                               block: { [weak self] (timer) in
                                                timer.invalidate()
                                                guard let sSelf = self else { return }
                                                sSelf.performSearch(for: string,
                                                                    paginationRequest: paginationRequest)
                                               })
    }

    func handleSearch(for searchString: String, paginationRequest: RequestPagination?) {
        // Override in children class
    }

    // MARK: - Public interface

    func performLibrariesSearch(searchString: String, paginationRequest: RequestPagination?) {
        services.accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            let searchChipsState = sSelf.searchChipsState()
            QueriesAPI.findSites(term: searchString,
                                 skipCount: paginationRequest?.skipCount,
                                 maxItems: paginationRequest?.maxItems ?? APIConstants.pageSize) { (results, error) in
                guard let sSelf = self else { return }

                var listNodes: [ListNode] = []
                if let entries = results?.list.entries {
                    listNodes = SitesNodeMapper.map(entries)
                }

                let paginatedResponse = PaginatedResponse(results: listNodes,
                                                          error: error,
                                                          requestPagination: paginationRequest,
                                                          responsePagination: results?.list.pagination)

                if sSelf.changedSearchChipsState(with: searchChipsState) == false,
                   let completionHandler = sSelf.searchCompletionHandler {
                    completionHandler(paginatedResponse)
                }
            }
        })
    }

    func performFileFolderSearch(searchString: String, paginationRequest: RequestPagination?) {
        services.accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            let searchChipsState = sSelf.searchChipsState()
            let simpleSearchRequest = SearchRequestBuilder.searchRequest(searchString,
                                                                         chipFilters: sSelf.searchChips,
                                                                         pagination: paginationRequest)
            SearchAPI.simpleSearch(searchRequest: simpleSearchRequest) { (result, error) in
                guard let sSelf = self else { return }

                var listNodes: [ListNode] = []
                if let entries = result?.list?.entries {
                    listNodes = ResultsNodeMapper.map(entries)
                }
                let paginatedResponse = PaginatedResponse(results: listNodes,
                                                          error: error,
                                                          requestPagination: paginationRequest,
                                                          responsePagination: result?.list?.pagination)

                if sSelf.changedSearchChipsState(with: searchChipsState) == false,
                   let completionHandler = sSelf.searchCompletionHandler {
                    completionHandler(paginatedResponse)
                }
            }
        })
    }

    func isSearchForLibraries() -> Bool {
        for chip in searchChips where chip.type == .library {
            return chip.selected
        }
        return false
    }

    // MARK: - Private interface

    private func searchChipsState() -> String {
        var state = ""
        for chip in searchChips where chip.selected == true {
            state += chip.type.rawValue
        }
        return state
    }

    private func changedSearchChipsState(with oldState: String) -> Bool {
        // Mixed items displayed in search results list when server takes longer to respond
        // and user changes the filter
        let state = self.searchChipsState()
        if oldState == state {
            return false
        }
        return true
    }
}

// MARK: - ListModelProtocol

extension SearchModel: ListComponentModelProtocol {
    func isEmpty() -> Bool {
        return rawListNodes.isEmpty
    }

    func numberOfItems(in section: Int) -> Int {
        return rawListNodes.count
    }

    func listNodes() -> [ListNode] {
        return rawListNodes
    }

    func listNode(for indexPath: IndexPath) -> ListNode {
        return rawListNodes[indexPath.row]
    }

    func titleForSectionHeader(at indexPath: IndexPath) -> String {
        return ""
    }

    func fetchItems(with requestPagination: RequestPagination,
                    completionHandler: @escaping PagedResponseCompletionHandler) {
        searchCompletionHandler = completionHandler

        guard let string = searchString else {
            rawListNodes = []
            delegate?.needsDisplayStateRefresh()
            return
        }

        switch searchType {
        case .simple:
            self.performSearch(for: string,
                               paginationRequest: requestPagination)
        case .live :
            self.performLiveSearch(for: string,
                                   paginationRequest: requestPagination)
        }
    }
}

// MARK: - Event observable

extension SearchModel: EventObservable {
    func handle(event: BaseNodeEvent, on queue: EventQueueType) {
        if let publishedEvent = event as? FavouriteEvent {
            handleFavorite(event: publishedEvent)
        } else if let publishedEvent = event as? MoveEvent {
            handleMove(event: publishedEvent)
        } else if let publishedEvent = event as? OfflineEvent {
            handleOffline(event: publishedEvent)
        }
    }

    private func handleFavorite(event: FavouriteEvent) {
        let node = event.node
        for listNode in rawListNodes where listNode.guid == node.guid {
            listNode.favorite = node.favorite
        }
    }

    private func handleMove(event: MoveEvent) {
        let node = event.node
        switch event.eventType {
        case .moveToTrash:
            if node.nodeType == .file {
                if let indexOfMovedNode = rawListNodes.firstIndex(where: { listNode in
                    listNode.guid == node.guid
                }) {
                    rawListNodes.remove(at: indexOfMovedNode)
                    delegate?.needsDisplayStateRefresh()
                }
            } else {
                delegate?.needsDataSourceReload()
            }
        case .restore:
            delegate?.needsDataSourceReload()
        default: break
        }
    }

    private func handleOffline(event: OfflineEvent) {
        let node = event.node

        if let indexOfOfflineNode = rawListNodes.firstIndex(where: { listNode in
            listNode.guid == node.guid
        }) {
            rawListNodes[indexOfOfflineNode] = node

            let indexPath = IndexPath(row: indexOfOfflineNode, section: 0)
            delegate?.forceDisplayRefresh(for: indexPath)
        }
    }
}

