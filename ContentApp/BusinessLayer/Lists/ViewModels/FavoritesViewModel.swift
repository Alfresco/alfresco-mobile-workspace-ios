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
    var supportedNodeTypes: [NodeType]?

    // MARK: - ListViewModelProtocol

    required init(with accountService: AccountService?, listRequest: SearchRequest?) {
        self.accountService = accountService
        self.listRequest = listRequest
    }

    func isEmpty() -> Bool {
        return results.isEmpty
    }

    func emptyList() -> EmptyListProtocol {
        if listCondition == kWhereFavoritesFileFolderCondition {
            return EmptyFavoritesFilesFolders()
        }
        return EmptyFavoritesLibraries()
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

    func shouldDisplayMoreButton() -> Bool {
        return true
    }

    func shouldDisplayCreateButton() -> Bool {
        return false
    }

    func shouldDisplayNodePath() -> Bool {
        return true
    }

    func shouldPreview(node: ListNode) -> Bool {
        return true
    }

    func performListAction() {
        // Do nothing
    }

    // MARK: - PageFetchingViewModel

    override func fetchItems(with requestPagination: RequestPagination,
                             userInfo: Any?,
                             completionHandler: @escaping PagedResponseCompletionHandler) {
        favoritesList(with: requestPagination)
    }

    override func handlePage(results: [ListNode]?,
                             pagination: Pagination?,
                             error: Error?) {
        updateResults(results: results,
                      pagination: pagination,
                      error: error)
    }

    override func updatedResults(results: [ListNode], pagination: Pagination) {
        pageUpdatingDelegate?.didUpdateList(error: nil,
                                            pagination: pagination)
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
                                       orderBy: ["title ASC"],
                                       _where: sSelf.listCondition,
                                       include: [kAPIIncludePathNode,
                                                 kAPIIncludeAllowableOperationsNode,
                                                 kAPIIncludeProperties],
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

                                        let paginatedResponse =
                                            PaginatedResponse(results: listNodes,
                                                              error: error,
                                                              requestPagination: paginationRequest,
                                                              responsePagination: result?.list.pagination)

                                        sSelf.handlePaginatedResponse(response: paginatedResponse)
            }
        })
    }
}

// MARK: - Event observable

extension FavoritesViewModel: EventObservable {
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
        switch event.eventType {
        case .addToFavourite:
            refreshList()
        case .removeFromFavourites:
            if let indexOfRemovedFavorite = results.firstIndex(of: node) {
                results.remove(at: indexOfRemovedFavorite)
            }
        }
    }

    private func handleMove(event: MoveEvent) {
        let node = event.node
        switch event.eventType {
        case .moveToTrash:
            if node.nodeType == .file {
                if let indexOfMovedNode = results.firstIndex(of: node) {
                    results.remove(at: indexOfMovedNode)
                }
            } else {
                refreshList()
            }
        case .restore:
            refreshList()
        default: break
        }
    }

    private func handleOffline(event: OfflineEvent) {
        let node = event.node
        if let indexOfOfflineNode = results.firstIndex(of: node) {
            let listNode = results[indexOfOfflineNode]
            listNode .markedAsOffline = node.markedAsOffline
            results[indexOfOfflineNode] = listNode
        }
    }
}
