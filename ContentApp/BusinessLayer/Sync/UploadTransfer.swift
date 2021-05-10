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

class UploadTransfer: Entity {
    var id: Id = 0 // swiftlint:disable:this identifier_name
    var parentNodeId = ""
    var nodeName = ""
    var nodeDescription = ""
    var filePath = ""
    // objectbox: convert = { "default": ".undefined" }
    var syncStatus: SyncStatus = .undefined

    // Default initializer required by ObjectBox

    init() {}

    init(parentNodeId: String,
         nodeName: String,
         nodeDescription: String?,
         filePath: String) {
        self.parentNodeId = parentNodeId
        self.nodeName = nodeName
        self.nodeDescription = nodeDescription ?? ""
        self.filePath = filePath
    }

    // MARK: - Public Helpers

    func update(with newVersion: UploadTransfer) {
        parentNodeId = newVersion.parentNodeId
        nodeName = newVersion.nodeName
        nodeDescription = newVersion.nodeDescription
        filePath = newVersion.filePath
    }
}
