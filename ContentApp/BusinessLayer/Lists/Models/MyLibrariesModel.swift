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

class MyLibrariesModel: ListComponentModelProtocol {
    private var services: CoordinatorServices
    internal var supportedNodeTypes: [NodeType] = []

    var rawListNodes: [ListNode] = []
    var delegate: ListComponentModelDelegate?

    init(services: CoordinatorServices) {
        self.services = services
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
        let accountService = services.accountService
        accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            let skipCount = requestPagination.skipCount
            let maxItems = requestPagination.maxItems ?? APIConstants.pageSize
            SitesAPI.listSiteMembershipsForPerson(personId: APIConstants.me,
                                                  skipCount: skipCount,
                                                  maxItems: maxItems,
                                                  orderBy: nil,
                                                  relations: nil,
                                                  fields: nil,
                                                  _where: nil) { (result, error) in
                var listNodes: [ListNode] = []
                if let entries = result?.list.entries {
                    listNodes = SitesNodeMapper.map(entries)
                } else {
                    if let error = error {
                        AlfrescoLog.error(error)
                    }
                }
                let paginatedResponse = PaginatedResponse(results: listNodes,
                                                          error: error,
                                                          requestPagination: requestPagination,
                                                          responsePagination: result?.list.pagination)
                completionHandler(paginatedResponse)
            }
        })
    }
}

// MARK: - Event observable

extension MyLibrariesModel: EventObservable {
    func handle(event: BaseNodeEvent, on queue: EventQueueType) {
        if let publishedEvent = event as? FavouriteEvent {
            handleFavorite(event: publishedEvent)
        } else if let publishedEvent = event as? MoveEvent {
            handleMove(event: publishedEvent)
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
            if let indexOfMovedNode = rawListNodes.firstIndex(where: { listNode in
                listNode.guid == node.guid
            }) {
                rawListNodes.remove(at: indexOfMovedNode)
                delegate?.needsDisplayStateRefresh()
            }
        case .restore, .moveToFolder, .updated:
            delegate?.needsDataSourceReload()
        default: break
        }
    }
}
