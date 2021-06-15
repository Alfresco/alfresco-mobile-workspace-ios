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

class FolderDrillModel: ListModelProtocol {
    private var services: CoordinatorServices
    private let nodeOperations: NodeOperations
    private let uploadTransferDataAccessor = UploadTransferDataAccessor()
    internal var supportedNodeTypes: [NodeType] = []

    var listNode: ListNode?
    var rawListNodes: [ListNode] = []
    weak var delegate: ListModelDelegate?

    init(listNode: ListNode?, services: CoordinatorServices) {
        self.services = services
        self.listNode = listNode
        self.nodeOperations = NodeOperations(accountService: services.accountService)
    }

    func isEmpty() -> Bool {
        rawListNodes.isEmpty
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
        let relativePath = (listNode?.nodeType == .site) ? APIConstants.Path.relativeSites : nil
        let reqPagination = RequestPagination(maxItems: requestPagination.maxItems,
                                              skipCount: requestPagination.skipCount)
        updateNodeDetailsIfNecessary { [weak self] (_) in
            guard let sSelf = self else { return }
            let parentGuid = sSelf.listNode?.guid ?? APIConstants.my

            sSelf.nodeOperations.fetchNodeChildren(for: parentGuid,
                                                   pagination: reqPagination,
                                                   relativePath: relativePath) { (result, error) in
                guard let sSelf = self else { return }

                var listNodes: [ListNode] = []
                if let entries = result?.list?.entries {
                    listNodes = NodeChildMapper.map(entries)
                } else {
                    if let error = error {
                        AlfrescoLog.error(error)
                    }
                }

                // Insert nodes to be uploaded
                let responsePagination = result?.list?.pagination
                let uploadTransfers = sSelf.uploadTransferDataAccessor.queryAll(for: parentGuid) { uploadTransfers in
                    guard let sSelf = self else { return }
                    sSelf.insert(uploadTransfers: uploadTransfers,
                                 totalItems: responsePagination?.totalItems ?? 0)
                }
                sSelf.insert(uploadTransfers: uploadTransfers,
                             totalItems: responsePagination?.totalItems ?? 0)
                let paginatedResponse = PaginatedResponse(results: listNodes,
                                                          error: error,
                                                          requestPagination: requestPagination,
                                                          responsePagination: responsePagination)
                completionHandler(paginatedResponse)
            }
        }
    }

    func syncStatusForNode(at indexPath: IndexPath) -> ListEntrySyncStatus {
        let node = listNode(for: indexPath)
        if node.isAFileType() && node.markedFor == .upload {
            let nodeSyncStatus = node.syncStatus
            var entryListStatus: ListEntrySyncStatus

            switch nodeSyncStatus {
            case .pending:
                entryListStatus = .pending
            case .error:
                entryListStatus = .error
            case .inProgress:
                entryListStatus = .inProgress
            case .synced:
                entryListStatus = .uploaded
            default:
                entryListStatus = .undefined
            }

            return entryListStatus
        }

        return node.isMarkedOffline() ? .markedForOffline : .undefined
    }

    // MARK: - Private interface

    private func updateNodeDetailsIfNecessary(handle: @escaping (Error?) -> Void) {
        guard let listNode = self.listNode else {
            handle(nil)
            return
        }
        if listNode.nodeType == .folderLink {
            updateDetails(for: listNode, handle: handle)
            return
        }
        if listNode.nodeType == .site || listNode.shouldUpdate() == false {
            handle(nil)
            return
        }
        updateDetails(for: listNode, handle: handle)
    }

    private func updateDetails(for listNode: ListNode, handle: @escaping (Error?) -> Void) {
        var guid = listNode.guid
        if listNode.nodeType == .folderLink {
            guid = listNode.destination ?? listNode.guid
        }

        nodeOperations.fetchNodeDetails(for: guid) { [weak self] (result, error) in
            guard let sSelf = self else { return }

            if let error = error {
                AlfrescoLog.error(error)
            } else if let entry = result?.entry {
                sSelf.listNode = NodeChildMapper.create(from: entry)
            }
            handle(error)
        }
    }

    private func insert(uploadTransfers: [UploadTransfer], totalItems: Int64) {
        _ = uploadTransfers.map { transfer in
            let listNode = transfer.listNode()
            if !rawListNodes.contains(listNode) {

                var insertionIndex = 0

                for (index, node) in rawListNodes.enumerated() {
                    if node.isFolder {
                        insertionIndex = index + 1
                    } else {
                        if node.title.localizedCompare(listNode.title) == .orderedAscending {
                            insertionIndex = index + 1
                        } else if node.title.localizedCompare(listNode.title) == .orderedSame {
                            insertionIndex = index + 1
                            break
                        } else {
                            insertionIndex = index
                            break
                        }
                    }
                }

                if rawListNodes.isEmpty {
                    rawListNodes.insert(listNode, at: 0)
                } else if insertionIndex < rawListNodes.count {
                    rawListNodes.insert(listNode, at: insertionIndex)
                } else if insertionIndex >= totalItems ||
                            rawListNodes.count + 1 == totalItems {
                    rawListNodes.insert(listNode, at: rawListNodes.count)
                }
            }
        }
    }
}

// MARK: Event observable

extension FolderDrillModel: EventObservable {
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
        let node = event.node
        for listNode in rawListNodes where listNode.guid == node.guid {
            listNode.favorite = node.favorite
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
        case .created:
            if (listNode == nil && node.guid == APIConstants.my) || listNode?.guid == node.guid {
                delegate?.needsDataSourceReload()
            }
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

    private func handleSyncStatus(event: SyncStatusEvent) {
        let eventNode = event.node
        guard eventNode.markedFor == .upload else { return }
        for (index, listNode) in rawListNodes.enumerated() where listNode.id == eventNode.id {
            rawListNodes[index] = eventNode
            delegate?.needsDisplayStateRefresh()
            return
        }
    }
}

