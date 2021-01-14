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

protocol SyncServiceProtocol {
    ///
    ///  Starts a sync operation for a list of nodes.
    ///  - Sync starts with fetching all metadata for top nodes that are marked for offline. If a node is changed, the DB metadata will
    ///  be updated
    ///  - If the enumerated node is a file, then it is added to the download queue
    ///  - If the enumerated node is a folder, list all the children and step back to the previous step
    ///  - When new item is added, it will also be added in the DB
    ///  - If an item is removed, it will be first removed from DB and then the disk.
    ///  - Database operations for updating metadata are synchronous operations whilst physical operations like removing and
    ///  downloading files are to be always enqueued
    /// - Parameter nodeList: Nodes to be synced
    func sync(nodeList: [ListNode])
}

protocol SyncServiceDelegate: class {

}

class SyncService: Service, SyncServiceProtocol {
    let syncOperationQueue: OperationQueue
    let syncOperationFactory: SyncOperationFactory

    // MARK: - Public interface

    init(accountService: AccountService?) {
        syncOperationQueue = OperationQueue()
        syncOperationQueue.maxConcurrentOperationCount = 1

        let nodeOperations = NodeOperations(accountService: accountService)
        syncOperationFactory = SyncOperationFactory(nodeOperations: nodeOperations)
    }

    func sync(nodeList: [ListNode]) {
        let processMarkedNodesOperation = BlockOperation { [weak self] in
            guard let sSelf = self else { return }
            sSelf.processMarkedNodes()
        }
        // Fetch details for existing nodes and decide whether they should be marked for download
        for node in nodeList where node.nodeType == .file {
            let nodeDetailsOperation = syncOperationFactory.nodeDetailsOperation(node: node)
            syncOperationQueue.addOperation(nodeDetailsOperation)
        }

        syncOperationQueue.addOperation(processMarkedNodesOperation)
    }

    // MARK: - Private interface

    private func processMarkedNodes() {
        // Generate download operations for marked nodes
        let dataAccessor = ListNodeDataAccessor()
        let nodesToBeDownloaded = dataAccessor.queryMarkedForDownload()
        let downloadOperations = syncOperationFactory.downloadMarkedNodesOperation(nodes: nodesToBeDownloaded)

        syncOperationQueue.addOperations(downloadOperations,
                                         waitUntilFinished: false)
    }
}
