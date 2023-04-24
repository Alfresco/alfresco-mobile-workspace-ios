//
// Copyright (C) 2005-2022 Alfresco Software Limited.
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

import UIKit

class SyncSharedNodes: NSObject {

    // MARK: - Functions for nodes to be upload
    static func store(uploadTransfers: [UploadTransfer]) {
        let userDefaults = UserDefaultsModel.getUserDefault()
        let pending = SyncSharedNodes.getPendingUploads()
        
        if !pending.isEmpty {
            // store from local database
            let uploadTransferAccessor = UploadTransferDataAccessor()
            let nodes = uploadTransferAccessor.queryAll(attachmentType: .content)
            try? userDefaults?.setObjects(nodes, forKey: KeyConstants.AppGroup.pendingUploadNodes)
        } else {
            try? userDefaults?.setObjects(uploadTransfers, forKey: KeyConstants.AppGroup.pendingUploadNodes)
        }
    }
    
    static func getPendingUploads() -> [UploadTransfer] {
        let userDefaults = UserDefaultsModel.getUserDefault()
        let nodes = try? userDefaults?.getObjects(forKey: KeyConstants.AppGroup.pendingUploadNodes, castTo: [UploadTransfer].self) ?? []
        return nodes ?? [UploadTransfer]()
    }
    
    // MARK: - Functions for nodes uploaded
    static func store(uploadedNode: UploadTransfer) {
        let userDefaults = UserDefaultsModel.getUserDefault()
        var uploaded = SyncSharedNodes.getSavedUploadedNodes()
        uploaded.append(uploadedNode)
        try? userDefaults?.setObjects(uploaded, forKey: KeyConstants.AppGroup.uploadedNodes)
    }
    
    static func getSavedUploadedNodes() -> [UploadTransfer] {
        let userDefaults = UserDefaultsModel.getUserDefault()
        let nodes = try? userDefaults?.getObjects(forKey: KeyConstants.AppGroup.uploadedNodes, castTo: [UploadTransfer].self) ?? []
        return nodes ?? [UploadTransfer]()
    }
}
