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

protocol PageFetchingViewModelDelegate: class {
    func fetchItems(with requestPagination: RequestPagination, userInfo: Any, completionHandler: @escaping PagedResponseCompletionHandler)
    func handle(results: [ListNode]?, pagination: Pagination?, error: Error?)
}

class PageFetchingViewModel {
    weak var pageFetchingDelegate: PageFetchingViewModelDelegate?

    var pageFetchingGroup = DispatchGroup()
    var currentPage: Int = 1
    var hasMoreItems = true

    final func fetchNextListPage(index: IndexPath, userInfo: Any) {
        pageFetchingGroup.notify(queue: .global()) { [weak self] in
            guard let sSelf = self else { return }

            if sSelf.hasMoreItems {
                let nextPage = RequestPagination(maxItems: kListPageSize, skipCount: sSelf.currentPage * kListPageSize)
                sSelf.pageFetchingDelegate?.fetchItems(with: nextPage, userInfo: userInfo, completionHandler: { (paginatedResponse) in
                    sSelf.handle(paginatedResponse: paginatedResponse)
                })
            }
        }
    }

    final func handle(paginatedResponse: PaginatedResponse) {
        if let error = paginatedResponse.error {
            AlfrescoLog.error(error)

            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                sSelf.pageFetchingDelegate?.handle(results: nil, pagination: nil, error: error)
            }
        } else if let results = paginatedResponse.results, let skipCount = paginatedResponse.responsePagination?.skipCount {
            self.hasMoreItems = (Int64(results.count) + skipCount) == paginatedResponse.responsePagination?.totalItems ? false : true

            if paginatedResponse.requestPagination != nil && hasMoreItems {
                incrementPage(for: paginatedResponse.requestPagination)
            }

            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                sSelf.pageFetchingDelegate?.handle(results: results, pagination: paginatedResponse.responsePagination, error: nil)
            }
        }
        pageFetchingGroup.leave()
    }

    // MARK: - Private interface

    private final func incrementPage(for paginationRequest: RequestPagination?) {
        if let pageSkipCount = paginationRequest?.skipCount {
            currentPage = pageSkipCount / kListPageSize + 1
        }
    }
}
