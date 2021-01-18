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

    func nodeDetailsOperation(nodes: [ListNode]?) -> [AsyncClosureOperation] {
        guard let nodes = nodes else { return [] }
        var detailsOperations: [AsyncClosureOperation] = []

        for node in nodes where node.nodeType == .file {
            let operation = AsyncClosureOperation { [weak self] completion in
                guard let sSelf = self else { return }

                let guid = node.guid
                let dataAccessor = ListNodeDataAccessor()

                sSelf.nodeOperations.fetchNodeDetails(for: guid) { (result, error) in
                    if let error = error {
                        if error.code == StatusCodes.code404NotFound.rawValue {
                            node.markedForDeletion = true
                            dataAccessor.store(node: node)
                        } else {
                            AlfrescoLog.error("Unexpected sync process error: \(error)")
                        }
                    } else if let entry = result?.entry {
                        let onlineListNode = NodeChildMapper.create(from: entry)

                        if onlineListNode.modifiedAt != node.modifiedAt ||
                            node.localPath == nil {
                            onlineListNode.syncStatus = .inProgress
                            onlineListNode.markedForDownload = true
                        } else {
                            onlineListNode.syncStatus = .synced
                        }

                        sSelf.publishSyncStatusEvent(for: onlineListNode)
                        dataAccessor.store(node: onlineListNode)
                    }

                    completion()
                }
            }

            detailsOperations.append(operation)
        }

        return detailsOperations
    }

    func deleteMarkedNodesOperation(nodes: [ListNode]?) -> [AsyncClosureOperation] {
        guard let nodes = nodes else { return [] }
        var deleteOperations: [AsyncClosureOperation] = []

        for node in nodes {
            let operation = AsyncClosureOperation { [weak self] completion in
                guard let sSelf = self else { return }
                if let nodeURL = sSelf.localPath(for: node) {
                    _ = DiskService.delete(itemAtPath: nodeURL.path)
                }

                let dataAccessor = ListNodeDataAccessor()
                dataAccessor.remove(node: node)

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
            let operation = AsyncClosureOperation { [weak self] completion in
                guard let sSelf = self else { return }
                if let downloadURL = sSelf.localPath(for: node) {
                    let parentDirectoryURL = downloadURL.deletingLastPathComponent()
                    _ = DiskService.create(directoryPath: parentDirectoryURL.path)

                    sSelf.nodeOperations.sessionForCurrentAccount { _ in
                        _ = sSelf.nodeOperations.downloadContent(for: node,
                                                                 to: downloadURL) { (destinationURL, error) in
                            if error != nil {
                                node.syncStatus = .error
                            } else {
                                node.localPath = destinationURL?.path
                                node.syncStatus = .synced
                            }

                            sSelf.publishSyncStatusEvent(for: node)

                            let dataAccessor = ListNodeDataAccessor()
                            dataAccessor.store(node: node)

                            completion()
                        }
                    }
                }
            }

            downloadOperations.append(operation)
        }

        return downloadOperations
    }

    private func localPath(for node: ListNode) -> URL? {
        guard let accountIdentifier = nodeOperations.accountService?.activeAccount?.identifier else { return nil }
        let localPath = DiskService.documentsDirectoryPath(for: accountIdentifier)
        var localURL = URL(fileURLWithPath: localPath)
        localURL.appendPathComponent(node.guid)
        localURL.appendPathExtension(URL(fileURLWithPath: node.title).pathExtension)

        return localURL
    }

    // MARK: - Event bus

    private func publishSyncStatusEvent(for listNode: ListNode) {
        let syncStatusEvent = SyncStatusEvent(node: listNode)
        eventBusService?.publish(event: syncStatusEvent, on: .mainQueue)
    }
}
