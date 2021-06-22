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
}

protocol ListPageControllerProtocol: AnyObject {
    var dataSource: ListModelProtocol { get }
    var delegate: ListPageControllerDelegate? { get set }

    func isPaginationEnabled() -> Bool
    func fetchNextPage()
    func refreshList()
    func clear()
}

protocol ListPageControllerDelegate: AnyObject {
    func didUpdateList(error: Error?,
                       pagination: Pagination?)
    func forceDisplayRefresh(for indexPath: IndexPath)
}

class ListPageController: ListPageControllerProtocol {
    let services: CoordinatorServices
    var dataSource: ListModelProtocol
    weak var delegate: ListPageControllerDelegate?
    var paginationEnabled: Bool
    var currentPage = 1
    var pageSkipCount = 0
    var totalItems: Int64 = 0
    var hasMoreItems = true
    var shouldDisplayNextPageLoadingIndicator = false
    
    private var shouldRefreshList = true
    private var requestInProgress = false

    init(dataSource: ListModelProtocol, services: CoordinatorServices) {
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
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                sSelf.update(with: sSelf.dataSource.rawListNodes,
                             pagination: nil,
                             error: nil)
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
                                pagination: nil)
    }

    // MARK: - Private interface

    private func handlePaginatedResponse(response: PaginatedResponse) {
        requestInProgress = false
        if let error = response.error {
            update(with: [],
                   pagination: nil,
                   error: error)
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
                   error: nil)
        }
    }

    private func update(with results: [ListNode],
                        pagination: Pagination?,
                        error: Error?) {
        if !results.isEmpty {
            if pagination?.skipCount != 0 {
                addNewResults(results: results, pagination: pagination)
            } else {
                addResults(results: results, pagination: pagination)
            }
        } else if pagination?.skipCount == 0 || error == nil {
            self.dataSource.rawListNodes = []
        }
        delegate?.didUpdateList(error: error,
                                pagination: pagination)
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

            if let pagination = pagination {
                shouldDisplayNextPageLoadingIndicator =
                    (Int64(self.dataSource.rawListNodes.count) == pagination.totalItems) ? false : true
            }
        }
    }

    private func addResults(results: [ListNode],
                            pagination: Pagination?) {
        if !results.isEmpty {
            self.dataSource.rawListNodes = results

            shouldDisplayNextPageLoadingIndicator =
                (Int64(results.count) == pagination?.totalItems) ? false : true
        }
    }
}

extension ListPageController: ListModelDelegate {
    func forceDisplayRefresh(for indexPath: IndexPath) {
        delegate?.forceDisplayRefresh(for: indexPath)
    }

    func needsDisplayStateRefresh() {
        let pagination = Pagination(count: Int64(dataSource.numberOfItems(in: 0)),
                                    hasMoreItems: hasMoreItems,
                                    totalItems: totalItems,
                                    skipCount: Int64(pageSkipCount),
                                    maxItems: Int64(0))
        delegate?.didUpdateList(error: nil,
                                pagination: pagination)
    }

    func needsDataSourceReload() {
        refreshList()
    }
}
