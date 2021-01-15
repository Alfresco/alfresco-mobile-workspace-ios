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

    func nodeDetailsOperation(node: ListNode) -> AsyncClosureOperation {
        let operation = AsyncClosureOperation { [weak self] completion in
            guard let sSelf = self else { return }

            let guid = node.guid
            sSelf.nodeOperations.fetchNodeDetails(for: guid) { (result, error) in
                if let error = error {
                    if error.code == StatusCodes.code404NotFound.rawValue {
                        node.markedForDeletion = true
                    } else {
                        AlfrescoLog.error("Unexpected sync process error: \(error)")
                    }
                } else if let entry = result?.entry {
                    let onlineListNode = NodeChildMapper.create(from: entry)
                    onlineListNode.syncStatus = .inProgress
                    sSelf.publishSyncStatusEvent(for: onlineListNode)

                    if onlineListNode.modifiedAt != node.modifiedAt ||
                        node.localPath == nil {
                        onlineListNode.markedForDownload = true
                    }

                    let dataAccessor = ListNodeDataAccessor()
                    dataAccessor.store(node: onlineListNode)
                }

                completion()
            }
        }

        return operation
    }

    func deleteMarkedNodesOperation(nodes: [ListNode]?) -> AsyncClosureOperation {
        let operation = AsyncClosureOperation { completion in

            let dataAccessor = ListNodeDataAccessor()
            let nodesToBeRemoved = dataAccessor.queryMarkedForDeletion()

            completion()
        }

        return operation
    }

    func downloadMarkedNodesOperation(nodes: [ListNode]?) -> [AsyncClosureOperation] {
        guard let nodes = nodes else { return [] }
        guard let accountIdentifier = nodeOperations.accountService?.activeAccount?.identifier else { return [] }
        var downloadOperations: [AsyncClosureOperation] = []

        for node in nodes {
            let operation = AsyncClosureOperation { [weak self] completion in
                guard let sSelf = self else { return }

                let downloadPath = DiskService.documentsDirectoryPath(for: accountIdentifier)
                var downloadURL = URL(fileURLWithPath: downloadPath)
                downloadURL.appendPathComponent(node.title)

                sSelf.nodeOperations.sessionForCurrentAccount { _ in
                    _ = sSelf.nodeOperations.downloadContent(for: node,
                                                             to: downloadURL) { (destinationURL, error) in
                        node.localPath = destinationURL?.absoluteString

                        completion()
                    }
                }
            }

            downloadOperations.append(operation)
        }

        return downloadOperations
    }

    // MARK: - Private Helpers

    private func publishSyncStatusEvent(for listNode: ListNode) {
        let syncStatusEvent = SyncStatusEvent(node: listNode)
        eventBusService?.publish(event: syncStatusEvent, on: .mainQueue)
    }
}
