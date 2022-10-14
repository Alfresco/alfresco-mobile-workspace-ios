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
import ObjectBox

class UploadTransferDataAccessor: DataAccessor {
    var allTransfersQueryObserver: Observer?

    // MARK: - Database operations

    func store(uploadTransfer: UploadTransfer) {
        var uploadTransferToBeStored = uploadTransfer

        if uploadTransfer.id == 0 {
            if let queriedTransfer = query(uploadTransfer: uploadTransfer) {
                queriedTransfer.update(with: uploadTransfer)
                uploadTransferToBeStored = queriedTransfer
            }
        }

        databaseService?.store(entity: uploadTransferToBeStored)
    }

    func store(uploadTransfers: [UploadTransfer]) {
        databaseService?.store(entities: uploadTransfers)
    }

    func remove(transfer: UploadTransfer) {
        var transferToBeDeleted = transfer
        if let queriedTransfer = query(uploadTransfer: transfer) {
            transferToBeDeleted = queriedTransfer
        }
        
        databaseService?.remove(entity: transferToBeDeleted)
        if let uploadURL = uploadLocalPath(for: transfer) {
            _ = DiskService.delete(itemAtPath: uploadURL.path)
        }
    }

    func query(uploadTransfer: UploadTransfer) -> UploadTransfer? {
        if let transfersBox = databaseService?.box(entity: UploadTransfer.self) {
            do {
                let query: Query<UploadTransfer> = try transfersBox.query {
                    UploadTransfer.localFilenamePath == uploadTransfer.localFilenamePath
                }.build()
                let uploadTransfer = try query.findUnique()
                return uploadTransfer
            } catch {
                AlfrescoLog.error("Unable to retrieve transfer information.")
            }
        }
        return nil
    }
    
    func uploadLocalPath(for transfer: UploadTransfer) -> URL? {
        guard let accountIdentifier = nodeOperations.accountService?.activeAccount?.identifier else { return nil }
        let uploadFilePath = DiskService.uploadFolderPath(for: accountIdentifier)
        var localURL = URL(fileURLWithPath: uploadFilePath)
        localURL.appendPathComponent(transfer.localFilenamePath)

        return localURL
    }

    func isUploadContentLocal(for transfer: UploadTransfer) -> Bool {
        if let uploadURLPath = uploadLocalPath(for: transfer)?.path {
            let fileManager = FileManager.default
            return fileManager.fileExists(atPath: uploadURLPath)
        }
        return false
    }

    func queryAll(isTaskAttachments: Bool = false) -> [UploadTransfer] {
        guard let transfersBox = databaseService?.box(entity: UploadTransfer.self) else { return [] }
        
        do {
            let query: Query<UploadTransfer> = try transfersBox.query {
                UploadTransfer.syncStatus != SyncStatus.synced.rawValue && UploadTransfer.syncStatus != SyncStatus.inProgress.rawValue &&
                UploadTransfer.isTaskAttachment == isTaskAttachments
            }.build()
            return try query.find()
        } catch {
            AlfrescoLog.error("Unable to retrieve transfer information.")
        }
        return []
    }
    
    func queryAll(for parentNodeId: String,
                  isTaskAttachment: Bool = false,
                  changeHandler: @escaping ([UploadTransfer]) -> Void) -> [UploadTransfer] {

        guard let transfersBox = databaseService?.box(entity: UploadTransfer.self) else { return [] }
        
        do {
            let query: Query<UploadTransfer> = try transfersBox.query {
                UploadTransfer.parentNodeId == parentNodeId && UploadTransfer.syncStatus != SyncStatus.synced.rawValue && UploadTransfer.isTaskAttachment == isTaskAttachment
            }.build()
            allTransfersQueryObserver = query.subscribe(resultHandler: { transfers, _ in
                changeHandler(transfers)
            })
            return try query.find()
        } catch {
            AlfrescoLog.error("Unable to retrieve transfer information.")
        }
        return []
    }

    func syncStatus(for uploadTransfer: UploadTransfer) -> SyncStatus {
        guard let uploadTransfer = query(uploadTransfer: uploadTransfer) else { return .undefined }
        return uploadTransfer.syncStatus
    }
    
    // MARK: - Query all for uploaded nodes
    func queryAllForUploadedNodes() -> [UploadTransfer] {
        guard let transfersBox = databaseService?.box(entity: UploadTransfer.self) else { return [] }
        
        do {
            let query: Query<UploadTransfer> = try transfersBox.query {
                UploadTransfer.syncStatus == SyncStatus.synced.rawValue
            }.build()
            return try query.find()
        } catch {
            AlfrescoLog.error("Unable to retrieve transfer information.")
        }
        return []
    }
    
    func updateNode(node: UploadTransfer) {
        databaseService?.store(entity: node)
    }
    
    func removeNode(node: UploadTransfer) {
        databaseService?.remove(entity: node)
    }
}
