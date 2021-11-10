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
    private var lastSearchCompletionOperation: SearchCompletionHandler?

    var delegate: ListComponentModelDelegate?
    var rawListNodes: [ListNode] = []
    var searchChips: [SearchChipItem] = []
    var searchString: String?
    var searchType: SearchType = .simple
    var selectedSearchFilter: AdvanceSearchFilters?

    init(with services: CoordinatorServices) {
        self.services = services
    }

    // MARK: - SearchModelProtocol
    
    func isNodePathEnabled() -> Bool {
        return true
    }

    func defaultSearchChips(for configurations: [AdvanceSearchFilters], and index: Int) -> [SearchChipItem] {
        return []
    }

    func searchChipIndexes(for tappedChip: SearchChipItem) -> [Int] {
        return []
    }

    func performSearch(for string: String,
                       paginationRequest: RequestPagination?,
                       completionHandler: SearchCompletionHandler) {
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

        handleSearch(for: sString,
                        paginationRequest: paginationRequest,
                        completionHandler: completionHandler)
    }
    
    func performLiveSearch(for string: String,
                           paginationRequest: RequestPagination?,
                           completionHandler: SearchCompletionHandler) {
        liveSearchTimer?.invalidate()
        liveSearchTimer = Timer.scheduledTimer(withTimeInterval: searchTimerBuffer,
                                               repeats: false,
                                               block: { [weak self] (timer) in
                                                timer.invalidate()
                                                guard let sSelf = self else { return }
                                                sSelf.performSearch(for: string,
                                                                    paginationRequest: paginationRequest,
                                                                    completionHandler: completionHandler)
                                               })
    }

    func handleSearch(for searchString: String,
                      paginationRequest: RequestPagination?,
                      completionHandler: SearchCompletionHandler) {
        // Override in children class
    }

    // MARK: - Public interface

    func performLibrariesSearch(searchString: String,
                                paginationRequest: RequestPagination?,
                                completionHandler: SearchCompletionHandler) {
        services.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            QueriesAPI.findSites(term: searchString,
                                 skipCount: paginationRequest?.skipCount,
                                 maxItems: paginationRequest?.maxItems ?? APIConstants.pageSize) { [weak self] (results, error) in
                guard let sSelf = self else { return }
                if completionHandler == sSelf.lastSearchCompletionOperation {
                    var listNodes: [ListNode] = []
                    if let entries = results?.list.entries {
                        listNodes = SitesNodeMapper.map(entries)
                    }

                    let paginatedResponse = PaginatedResponse(results: listNodes,
                                                              error: error,
                                                              requestPagination: paginationRequest,
                                                              responsePagination: results?.list.pagination)
                    completionHandler.handler(paginatedResponse)
                }
            }
        })
    }

    func performFileFolderSearch(searchString: String,
                                 paginationRequest: RequestPagination?,
                                 completionHandler: SearchCompletionHandler) {
        if !isSearchForAdvanceFilters() {
            performConventionalSearch(searchString: searchString, paginationRequest: paginationRequest, completionHandler: completionHandler)
        } else {
            performAdvanceSearch(searchString: searchString, paginationRequest: paginationRequest, completionHandler: completionHandler)
        }
    }
    
    // MARK: - Conventioanl Search
    func performConventionalSearch(searchString: String, paginationRequest: RequestPagination?, completionHandler: SearchCompletionHandler) {
        services.accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            let simpleSearchRequest = SearchRequestBuilder.searchRequest(searchString,
                                                                         chipFilters: sSelf.searchChips,
                                                                         pagination: paginationRequest,
                                                                         selectedSearchFilter: nil)
            SearchAPI.simpleSearch(searchRequest: simpleSearchRequest) { [weak self] (result, error) in
                guard let sSelf = self else { return }

                if completionHandler == sSelf.lastSearchCompletionOperation {
                    var listNodes: [ListNode] = []
                    if let entries = result?.list?.entries {
                        listNodes = ResultsNodeMapper.map(entries)
                    }
                    let paginatedResponse = PaginatedResponse(results: listNodes,
                                                              error: error,
                                                              requestPagination: paginationRequest,
                                                              responsePagination: result?.list?.pagination)
                    completionHandler.handler(paginatedResponse)
                }
            }
        })
    }
    
    // MARK: - Advance search
    func performAdvanceSearch(searchString: String, paginationRequest: RequestPagination?, completionHandler: SearchCompletionHandler) {
        
        services.accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            let simpleSearchRequest = SearchRequestBuilder.searchRequest(searchString,
                                                                         chipFilters: sSelf.searchChips,
                                                                         pagination: paginationRequest,
                                                                         selectedSearchFilter: self?.selectedSearchFilter)
            SearchAPI.simpleSearch(searchRequest: simpleSearchRequest) { [weak self] (result, error) in
                guard let sSelf = self else { return }

                if completionHandler == sSelf.lastSearchCompletionOperation {
                    var listNodes: [ListNode] = []
                    if let entries = result?.list?.entries {
                        listNodes = ResultsNodeMapper.map(entries)
                    }
                    let paginatedResponse = PaginatedResponse(results: listNodes,
                                                              error: error,
                                                              requestPagination: paginationRequest,
                                                              responsePagination: result?.list?.pagination)
                    completionHandler.handler(paginatedResponse)
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
    
    func isSearchForAdvanceFilters() -> Bool {
        if let accountIdentifier = services.accountService?.activeAccount?.identifier, let _ = DiskService.getAdvanceSearchConfigurations(for: accountIdentifier) {
            return true
        }
        return false
    }
    
    // MARK: - Advance Search Configuration
    func getAdvanceSearchConfigurationFromServer(callback completion: ((_ configuration: SearchConfigModel?, _ data: Data?) -> Void)?) {
        services.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            QueriesAPI.loadAdvanceSearchConfigurations(for: nil) { (configuration, data, error) in
                completion?(configuration, data)
            }
        })
    }
}

