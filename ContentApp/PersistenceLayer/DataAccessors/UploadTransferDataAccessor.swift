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

    func remove(transfer: UploadTransfer) {
        var transferToBeDeleted = transfer

        if transfer.id == 0 {
            if let queriedTransfer = query(uploadTransfer: transfer) {
                transferToBeDeleted = queriedTransfer
            }
        }

        databaseService?.remove(entity: transferToBeDeleted)
        _ = DiskService.delete(itemAtPath: transfer.filePath)
    }

    func query(uploadTransfer: UploadTransfer) -> UploadTransfer? {
        if let listBox = databaseService?.box(entity: UploadTransfer.self) {
            do {
                let querry: Query<UploadTransfer> = try listBox.query {
                    UploadTransfer.filePath == uploadTransfer.filePath
                }.build()
                let uploadTransfer = try querry.findUnique()
                return uploadTransfer
            } catch {
                AlfrescoLog.error("Unable to retrieve transfer information.")
            }
        }
        return nil
    }

    func queryAll() -> [UploadTransfer] {
        databaseService?.queryAll(entity: UploadTransfer.self) ?? []
    }

    func syncStatus(for uploadTransfer: UploadTransfer) -> SyncStatus {
        guard let uploadTransfer = query(uploadTransfer: uploadTransfer) else { return .undefined }
        return uploadTransfer.syncStatus
    }
}
