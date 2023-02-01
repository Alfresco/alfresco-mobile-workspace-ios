//
// Copyright (C) 2005-2022 Alfresco Software Limited.
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

import UIKit
import AlfrescoContent

class UploadNodesModel: ListComponentModelProtocol {
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
        rawListNodes
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
    }
    
    func syncStatusForNode(at indexPath: IndexPath, and shouldEnableListButton: Bool) -> ListEntrySyncStatus {
        if let node = listNode(for: indexPath) {
            if node.isAFileType() {
                var entryListStatus: ListEntrySyncStatus
                if shouldEnableListButton {
                    entryListStatus = .pending
                } else {
                    entryListStatus = .inProgress
                }
                return entryListStatus
            }
        }
        return .undefined
    }
}

// MARK: Event Observable

extension UploadNodesModel: EventObservable {
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
        case .restore, .moveToFolder, .updated:
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
            let copyNode = rawListNodes[indexOfNode]
            copyNode.syncStatus = eventNode.syncStatus
            rawListNodes[indexOfNode] = copyNode
            delegate?.needsDataSourceReload()
        }
    }
}

// MARK: - Offline search
extension UploadNodesModel {
    func fetchOfflineItems(completionHandler: @escaping PagedResponseCompletionHandler) {
    }
}
