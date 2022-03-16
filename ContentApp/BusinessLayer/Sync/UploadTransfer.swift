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

class UploadTransfer: Entity, Codable {
    var id: Id = 0 // swiftlint:disable:this identifier_name
    var parentNodeId = ""
    var nodeName = ""
    var extensionType: String = ""
    var mimetype: String = ""
    var nodeDescription = ""
    var localFilenamePath = ""
    var fullFilePath = ""
    // objectbox: convert = { "default": ".undefined" }
    var syncStatus: SyncStatus = .pending

    // Default initializer required by ObjectBox

    init() {}

    init(parentNodeId: String,
         nodeName: String,
         extensionType: String,
         mimetype: String,
         nodeDescription: String?,
         localFilenamePath: String,
         fullFilePath: String) {
        self.parentNodeId = parentNodeId
        self.nodeName = nodeName
        self.extensionType = extensionType
        self.mimetype = mimetype
        self.nodeDescription = nodeDescription ?? ""
        self.localFilenamePath = localFilenamePath
        self.fullFilePath = fullFilePath
    }

    // MARK: - Public Helpers

    func update(with newVersion: UploadTransfer) {
        parentNodeId = newVersion.parentNodeId
        nodeName = newVersion.nodeName
        nodeDescription = newVersion.nodeDescription
        localFilenamePath = newVersion.localFilenamePath
        fullFilePath = newVersion.fullFilePath
    }
    
    func listNode() -> ListNode {
        let node = ListNode(guid: "0", title: nodeName + "." + extensionType, path: "", nodeType: .file)
        node.id = id
        node.mimeType = mimetype
        node.parentGuid = parentNodeId
        node.syncStatus = syncStatus
        node.markedFor = .upload
        node.uploadLocalPath = localFilenamePath
        return node
    }
    
    func updateListNode(with newVersion: ListNode) -> ListNode {
        newVersion.id = id
        newVersion.syncStatus = syncStatus
        newVersion.markedFor = .upload
        newVersion.uploadLocalPath = localFilenamePath
        return newVersion
    }
}
