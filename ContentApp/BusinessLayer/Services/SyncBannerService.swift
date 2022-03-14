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

class SyncBannerService: NSObject {

    class func triggerSyncNotifyService() {
        let notificationName = Notification.Name(rawValue: KeyConstants.Notification.syncStarted)
        let notification = Notification(name: notificationName)
        NotificationCenter.default.post(notification)
    }
    
    class func calculateProgress() -> Float {
        let totalFiles = SyncBannerService.totalUploadNodes()
        let uploadedFiles = SyncBannerService.totalUploadedNodes()
        let percentage = Float(uploadedFiles)/Float(totalFiles + uploadedFiles)
        return percentage
    }
    
    class func totalUploadNodes() -> Int {
        let uploadTransferAccessor = UploadTransferDataAccessor()
        return uploadTransferAccessor.queryAll().count
    }
    
    class func totalUploadedNodes() -> Int {
        let uploadTransferAccessor = UploadTransferDataAccessor()
        return uploadTransferAccessor.queryAllForUploadedNodes().count
    }
    
    class func removeAllUploadedNodesFromDatabase() {
        let uploadTransferAccessor = UploadTransferDataAccessor()
        let nodes = uploadTransferAccessor.queryAllForUploadedNodes()
        if !nodes.isEmpty {
            for node in nodes {
                uploadTransferAccessor.removeNode(node: node)
            }
        }
    }
}
