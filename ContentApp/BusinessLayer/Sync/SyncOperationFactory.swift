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
import AlfrescoCore

class SyncOperationFactory {
    let nodeOperations: NodeOperations
    let eventBusService: EventBusService?

    init(nodeOperations: NodeOperations,
         eventBusService: EventBusService?) {
        self.nodeOperations = nodeOperations
        self.eventBusService = eventBusService
    }

    func fileNodeDetailsOperations(nodes: [ListNode]?) -> [AsyncClosureOperation] {
        guard let nodes = nodes else { return [] }
        var detailsOperations: [AsyncClosureOperation] = []

        for node in nodes where node.nodeType == .file {
            let fileNodeOperation = fetchFileNodeDetailsOperation(node: node)
            detailsOperations.append(fileNodeOperation)
        }

        return detailsOperations
    }

    func scheduleFolderNodeDetailsOperations(for nodes: [ListNode]?,
                                             on operationQueue: OperationQueue) {
        guard let nodes = nodes else { return }

        for node in nodes where node.nodeType == .folder {
            fetchChildrenNodeDetailsOperations(of: node,
                                               paginationRequest: nil,
                                               on: operationQueue)
        }
    }

    func deleteMarkedNodesOperation(nodes: [ListNode]?) -> [AsyncClosureOperation] {
        guard let nodes = nodes else { return [] }
        var deleteOperations: [AsyncClosureOperation] = []
        let listNodeDataAccessor = ListNodeDataAccessor()

        for node in nodes {
            let operation = AsyncClosureOperation { completion, _  in
                listNodeDataAccessor.remove(node: node)

                completion()
            }

            deleteOperations.append(operation)
        }

        return deleteOperations
    }

    func downloadMarkedNodesOperation(nodes: [ListNode]?) -> [AsyncClosureOperation] {
        guard let nodes = nodes else { return [] }
        var downloadOperations: [AsyncClosureOperation] = []

        for node in nodes {
            let originalFileDownloadOperation = downloadNodeContentOperation(node: node)
            downloadOperations.append(originalFileDownloadOperation)

            if let renditionDownloadOperation = downloadNodeRenditionOperation(node: node) {
                downloadOperations.append(renditionDownloadOperation)
            }
        }

        return downloadOperations
    }

    // MARK: - Private interface

    private func fetchFileNodeDetailsOperation(node: ListNode) -> AsyncClosureOperation {
        let operation = AsyncClosureOperation { [weak self] completion, operation  in
            guard let sSelf = self else { return }

            let guid = node.guid

            sSelf.nodeOperations.fetchNodeDetails(for: guid) { (result, error) in
                if operation.isCancelled {
                    completion()

                    return
                }

                if let error = error {
                    sSelf.handle(error: error, for: node)
                } else if let entry = result?.entry {
                    let onlineListNode = NodeChildMapper.create(from: entry)

                    sSelf.compareAndUpdate(queriedNode: node, with: onlineListNode)
                }

                completion()
            }
        }

        return operation
    }

    private func fetchChildrenNodeDetailsOperations(of node: ListNode,
                                                    paginationRequest: RequestPagination?,
                                                    on queue: OperationQueue) {
        let operation = AsyncClosureOperation { [weak self] (completion, _) in
            guard let sSelf = self else { return }

            let reqPagination = RequestPagination(maxItems: paginationRequest?.maxItems ?? kMaxCount,
                                                  skipCount: paginationRequest?.skipCount)
            sSelf.nodeOperations.fetchNodeChildren(for: node.guid,
                                                   pagination: reqPagination) { (result, error) in
                guard let sSelf = self else { return }
                let listNodeDataAccessor = ListNodeDataAccessor()

                if let error = error {
                    sSelf.handle(error: error, for: node)
                } else {
                    if let entries = result?.list?.entries {
                        let onlineNodes = NodeChildMapper.map(entries)

                        let querriedNodeChildren = listNodeDataAccessor.querryChildren(for: node)
                        sSelf.compareAndUpdate(queriedNodeChildren: querriedNodeChildren,
                                               with: onlineNodes)

                        for onlineNode in onlineNodes {
                            if onlineNode.nodeType == .folder {
                                listNodeDataAccessor.store(node: onlineNode)

                                sSelf.fetchChildrenNodeDetailsOperations(of: onlineNode,
                                                                         paginationRequest: nil,
                                                                         on: queue)
                            } else if onlineNode.nodeType == .file {
                                let queriedNode = listNodeDataAccessor.query(node: onlineNode)

                                sSelf.compareAndUpdate(queriedNode: queriedNode, with: onlineNode)
                            }
                        }

                        if let pagination = result?.list?.pagination {
                            let skipCount = Int64(onlineNodes.count) + pagination.skipCount
                            if pagination.totalItems ?? 0 != skipCount {
                                let reqPag = RequestPagination(maxItems: kMaxCount,
                                                               skipCount: Int(skipCount))
                                sSelf.fetchChildrenNodeDetailsOperations(of: node,
                                                                         paginationRequest: reqPag,
                                                                         on: queue)
                            }
                        }

                        completion()
                    }
                }
            }
        }

        queue.addOperation(operation)
    }

