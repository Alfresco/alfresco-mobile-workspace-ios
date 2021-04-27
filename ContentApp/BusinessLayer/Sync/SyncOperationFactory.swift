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

protocol SyncOperationFactoryDelegate: AnyObject {
    func didComplete(with error: Error)
}

class SyncOperationFactory {
    let nodeOperations: NodeOperations
    let eventBusService: EventBusService?

    var nodesWithChildren: [ListNode: [ListNode]] = [:]

    weak var delegate: SyncOperationFactoryDelegate?
    var syncIsCancelled = false

    init(nodeOperations: NodeOperations,
         eventBusService: EventBusService?) {
        self.nodeOperations = nodeOperations
        self.eventBusService = eventBusService
    }

    func fileNodeDetailsOperations(nodes: [ListNode]) -> [AsyncClosureOperation] {
        guard !nodes.isEmpty else { return [] }
        var detailsOperations: [AsyncClosureOperation] = []

        for node in nodes where node.isAFileType() {
            let fileNodeOperation = fetchFileNodeDetailsOperation(node: node)
            detailsOperations.append(fileNodeOperation)
        }

        return detailsOperations
    }

    func scheduleFolderNodeDetailsOperations(for nodes: [ListNode],
                                             on operationQueue: OperationQueue) {
        for node in nodes where node.isAFolderType() {
            fetchChildrenNodeDetailsOperations(of: node,
                                               paginationRequest: nil,
                                               on: operationQueue)
        }
    }

    func processNodeChildren() -> AsyncClosureOperation {
        let operation = AsyncClosureOperation { [weak self] completion, _  in
            guard let sSelf = self else { return }

            let listNodeDataAccessor = ListNodeDataAccessor()

            _ = sSelf.nodesWithChildren.keys.map({ (node) in
                if let onlineNodes = sSelf.nodesWithChildren[node] {
                    let querriedNodeChildren = listNodeDataAccessor.queryChildren(for: node)
                    sSelf.compareAndUpdate(queriedNodeChildren: querriedNodeChildren,
                                           with: onlineNodes)
                }
            })

            sSelf.nodesWithChildren = [:]

            completion()
        }

        return operation
    }

