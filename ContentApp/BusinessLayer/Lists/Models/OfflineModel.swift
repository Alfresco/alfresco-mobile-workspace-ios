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

class OfflineModel: ListComponentModelProtocol {
    private var services: CoordinatorServices
    internal var supportedNodeTypes: [NodeType] = []

    var delegate: ListComponentModelDelegate?
    var rawListNodes: [ListNode] = []

    init(services: CoordinatorServices) {
        self.services = services
    }

    func isEmpty() -> Bool {
        return rawListNodes.isEmpty
    }

    func isChildFolder() -> Bool {
        return false
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
        let offlineNodes = offlineMarkedNodes()
        let pagination = Pagination(count: Int64(offlineNodes.count),
                                    hasMoreItems: offlineNodes.isEmpty ? false : true,
                                    totalItems: Int64(offlineNodes.count),
                                    skipCount: 0,
                                    maxItems: 0)
        let paginatedResponse = PaginatedResponse(results: offlineMarkedNodes(),
                                                  error: nil,
                                                  requestPagination: requestPagination,
                                                  responsePagination: pagination)
        completionHandler(paginatedResponse)
    }

    func syncStatusForNode(at indexPath: IndexPath) -> ListEntrySyncStatus {
        if let node = listNode(for: indexPath) {
            if node.isAFileType() {
                let nodeSyncStatus = node.hasSyncStatus()
                var entryListStatus: ListEntrySyncStatus

                switch nodeSyncStatus {
                case .pending:
                    entryListStatus = .pending
                case .error:
                    entryListStatus = .error
                case .inProgress:
                    entryListStatus = .inProgress
                case .synced:
                    entryListStatus = .downloaded
                default:
                    entryListStatus = .undefined
                }

                return entryListStatus
            }
        }

        return .undefined
    }

    // MARK: - Private interface

    func offlineMarkedNodes() -> [ListNode] {
        let listNodeDataAccessor = ListNodeDataAccessor()
        return listNodeDataAccessor.queryMarkedOffline()
    }
}

// MARK: - Event observable

extension OfflineModel: EventObservable {
    func handle(event: BaseNodeEvent, on queue: EventQueueType) {
        if let publishedEvent = event as? FavouriteEvent {
            handleFavorite(event: publishedEvent)
        } else if let publishedEvent = event as? MoveEvent {
            handleMove(event: publishedEvent)
        } else if let publishedEvent = event as? OfflineEvent {
            handleOffline(event: publishedEvent)
        } else if let publishedEvent = event as? SyncStatusEvent {
            handleSyncStatus(event: publishedEvent)
        }
    }

    private func handleFavorite(event: FavouriteEvent) {
        let eventNode = event.node
        for listNode in rawListNodes where listNode.guid == eventNode.guid {
            listNode.favorite = eventNode.favorite
        }
    }

    private func handleMove(event: MoveEvent) {
        let eventNode = event.node
        switch event.eventType {
        case .moveToTrash:
            if eventNode.nodeType == .file {
                if let indexOfMovedNode = rawListNodes.firstIndex(where: { listNode in
                    listNode.guid == eventNode.guid
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
        let eventNode = event.node
        switch event.eventType {
        case .removed:
            if let indexOfNode = rawListNodes.firstIndex(where: { listNode in
                listNode.guid == eventNode.guid
            }) {
                rawListNodes.remove(at: indexOfNode)
            }
        default: break
        }

        delegate?.needsDataSourceReload()
    }

    private func handleSyncStatus(event: SyncStatusEvent) {
        let eventNode = event.node
        if let indexOfNode = rawListNodes.firstIndex(where: { listNode in
            listNode.guid == eventNode.guid
        }) {
            rawListNodes[indexOfNode] = eventNode
            delegate?.needsDataSourceReload()
        }
    }
}

