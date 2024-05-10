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

class TaskAttachmentOperations: NSObject {

    static func processAttachments(for taskAttachments: [TaskAttachment], taskId: String) -> [ListNode] {
        var nodes: [ListNode] = []
        for attachment in taskAttachments {
            
            let listNode = ListNode(guid: String(format: "%d", attachment.id ?? -1),
                                    parentGuid: taskId,
                                    mimeType: attachment.mimeType,
                                    title: attachment.name ?? "",
                                    path: "",
                                    nodeType: .file,
                                    isFile: true,
                                    isFolder: false,
                                    assigneeID: attachment.createdBy?.id ?? -1,
                                    firstName: attachment.createdBy?.firstName,
                                    lastName: attachment.createdBy?.lastName,
                                    email: attachment.createdBy?.email)
            nodes.append(listNode)
        }
        return nodes
    }
    
    static func processWorkflowAttachments(for taskAttachments: [ValueElement], taskId: String) -> [ListNode] {
        var nodes: [ListNode] = []
        for attachment in taskAttachments {
            
            let listNode = ListNode(guid: String(format: "%d", attachment.id),
                                    parentGuid: taskId,
                                    mimeType: attachment.mimeType,
                                    title: attachment.name,
                                    path: "",
                                    nodeType: .file,
                                    isFile: true,
                                    isFolder: false,
                                    assigneeID: attachment.createdBy.id,
                                    firstName: attachment.createdBy.firstName,
                                    lastName: attachment.createdBy.lastName,
                                    email: attachment.createdBy.email)
            nodes.append(listNode)
        }
        return nodes
    }
    
    static func processWorkflowAttachmentszFromValueElement(for taskAttachment: ListNode, taskId: String) -> ValueElement {
            
        let createdBy = CreatedBy(id: Int(taskAttachment.id), firstName: taskAttachment.firstName ?? "", lastName: taskAttachment.lastName ?? "", email: taskAttachment.email ?? "")
            
        return  ValueElement(id: Int(taskAttachment.guid) ?? 0, name: taskAttachment.title, created: "", createdBy: createdBy, relatedContent: false, contentAvailable: false, link: false, mimeType: taskAttachment.mimeType ?? "", simpleType: "", previewStatus: "", thumbnailStatus: "")
    }
}
