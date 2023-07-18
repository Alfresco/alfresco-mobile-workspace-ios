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

typealias PagedResponseCompletionHandler = ((PaginatedResponse) -> Void)

struct PaginatedResponse {
    var results: [ListNode]
    var error: Error?
    var requestPagination: RequestPagination?
    var responsePagination: Pagination?
    var searchFacets = [SearchFacets]()
    var source: Node?
}

protocol ListPageControllerProtocol: AnyObject {
    var dataSource: ListComponentModelProtocol { get }
    var delegate: ListPageControllerDelegate? { get set }
    var resultPageDelegate: ResultPageControllerDelegate? { get set }

    func isPaginationEnabled() -> Bool
    func fetchNextPage()
    func refreshList()
    func clear()
}

protocol ListPageControllerDelegate: AnyObject {
    func didUpdateList(error: Error?,
                       pagination: Pagination?,
                       source: Node?)
    func forceDisplayRefresh(for indexPath: IndexPath)
}

protocol ResultPageControllerDelegate: AnyObject {
    func didUpdateChips(error: Error?, searchFacets: [SearchFacets])
}

class ListPageController: ListPageControllerProtocol {
    let services: CoordinatorServices
    var dataSource: ListComponentModelProtocol
    weak var delegate: ListPageControllerDelegate?
    var resultPageDelegate: ResultPageControllerDelegate?
    var paginationEnabled: Bool
    var currentPage = 1
    var pageSkipCount = 0
    var totalItems: Int64 = 0
    var hasMoreItems = true
    var shouldDisplayNextPageLoadingIndicator = false

    private var shouldRefreshList = true
    private var requestInProgress = false
    var sourceNodeToMove: [ListNode]?

    init(dataSource: ListComponentModelProtocol, services: CoordinatorServices) {
        self.dataSource = dataSource
        paginationEnabled = true
        self.services = services
        self.dataSource.delegate = self
    }

    func isPaginationEnabled() -> Bool {
        return paginationEnabled &&
            services.connectivityService?.hasInternetConnection() == true
    }

    func fetchNextPage() {
        let connectivityService = ApplicationBootstrap.shared().repository.service(of: ConnectivityService.identifier) as? ConnectivityService
        if connectivityService?.hasInternetConnection() == false {
            if dataSource is SearchModel {
                (dataSource as? SearchModel)?.fetchOfflineItems { [weak self] paginatedResponse in
                    guard let sSelf = self else { return }
                    sSelf.handlePaginatedResponse(response: paginatedResponse)
                }
                return
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let sSelf = self else { return }
                    sSelf.update(with: sSelf.dataSource.rawListNodes,
                                 pagination: nil,
                                 error: nil,
                                 source: nil)
                }
            }
        }