    func deleteMarkedNodesOperation(nodes: [ListNode]) -> [AsyncClosureOperation] {
        guard !nodes.isEmpty else { return [] }
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

    func downloadMarkedNodesOperation(nodes: [ListNode]) -> [AsyncClosureOperation] {
        guard !nodes.isEmpty else { return [] }
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

    func uploadPendingContentOperation(transfers: [UploadTransfer]) -> [AsyncClosureOperation] {
        guard !transfers.isEmpty else { return [] }
        var uploadOperations: [AsyncClosureOperation] = []

        for transfer in transfers {
            let fileUploadOperation = uploadNodeContentOperation(transfer: transfer)
            uploadOperations.append(fileUploadOperation)
        }

        return uploadOperations
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

                if error != nil {
                    sSelf.handle(error: error, for: node)
                } else if let entry = result?.entry {
                    let onlineListNode = NodeChildMapper.create(from: entry)
                    onlineListNode.removeAllowableOperationUnknown()
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
                let listNodeDataAccessor = ListNodeDataAccessor()

                if let error = error {
                    sSelf.handle(error: error, for: node)
                    sSelf.delegate?.didComplete(with: error)
                } else if let entries = result?.list?.entries {
                    let onlineNodes = NodeChildMapper.map(entries)

                    if sSelf.nodesWithChildren[node] == nil {
                        sSelf.nodesWithChildren[node] = []
                    }
                    sSelf.nodesWithChildren[node]?.append(contentsOf: onlineNodes)

                    for onlineNode in onlineNodes {
                        onlineNode.removeAllowableOperationUnknown()
                        if onlineNode.isAFolderType() {
                            let queriedNode = listNodeDataAccessor.query(node: onlineNode)
                            onlineNode.markedAsOffline = queriedNode?.markedAsOffline ?? false
                            listNodeDataAccessor.store(node: onlineNode)

                            sSelf.fetchChildrenNodeDetailsOperations(of: onlineNode,
                                                                     paginationRequest: nil,
                                                                     on: queue)
                        } else if onlineNode.isAFileType() {
                            let queriedNode = listNodeDataAccessor.query(node: onlineNode)
                            sSelf.compareAndUpdate(queriedNode: queriedNode,
                                                   with: onlineNode)
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
                }

                completion()
            }
        }
        if syncIsCancelled == false {
            queue.addOperation(operation)
        }
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

    private func uploadNodeContentOperation(transfer: UploadTransfer) -> AsyncClosureOperation {
        let operation = AsyncClosureOperation { [weak self] completion, operation in
            guard let sSelf = self else { return }

            let transferDataAccessor = UploadTransferDataAccessor()

            let handleErrorCaseForTransfer = {
                transfer.syncStatus = .error
                transferDataAccessor.store(uploadTransfer: transfer)

                completion()
            }

            sSelf.nodeOperations.sessionForCurrentAccount { _ in
                let fileURL = URL(fileURLWithPath: transfer.filePath)
                do {
                    let fileData = try Data(contentsOf: fileURL)

                    sSelf.nodeOperations.createNode(nodeId: transfer.parentNodeId,
                                                    name: transfer.nodeName,
                                                    description: transfer.nodeDescription,
                                                    nodeExtension: transfer.filePath.fileExtension(),
                                                    fileData: fileData,
                                                    autoRename: true,
                                                    completionHandler: { (entry, error) in
                                                        if operation.isCancelled {
                                                            completion()
                                                        }

                                                        if error == nil, let node = entry {
                                                            transfer.syncStatus = .synced
                                                            sSelf.publishSyncStatusEvent(for: node)
                                                            transferDataAccessor.remove(transfer: transfer)
                                                        } else {
                                                            transfer.syncStatus = .error
                                                            transferDataAccessor.store(uploadTransfer: transfer)
                                                        }

                                                        completion()
                                                    })
                } catch {
                    handleErrorCaseForTransfer()
                }
            }
        }
        return operation
    }

    private func downloadNodeRenditionOperation(node: ListNode) -> AsyncClosureOperation? {
        if FilePreview.preview(mimetype: node.mimeType) == .rendition {
            let renditionDownloadOperation = AsyncClosureOperation { [weak self] completion, operation  in
                guard let sSelf = self else { return }

                sSelf.nodeOperations.sessionForCurrentAccount { _ in
                    sSelf.nodeOperations.fetchRenditionURL(for: node.guid,
                                                           completionHandler: { (renditionURL, isImageRendition) in
                        if let url = renditionURL {
                            let listNodeDataAccessor = ListNodeDataAccessor()

                            if let downloadURL = listNodeDataAccessor.renditionLocalPath(for: node,
                                                                                         isImageRendition: isImageRendition) {
                                let parentDirectoryURL = downloadURL.deletingLastPathComponent()
                                _ = DiskService.create(directoryPath: parentDirectoryURL.path)

                                _ = sSelf.nodeOperations.downloadContent(from: url,
                                                                         to: downloadURL,
                                                                         completionHandler: { (_, error) in
                                    if operation.isCancelled {
                                        _ = DiskService.delete(itemAtPath: downloadURL.path)
                                        completion()

                                        return
                                    }

                                    if error != nil {
                                        sSelf.handle(error: error, for: node)
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

    private func handle(error: Error?, for node: ListNode) {
        let listNodeDataAccessor = ListNodeDataAccessor()
        if error?.code == StatusCodes.code404NotFound.rawValue ||
            error?.code == StatusCodes.code403Forbidden.rawValue {
            node.markedFor = .removal
            node.syncStatus = .undefined
            listNodeDataAccessor.store(node: node)
        } else {
            AlfrescoLog.error("Unexpected sync process error: \(String(describing: error))")
            node.syncStatus = .error
            listNodeDataAccessor.store(node: node)
            publishSyncStatusEvent(for: node)
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

        onlineNode.markedAsOffline = queriedNode?.markedAsOffline ?? false
        publishSyncStatusEvent(for: onlineNode)
        listNodeDataAccessor.store(node: onlineNode)
    }

    private func compareAndUpdate(queriedNodeChildren: [ListNode],
                                  with onlineNodeChildren: [ListNode]) {
        var queriedSet = Set(queriedNodeChildren)
        queriedSet.subtract(Set(onlineNodeChildren))

        for node in queriedSet {
            node.markedFor = .removal
            node.syncStatus = .undefined

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
