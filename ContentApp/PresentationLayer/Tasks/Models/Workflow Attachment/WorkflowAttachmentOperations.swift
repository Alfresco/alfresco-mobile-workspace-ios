//
// Copyright (C) 2005-2023 Alfresco Software Limited.
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

class WorkflowAttachmentOperations: NSObject {

    static func processAttachments(for attachments: [ProcessContentDetails]) -> [WorkflowAttachment] {
        var nodes: [WorkflowAttachment] = []
        for attachment in attachments {
            let assignee = ProcessNodeAssignee(assigneeID: attachment.createdBy?.id ?? -1,
                                               firstName: attachment.createdBy?.firstName,
                                               lastName: attachment.createdBy?.lastName,
                                               email: attachment.createdBy?.email)
    
            let node = WorkflowAttachment(attachmentId: attachment.id,
                                          name: attachment.name,
                                          created: attachment.created,
                                          createdBy: assignee,
                                          relatedContent: attachment.relatedContent,
                                          contentAvailable: attachment.contentAvailable,
                                          link: attachment.link,
                                          source: attachment.source,
                                          sourceId: attachment.sourceId,
                                          mimeType: attachment.mimeType,
                                          simpleType: attachment.simpleType,
                                          previewStatus: attachment.previewStatus,
                                          thumbnailStatus: attachment.thumbnailStatus)

            nodes.append(node)
        }
        
        return nodes
    }
}
