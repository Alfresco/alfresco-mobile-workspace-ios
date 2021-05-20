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

protocol SyncServiceDelegate: AnyObject {
    func syncDidStarted()
    func syncDidFinished()
}

@objc enum SyncServiceStatus: Int {
    case idle
    case fetchingNodeDetails
    case processNodeDetails
    case processingMarkedNodes
    case uploadPendingNodes
}

let maxConcurrentSyncOperationCount = 3

@objc class SyncService: NSObject, Service, SyncServiceProtocol {
    var syncError: Error?

    @objc dynamic var syncServiceStatus: SyncServiceStatus = .idle
    weak var delegate: SyncServiceDelegate?

    private let syncOperationQueue: OperationQueue
    private let syncOperationFactory: SyncOperationFactory
    private let eventBusService: EventBusService?
    private var kvoToken: NSKeyValueObservation?
    private var nodeList: [ListNode] = []

    deinit {
        kvoToken?.invalidate()
    }

    // MARK: - Public interface

    init(accountService: AccountService?,
         eventBusService: EventBusService?) {

        self.eventBusService = eventBusService
        syncOperationQueue = OperationQueue()
        syncOperationQueue.maxConcurrentOperationCount = maxConcurrentSyncOperationCount

        let nodeOperations = NodeOperations(accountService: accountService)
        syncOperationFactory = SyncOperationFactory(nodeOperations: nodeOperations,
                                                    eventBusService: eventBusService)
        super.init()

        observeOperationQueue()
        syncOperationFactory.delegate = self
    }

    func sync(nodeList: [ListNode]) {
        guard syncServiceStatus == .idle else { return }

        syncOperationFactory.syncIsCancelled = false
        OperationQueueService.worker.async { [weak self] in
            guard let sSelf = self else { return }

            // Fetch details for existing nodes and decide whether they should be marked for download
            sSelf.delegate?.syncDidStarted()
            sSelf.processPendingUploads()
            sSelf.nodeList = nodeList
        }
    }

    func stopSync() {
        syncOperationFactory.syncIsCancelled = true
        syncOperationQueue.cancelAllOperations()

        let dataAccessor = ListNodeDataAccessor()
        let nodesToBeDownloaded = dataAccessor.queryMarkedForDownload()

        for node in nodesToBeDownloaded where node.syncStatus == .pending ||
            node.syncStatus == .inProgress {
            node.syncStatus = .error
            dataAccessor.store(node: node)
        }
    }

    // MARK: - Private interface

    private func processNodeDetails(for nodeList: [ListNode]) {
        syncServiceStatus = .fetchingNodeDetails
        let nodeDetailsOperations = syncOperationFactory.fileNodeDetailsOperations(nodes: nodeList)
        if nodeDetailsOperations.isEmpty {
            processNodeChildren()
        } else {
            syncOperationQueue.addOperations(nodeDetailsOperations,
                                             waitUntilFinished: false)
        }
        syncOperationFactory.scheduleFolderNodeDetailsOperations(for: nodeList,
                                                                 on: syncOperationQueue)
    }

    private func processNodeChildren() {
        syncServiceStatus = .processNodeDetails
        syncOperationQueue.addOperation(syncOperationFactory.processNodeChildren())
    }

    private func processMarkedNodes() {
        // Generate download and delete operations for marked nodes
        syncServiceStatus = .processingMarkedNodes
        let dataAccessor = ListNodeDataAccessor()
        let nodesToBeDownloaded = dataAccessor.queryMarkedForDownload()
        let nodesToBeDeleted = dataAccessor.queryMarkedForDeletion()
        let downloadOperations = syncOperationFactory.downloadMarkedNodesOperation(nodes: nodesToBeDownloaded)
        let deleteOperations = syncOperationFactory.deleteMarkedNodesOperation(nodes: nodesToBeDeleted)

        if downloadOperations.isEmpty &&
            deleteOperations.isEmpty {
            syncServiceStatus = .idle
            delegate?.syncDidFinished()
        } else {
            if !downloadOperations.isEmpty {
                syncOperationQueue.addOperations(downloadOperations,
                                                 waitUntilFinished: false)
            }

            if !deleteOperations.isEmpty {
                syncOperationQueue.addOperations(deleteOperations,
                                                 waitUntilFinished: false)
            }
        }
    }

    private func processPendingUploads() {
        syncServiceStatus = .uploadPendingNodes
        let dataAccessor = UploadTransferDataAccessor()
        let pendingUploadTransfers = dataAccessor.queryAll()
        let uploadOperations = syncOperationFactory.uploadPendingContentOperation(transfers: pendingUploadTransfers)

        if uploadOperations.isEmpty {
            processNodeDetails(for: nodeList)
        } else {
            if !uploadOperations.isEmpty {
                syncOperationQueue.addOperations(uploadOperations,
                                                 waitUntilFinished: false)
            }
        }
    }

    func observeOperationQueue() {
        kvoToken = syncOperationQueue.observe(\.operations, options: .new) { [weak self] (newValue, _) in
            guard let sSelf = self else { return }
            if newValue.operations.isEmpty {
                switch sSelf.syncServiceStatus {
                case .uploadPendingNodes:
                    sSelf.syncServiceStatus = .fetchingNodeDetails
                    sSelf.processNodeDetails(for: sSelf.nodeList)
                case .fetchingNodeDetails:
                    sSelf.processNodeChildren()
                case .processNodeDetails:
                    sSelf.processMarkedNodes()
                case .processingMarkedNodes:
                    sSelf.syncServiceStatus = .idle
                    sSelf.delegate?.syncDidFinished()
                case .idle:
                    AlfrescoLog.debug("-- SYNC is now idle")
                }
            }
        }
    }
}

extension SyncService: SyncOperationFactoryDelegate {
    func didComplete(with error: Error) {
        // Log the last error but don't stop the sync service for now
        AlfrescoLog.error("-- Sync encountered an error: \(error.localizedDescription)")
        syncError = error
    }
}
