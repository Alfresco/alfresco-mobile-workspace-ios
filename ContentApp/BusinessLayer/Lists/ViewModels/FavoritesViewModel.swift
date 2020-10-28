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
import UIKit
import AlfrescoAuth
import AlfrescoContent

class FavoritesViewModel: PageFetchingViewModel, ListViewModelProtocol {
    var listRequest: SearchRequest?
    var accountService: AccountService?

    var listCondition: String = kWhereFavoritesFileFolderCondition

    // MARK: - Init

    required init(with accountService: AccountService?, listRequest: SearchRequest?) {
        self.accountService = accountService
        self.listRequest = listRequest
    }

    // MARK: - Public interface

    func favoritesList(with paginationRequest: RequestPagination?) {
        pageFetchingGroup.enter()

        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            FavoritesAPI.listFavorites(personId: kAPIPathMe,
                                       skipCount: paginationRequest?.skipCount,
                                       maxItems: kListPageSize,
                                       orderBy: nil,
                                       _where: sSelf.listCondition,
                                       include: ["path"],
                                       fields: nil) { [weak self] (result, error) in
                                        guard let sSelf = self else { return }

                                        var listNodes: [ListNode]?
                                        if let entries = result?.list {
                                            listNodes = FavoritesNodeMapper.map(entries.entries)
                                        } else {
                                            if let error = error {
                                                AlfrescoLog.error(error)
                                            }
                                        }

                                        let paginatedResponse = PaginatedResponse(results: listNodes,
                                                                                  error: error,
                                                                                  requestPagination: paginationRequest,
                                                                                  responsePagination: result?.list.pagination)

                                        sSelf.handlePaginatedResponse(response: paginatedResponse)
            }
        })
    }

    // MARK: - ListViewModelProtocol Methods

    func isEmpty() -> Bool {
        return results.isEmpty
    }

    func numberOfSections() -> Int {
        return (results.count == 0) ? 0 : 1
    }

    func numberOfItems(in section: Int) -> Int {
        return results.count
    }

    func listNode(for indexPath: IndexPath) -> ListNode {
        return results[indexPath.row]
    }

    func titleForSectionHeader(at indexPath: IndexPath) -> String {
        return ""
    }

    func shouldDisplayListLoadingIndicator() -> Bool {
        return self.shouldDisplayNextPageLoadingIndicator
    }

    func refreshList() {
        currentPage = 1
        favoritesList(with: nil)
    }

    func shouldDisplaySections() -> Bool {
        return false
    }

    func shouldDisplaySettingsButton() -> Bool {
        return true
    }

    override func fetchItems(with requestPagination: RequestPagination, userInfo: Any?, completionHandler: @escaping PagedResponseCompletionHandler) {
        favoritesList(with: requestPagination)
    }

    override func handlePage(results: [ListNode]?, pagination: Pagination?, error: Error?) {
        updateResults(results: results, pagination: pagination, error: error)
    }
}

// MARK: - Event bus handling

extension FavoritesViewModel: EventObservable {
    func handle(event: BaseNodeEvent, on queue: EventQueueType) {
        if let publishedEvent = event as? FavouriteEvent {
            let node = publishedEvent.node

            switch publishedEvent.eventType {
            case .addToFavourite:
                if results.contains(node) == false {
                    results.append(node)

                    pageUpdatingDelegate?.didUpdateList(error: nil, pagination: nil)
                }
            case .removeFromFavourites:
                print("")
            }
        }
    }
}
