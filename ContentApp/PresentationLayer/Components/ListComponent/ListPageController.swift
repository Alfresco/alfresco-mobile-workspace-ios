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
    var isPaginationEnabled: Bool { get set}
    var dataSource: ListModelProtocol { get }
    var delegate: ListPageControllerDelegate? { get set }

    func fetchNextPage(userInfo: Any?)
    func refreshList()
    func clear()
}

protocol ListPageControllerDelegate: AnyObject {
    func didUpdateList(error: Error?,
                       pagination: Pagination?)
}

class ListPageController: ListPageControllerProtocol {
    var services: CoordinatorServices?
    var dataSource: ListModelProtocol
    weak var delegate: ListPageControllerDelegate?
    var isPaginationEnabled: Bool {
        get {
            return self.isPaginationEnabled &&
                services?.connectivityService?.hasInternetConnection() == true
        }

        set {
            self.isPaginationEnabled = newValue
        }
    }
    var currentPage = 1
    var pageSkipCount = 0
    var hasMoreItems = true
    var shouldDisplayNextPageLoadingIndicator = false
    private var refreshedList = false

    init(dataSource: ListModelProtocol) {
        self.dataSource = dataSource
        self.dataSource.delegate = self
    }

    func fetchNextPage(userInfo: Any?) {
        let connectivityService = ApplicationBootstrap.shared().repository.service(of: ConnectivityService.identifier) as? ConnectivityService
        if connectivityService?.hasInternetConnection() == false {
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                sSelf.pageSkipCount = 0
                sSelf.refreshedList = false
                sSelf.update(with: sSelf.dataSource.rawListNodes,
                             pagination: nil,
                             error: nil)
            }
        }

        if hasMoreItems {
            let skipCount = refreshedList ? APIConstants.pageSize : dataSource.rawListNodes.count
            let nextPage = RequestPagination(maxItems: APIConstants.pageSize,
                                             skipCount: skipCount)
            if skipCount != pageSkipCount {
                pageSkipCount = skipCount
                dataSource.fetchItems(with: nextPage, userInfo: userInfo) { [weak self] paginatedResponse in
                    guard let sSelf = self else { return }
                    sSelf.handlePaginatedResponse(response: paginatedResponse)
                }
            }
        }
    }

    func refreshList() {
        refreshedList = true
        currentPage = 1
        fetchNextPage(userInfo: nil)
    }

    func clear() {
        dataSource.rawListNodes = []
    }

    // MARK: - Private interface

    private func handlePaginatedResponse(response: PaginatedResponse) {
        if let error = response.error {
            refreshedList = false
            pageSkipCount = 0
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

            refreshedList = false
            pageSkipCount = 0
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

        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.delegate?.didUpdateList(error: error,
                                          pagination: pagination)
        }
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
    func needsDataSourceReload() {
        refreshList()
    }
}
