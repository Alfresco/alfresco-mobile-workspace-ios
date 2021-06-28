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

class FavoritesModel: ListComponentModelProtocol {
    internal var supportedNodeTypes: [NodeType] = []
    private var services: CoordinatorServices
    
    var listCondition: String = APIConstants.QuerryConditions.whereFavoritesFileFolder
    var delegate: ListComponentModelDelegate?
    var rawListNodes: [ListNode] = []

    init(services: CoordinatorServices, listCondition: String) {
        self.services = services
        self.listCondition = listCondition
    }
    
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
        favoritesList(with: requestPagination,
                      completionHandler: completionHandler)
    }

    // MARK: - Private interface

    func favoritesList(with paginationRequest: RequestPagination?,
                       completionHandler: @escaping PagedResponseCompletionHandler) {
        services.accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            FavoritesAPI.listFavorites(personId: APIConstants.me,
                                       skipCount: paginationRequest?.skipCount,
                                       maxItems: APIConstants.pageSize,
                                       orderBy: ["title ASC"],
                                       _where: sSelf.listCondition,
                                       include: [APIConstants.Include.path,
                                                 APIConstants.Include.allowableOperations,
                                                 APIConstants.Include.properties],
                                       fields: nil) { (result, error) in

                                        var listNodes: [ListNode] = []
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

                                        completionHandler(paginatedResponse)
            }
        })
    }
    
}

// MARK: - Event observable

extension FavoritesModel: EventObservable {
    
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
            delegate?.needsDataSourceReload()
        case .removeFromFavourites:
            if let indexOfRemovedFavorite = rawListNodes.firstIndex(where: { listNode in
                listNode.guid == node.guid
            }) {
                rawListNodes.remove(at: indexOfRemovedFavorite)
                delegate?.needsDisplayStateRefresh()
            }
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
