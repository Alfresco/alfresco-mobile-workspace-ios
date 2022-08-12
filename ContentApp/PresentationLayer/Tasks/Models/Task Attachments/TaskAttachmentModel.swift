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

import AlfrescoContent

class TaskAttachmentModel {
    var attachmentID: Int?
    var name: String?
    var created: Date?
    var createdBy: TaskNodeAssignee?
    var relatedContent: Bool?
    var contentAvailable: Bool?
    var link: Bool?
    var mimeType: String?
    var simpleType: String?
    var previewStatus: String?
    var thumbnailStatus: String?
    
    enum CodingKeys: String, CodingKey {
        case attachmentID = "id"
        case name, created, createdBy
        case relatedContent, contentAvailable, link
        case mimeType, simpleType, previewStatus, thumbnailStatus
    }
    
    init(attachmentID: Int?,
         name: String?,
         created: Date?,
         createdBy: TaskNodeAssignee?,
         relatedContent: Bool?,
         contentAvailable: Bool?,
         link: Bool?,
         mimeType: String?,
         simpleType: String?,
         previewStatus: String?,
         thumbnailStatus: String?) {
        
        self.attachmentID = attachmentID
        self.name = name
        self.created = created
        self.createdBy = createdBy
        self.relatedContent = relatedContent
        self.contentAvailable = contentAvailable
        self.link = link
        self.mimeType = mimeType
        self.simpleType = simpleType
        self.previewStatus = previewStatus
        self.thumbnailStatus = thumbnailStatus
    }
}
