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

struct PaginatedResponse {
    var results: [ListNode]?
    var error: Error?
    var requestPagination: RequestPagination?
    var responsePagination: Pagination?
}

typealias PagedResponseCompletionHandler = ((PaginatedResponse) -> Void)

class PageFetchingViewModel {
    weak var pageUpdatingDelegate: ListComponentPageUpdatingDelegate?

    var pageFetchingGroup = DispatchGroup()
    var currentPage: Int = 1
    var hasMoreItems = true

    var shouldDisplayNextPageLoadingIndicator: Bool = false
    var results: [ListNode] = [] {
        willSet {
            shouldDisplayNextPageLoadingIndicator = true
        }
        didSet {
            updatedResults(results: results)
        }
    }

    final func fetchNextListPage(index: IndexPath, userInfo: Any?) {
        pageFetchingGroup.notify(queue: .global()) { [weak self] in
            guard let sSelf = self else { return }

            if sSelf.hasMoreItems {
                let nextPage = RequestPagination(maxItems: kListPageSize, skipCount: sSelf.currentPage * kListPageSize)
                sSelf.fetchItems(with: nextPage, userInfo: userInfo, completionHandler: { (paginatedResponse) in
                    sSelf.handlePaginatedResponse(response: paginatedResponse)
                })
            }
        }
    }

    final func handlePaginatedResponse(response: PaginatedResponse) {
        if let error = response.error {
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                sSelf.handlePage(results: nil, pagination: nil, error: error)
            }
        } else if let results = response.results, let skipCount = response.responsePagination?.skipCount {
            self.hasMoreItems = (Int64(results.count) + skipCount) == response.responsePagination?.totalItems ? false : true

            if response.requestPagination != nil && hasMoreItems {
                incrementPage(for: response.requestPagination)
            }

            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                sSelf.handlePage(results: results, pagination: response.responsePagination, error: nil)
            }
        }
        pageFetchingGroup.leave()
    }

    func updateResults(results: [ListNode]?, pagination: Pagination?, error: Error?) {
        if let results = results {
            if results.count > 0 {
                if pagination?.skipCount != 0 {
                    addNewResults(results: results, pagination: pagination)
                } else {
                    addResults(results: results, pagination: pagination)
                }
            } else if pagination?.skipCount == 0 {
                self.results = []
            }
        } else {
            if error == nil {
                self.results = []
            }
        }

        pageUpdatingDelegate?.didUpdateList(error: error, pagination: pagination)
    }

    func clear() {
        results = []
    }

    func updatedResults(results: [ListNode]) {}

    func fetchItems(with requestPagination: RequestPagination, userInfo: Any?, completionHandler: @escaping PagedResponseCompletionHandler) {
        // Override in subclass to provide items for a page
    }

    func handlePage(results: [ListNode]?, pagination: Pagination?, error: Error?) {
        // Override in subclass to handle results for a page
    }

    // MARK: - Private interface

    private final func incrementPage(for paginationRequest: RequestPagination?) {
        if let pageSkipCount = paginationRequest?.skipCount {
            currentPage = pageSkipCount / kListPageSize + 1
        }
    }

    private func addNewResults(results: [ListNode]?, pagination: Pagination?) {
        guard let results = results else { return }
        if results.count != 0 {
            let olderElementsSet = Set(self.results)
            let newElementsSet = Set(results)

            if !newElementsSet.isSubset(of: olderElementsSet) {
                self.results.append(contentsOf: results)
            }

            if let pagination = pagination {
                shouldDisplayNextPageLoadingIndicator = (Int64(self.results.count) == pagination.totalItems) ? false : true
            }
        }
    }

    private func addResults(results: [ListNode]?, pagination: Pagination?) {
        guard let results = results else { return }
        if results.count != 0 {
            self.results = results

            shouldDisplayNextPageLoadingIndicator = (Int64(results.count) == pagination?.totalItems) ? false : true
        }
    }
}