// MARK: - Search Model Extension
extension SearchModel {
    func getCategories(for configurations: [AdvanceSearchFilters], and index: Int) -> [SearchCategories] {
        if index >= 0 {
            return configurations[index].categories
        }
        return []
    }
    
    func getChipsForAdvanceSearch(for configurations: [AdvanceSearchFilters], and index: Int) -> [SearchChipItem] {
        let categories = getCategories(for: configurations, and: index)
        var chipsArray = [SearchChipItem]()
        for category in categories {
            let name = category.name ?? ""
            if let selector = category.component?.selector, let componentType = ComponentType(rawValue: selector) {
                let chip = SearchChipItem(name: name,
                                          selected: false,
                                          componentType: componentType)
                chipsArray.append(chip)
            }
        }
        return chipsArray
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

    func listNode(for indexPath: IndexPath) -> ListNode? {
        if !rawListNodes.isEmpty && rawListNodes.count > indexPath.row {
            return rawListNodes[indexPath.row]
        }
        return nil
    }

    func titleForSectionHeader(at indexPath: IndexPath) -> String {
        return ""
    }

    func fetchItems(with requestPagination: RequestPagination,
                    completionHandler: @escaping PagedResponseCompletionHandler) {
        guard let string = searchString else {
            rawListNodes = []
            delegate?.needsDisplayStateRefresh()
            return
        }

        let completionHandler = SearchCompletionHandler(completionHandler: completionHandler)
        lastSearchCompletionOperation = completionHandler

        switch searchType {
        case .simple:
            self.performSearch(for: string,
                               paginationRequest: requestPagination,
                               completionHandler: completionHandler)
        case .live :
            self.performLiveSearch(for: string,
                                   paginationRequest: requestPagination,
                                   completionHandler: completionHandler)
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

class SearchCompletionHandler: Equatable {
    static func == (lhs: SearchCompletionHandler, rhs: SearchCompletionHandler) -> Bool {
        return lhs === rhs
    }

    var handler: PagedResponseCompletionHandler

    init(completionHandler: @escaping PagedResponseCompletionHandler) {
        handler = completionHandler
    }
}
