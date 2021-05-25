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
import AlfrescoAuth
import AlfrescoContent

class FolderDrillModel: ListModelProtocol {
    private var coordinatorServices: CoordinatorServices
    private let nodeOperations: NodeOperations
    private let uploadTransferDataAccessor = UploadTransferDataAccessor()
    private var results: [ListNode] = []
    internal var supportedNodeTypes: [NodeType] = []

    var listNode: ListNode?
    var rawListNodes: [ListNode] = []
    weak var delegate: ListModelDelegate?

    init(listNode: ListNode?, services: CoordinatorServices) {
        self.coordinatorServices = services
        self.listNode = listNode
        self.nodeOperations = NodeOperations(accountService: coordinatorServices.accountService)
    }

    func isEmpty() -> Bool {
        results.isEmpty
    }

    func numberOfItems(in section: Int) -> Int {
        return results.count
    }

    func listNodes() -> [ListNode] {
        return results
    }

    func listNode(for indexPath: IndexPath) -> ListNode {
        return results[indexPath.row]
    }

    func titleForSectionHeader(at indexPath: IndexPath) -> String {
        return ""
    }

    func shouldDisplaySubtitle(for indexPath: IndexPath) -> Bool {
        return true
    }

    func shouldDisplayMoreButton(for indexPath: IndexPath) -> Bool {
        return true
    }

    func shouldPreviewNode(at indexPath: IndexPath) -> Bool {
        return true
    }

    func fetchItems(with requestPagination: RequestPagination,
                    userInfo: Any?,
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
            if !results.contains(listNode) {

                var insertionIndex = 0

                for (index, node) in results.enumerated() {
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

                if results.isEmpty {
                    results.insert(listNode, at: 0)
                } else if insertionIndex < results.count {
                    results.insert(listNode, at: insertionIndex)
                } else if insertionIndex >= totalItems ||
                            results.count + 1 == totalItems {
                    results.insert(listNode, at: results.count)
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
        for listNode in results where listNode == node {
            listNode.favorite = node.favorite
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

        if let indexOfOfflineNode = results.firstIndex(of: node) {
            results.remove(at: indexOfOfflineNode)
            results.insert(node, at: indexOfOfflineNode)
        }
    }

    private func handleSyncStatus(event: SyncStatusEvent) {
        let eventNode = event.node
        guard eventNode.markedFor == .upload else { return }
        for (index, listNode) in results.enumerated() where listNode.id == eventNode.id {
            results[index] = eventNode
            return
        }
    }
}

