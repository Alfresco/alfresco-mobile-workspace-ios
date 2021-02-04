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

class OfflineFolderDrillViewModel: PageFetchingViewModel, ListViewModelProtocol {
    var supportedNodeTypes: [NodeType]?
    var parentListNode: ListNode?

    // MARK: - Init

    required init(with coordinatorServices: CoordinatorServices?, listRequest: SearchRequest?) {
        super.init()
        refreshList()
    }

    // MARK: - PageFetchingViewModel

    override func fetchItems(with requestPagination: RequestPagination,
                             userInfo: Any?,
                             completionHandler: @escaping PagedResponseCompletionHandler) {
        refreshList()
    }

    override func handlePage(results: [ListNode]?, pagination: Pagination?, error: Error?) {
        updateResults(results: results, pagination: pagination, error: error)
    }

    override func updatedResults(results: [ListNode], pagination: Pagination) {
        pageUpdatingDelegate?.didUpdateList(error: nil,
                                            pagination: pagination)
    }
}

// MARK: - ListViewModelProtocol

extension OfflineFolderDrillViewModel: ListComponentDataSourceProtocol {
    func isEmpty() -> Bool {
        return results.isEmpty
    }

    func emptyList() -> EmptyListProtocol {
        return EmptyFolder()
    }

    func numberOfSections() -> Int {
        return (results.count == 0) ? 0 : 1
    }

    func numberOfItems(in section: Int) -> Int {
        return results.count
    }

    func refreshList() {
        let listNodeDataAccessor = ListNodeDataAccessor()
        if let offlineNodes = listNodeDataAccessor.querryChildren(for: parentListNode) {
            results = offlineNodes
        }

        handlePage(results: results,
                   pagination: nil,
                   error: nil)
    }

    func listNode(for indexPath: IndexPath) -> ListNode {
        return results[indexPath.row]
    }

    func shouldDisplayNodePath() -> Bool {
        return false
    }

    func shouldPreview(node: ListNode) -> Bool {
        let listNodeDataAccessor = ListNodeDataAccessor()

        if node.nodeType == .folder {
            return true
        }

        if listNodeDataAccessor.isContentDownloaded(for: node) {
            return true
        }

        return false
    }

    func performListAction() {
        // Do nothing
    }

    func syncStatus(for node: ListNode) -> ListEntrySyncStatus {
        if node.nodeType == .file {
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
                entryListStatus = .synced
            default:
                entryListStatus = .undefined
            }

            return entryListStatus
        }

        return .undefined
    }
}

// MARK: Event observable

extension OfflineFolderDrillViewModel: EventObservable {
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
        for listNode in results where listNode == eventNode {
            listNode.favorite = eventNode.favorite
        }
    }

    private func handleMove(event: MoveEvent) {
        let eventNode = event.node
        switch event.eventType {
        case .moveToTrash:
            if eventNode.nodeType == .file {
                if let indexOfMovedNode = results.firstIndex(of: eventNode) {
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
        let eventNode = event.node
        if let indexOfNode = results.firstIndex(of: eventNode) {
            results[indexOfNode] = eventNode
        }
    }

    private func handleSyncStatus(event: SyncStatusEvent) {
        let eventNode = event.node
        if let indexOfNode = results.firstIndex(of: eventNode) {
            let copyNode = results[indexOfNode]
            copyNode.syncStatus = eventNode.syncStatus
            results[indexOfNode] = copyNode
        }
    }
}