    private func downloadNodeContentOperation(node: ListNode) -> AsyncClosureOperation {
        let operation = AsyncClosureOperation { [weak self] completion, operation  in
            guard let sSelf = self else { return }

            let listNodeDataAccessor = ListNodeDataAccessor()

            if let downloadURL = listNodeDataAccessor.fileLocalPath(for: node) {
                let parentDirectoryURL = downloadURL.deletingLastPathComponent()
                _ = DiskService.create(directoryPath: parentDirectoryURL.path)

                sSelf.nodeOperations.sessionForCurrentAccount { _ in
                    _ = sSelf.nodeOperations.downloadContent(for: node,
                                                             to: downloadURL) { (url, _) in
                        if operation.isCancelled {
                            _ = DiskService.delete(itemAtPath: downloadURL.path)
                            completion()

                            return
                        }

                        if url != nil {
                            node.syncStatus = .synced
                            node.markedFor = .undefined
                        } else {
                            node.syncStatus = .error
                        }

                        sSelf.publishSyncStatusEvent(for: node)
                        listNodeDataAccessor.store(node: node)

                        completion()
                    }
                }
            }
        }

        return operation
    }

    private func downloadNodeRenditionOperation(node: ListNode) -> AsyncClosureOperation? {
        let filePreviewType = FilePreview.preview(mimetype: node.mimeType)
        if filePreviewType == .rendition {
            let renditionDownloadOperation = AsyncClosureOperation { [weak self] completion, operation  in
                guard let sSelf = self else { return }

                sSelf.nodeOperations.sessionForCurrentAccount { _ in
                    sSelf.nodeOperations.fetchRenditionURL(for: node.guid, completionHandler: { (renditionURL, isImageRendition) in
                        if let url = renditionURL {
                            let listNodeDataAccessor = ListNodeDataAccessor()

                            if let downloadURL = listNodeDataAccessor.renditionLocalPath(for: node, isImageRendition: isImageRendition) {
                                let parentDirectoryURL = downloadURL.deletingLastPathComponent()
                                _ = DiskService.create(directoryPath: parentDirectoryURL.path)

                                _ = sSelf.nodeOperations.downloadContent(from: url, to: downloadURL, completionHandler: { (_, error) in
                                    if operation.isCancelled {
                                        _ = DiskService.delete(itemAtPath: downloadURL.path)
                                        completion()

                                        return
                                    }

                                    if error != nil {
                                        AlfrescoLog.error("Unexpected sync process error while fetching the rendition for node: \(node.guid) . Reason: \(String(describing: error))")
                                    }

                                    completion()
                                })
                            }
                        } else {
                            completion()
                        }
                    })
                }
            }

            return renditionDownloadOperation
        }

        return nil
    }

    private func handle(error: Error, for node: ListNode) {
        if error.code == StatusCodes.code404NotFound.rawValue {
            node.markedFor = .removal
            let listNodeDataAccessor = ListNodeDataAccessor()
            listNodeDataAccessor.store(node: node)
        } else {
            AlfrescoLog.error("Unexpected sync process error: \(error)")
        }
    }

    private func compareAndUpdate(queriedNode: ListNode?, with onlineNode: ListNode) {
        let listNodeDataAccessor = ListNodeDataAccessor()

        if onlineNode.modifiedAt != queriedNode?.modifiedAt ||
            !listNodeDataAccessor.isContentDownloaded(for: onlineNode) {
            onlineNode.syncStatus = .inProgress
            onlineNode.markedFor = .download
        } else {
            onlineNode.syncStatus = .synced
        }

        onlineNode.markedAsOffline = queriedNode?.markedAsOffline
        publishSyncStatusEvent(for: onlineNode)
        listNodeDataAccessor.store(node: onlineNode)
    }

    private func compareAndUpdate(queriedNodeChildren: [ListNode]?,
                                  with onlineNodeChildren: [ListNode]) {
        guard let queriedNodes = queriedNodeChildren else { return }
        var queriedSet = Set(queriedNodes)

        queriedSet.subtract(Set(onlineNodeChildren))

        for node in queriedSet {
            node.markedFor = .removal

            let listNodeDataAccessor = ListNodeDataAccessor()
            listNodeDataAccessor.store(node: node)
        }
    }

    // MARK: - Event bus

    private func publishSyncStatusEvent(for listNode: ListNode) {
        let syncStatusEvent = SyncStatusEvent(node: listNode)
        eventBusService?.publish(event: syncStatusEvent, on: .mainQueue)
    }
}