        if hasMoreItems && !requestInProgress {
            if shouldRefreshList {
                pageSkipCount = 0
                shouldRefreshList = false
            } else {
                pageSkipCount = dataSource.rawListNodes.isEmpty ? 0 : dataSource.rawListNodes.count
            }
            let nextPage = RequestPagination(maxItems: APIConstants.pageSize,
                                             skipCount: pageSkipCount)
            requestInProgress = true
            dataSource.fetchItems(with: nextPage) { [weak self] paginatedResponse in
                guard let sSelf = self else { return }
                sSelf.handlePaginatedResponse(response: paginatedResponse)
            }
        }
    }

    func refreshList() {
        currentPage = 1
        hasMoreItems = true
        shouldRefreshList = true
        fetchNextPage()
    }

    func clear() {
        dataSource.clear()
        delegate?.didUpdateList(error: nil,
                                pagination: nil, source: nil)
    }

    // MARK: - Private interface

    private func handlePaginatedResponse(response: PaginatedResponse) {
        requestInProgress = false
        if let error = response.error {
            update(with: [],
                   pagination: nil,
                   error: error,
                   source: response.source)
        } else if let skipCount = response.responsePagination?.skipCount {
            let results = response.results
            self.hasMoreItems =
                (Int64(results.count) + skipCount) == response.responsePagination?.totalItems ? false : true

            if response.requestPagination != nil && hasMoreItems {
                incrementPage(for: response.requestPagination)
            }

            totalItems = response.responsePagination?.maxItems ?? 0
            update(with: results,
                   pagination: response.responsePagination,
                   error: nil,
                   source: response.source)
            
            resultPageDelegate?.didUpdateChips(error: nil, searchFacets: response.searchFacets)
        }
    }

    private func update(with results: [ListNode],
                        pagination: Pagination?,
                        error: Error?,
                        source: Node?) {
        
        var listNodes = results
        let isMove = appDelegate()?.isMoveFilesAndFolderFlow ?? false
        if isMove {
            let nodes = sourceNodeToMove ?? []
            for node in nodes {
                if let index = listNodes.firstIndex(where: {$0.guid == node.guid}) {
                    listNodes.remove(at: index)
                }
            }
        }
        
        if !listNodes.isEmpty {
            if pagination?.skipCount != 0 {
                addNewResults(results: listNodes, pagination: pagination)
            } else {
                addResults(results: listNodes, pagination: pagination)
            }
        } else if pagination?.skipCount == 0 || error == nil {
            self.dataSource.rawListNodes = []
            if let totalItems = pagination?.totalItems {
                shouldDisplayNextPageLoadingIndicator =
                    (Int64(self.dataSource.rawListNodes.count) >= totalItems) ? false : true
                
                if isMove && listNodes.isEmpty {
                    shouldDisplayNextPageLoadingIndicator = false
                }
            }
        }
        delegate?.didUpdateList(error: error,
                                pagination: pagination, source: source)
    }

    private final func incrementPage(for paginationRequest: RequestPagination?) {
        if let pageSkipCount = paginationRequest?.skipCount {
            currentPage = pageSkipCount / APIConstants.pageSize + 1
        }
    }

    private func addNewResults(results: [ListNode],
                               pagination: Pagination?) {
        if !results.isEmpty {
            let olderElementsSet = Set(self.dataSource.rawListNodes)
            let newElementsSet = Set(results)

            if !newElementsSet.isSubset(of: olderElementsSet) {
                self.dataSource.rawListNodes.append(contentsOf: results)
            }

            if let totalItems = pagination?.totalItems {
                // Because the list node collection could mutate in certain situations: upload,
                // consider counts past the raw collection size
                shouldDisplayNextPageLoadingIndicator =
                    (Int64(self.dataSource.rawListNodes.count) >= totalItems) ? false : true
                
                let isMove = appDelegate()?.isMoveFilesAndFolderFlow ?? false
                if isMove && Int64(results.count) == totalItems - 1 {
                    shouldDisplayNextPageLoadingIndicator = false
                }
            }
        }
    }

    private func addResults(results: [ListNode],
                            pagination: Pagination?) {
        if !results.isEmpty {
            self.dataSource.rawListNodes = results

            if let totalItems = pagination?.totalItems {
                // Because the list node collection could mutate in certain situations: upload,
                // consider counts past the raw collection size
                shouldDisplayNextPageLoadingIndicator =
                    (Int64(results.count) >= totalItems) ? false : true
                
                let isMove = appDelegate()?.isMoveFilesAndFolderFlow ?? false
                if isMove && Int64(results.count) == totalItems - 1 {
                    shouldDisplayNextPageLoadingIndicator = false
                }
            }
        }
    }
}

extension ListPageController: ListComponentModelDelegate {
    func forceDisplayRefresh(for indexPath: IndexPath) {
        delegate?.forceDisplayRefresh(for: indexPath)
    }

    func needsDisplayStateRefresh() {
        requestInProgress = false
        let pagination = Pagination(count: Int64(dataSource.numberOfItems(in: 0)),
                                    hasMoreItems: hasMoreItems,
                                    totalItems: totalItems,
                                    skipCount: Int64(pageSkipCount),
                                    maxItems: Int64(0))
        delegate?.didUpdateList(error: nil,
                                pagination: pagination, source: nil)
    }

    func needsDataSourceReload() {
        refreshList()
    }
}
