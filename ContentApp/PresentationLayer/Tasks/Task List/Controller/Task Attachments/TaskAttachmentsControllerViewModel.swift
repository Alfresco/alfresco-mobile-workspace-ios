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
import AlfrescoContent

class TaskAttachmentsControllerViewModel: TaskPropertiesViewModel {
    let rowViewModels = Observable<[RowViewModel]>([])
    var attachmentsCount: String? {
        if attachmentType == .task {
            return String(format: LocalizationConstants.Tasks.multipleAttachmentsTitle, attachments.value.count)
        } else if attachmentType == .workflow {
            let localAttachments = workflowOperationsModel?.attachments.value ?? []
            let attachments = localAttachments.filter { $0.parentGuid == tempWorkflowId }
            if !attachments.isEmpty {
                if !isWorkflowTaskAttachments {
                    let sizeLimitString = String(format: LocalizationConstants.Workflows.maximumFileSizeForUploads, KeyConstants.FileSize.workflowFileSize)
                    let combinedString = "\(String(format: LocalizationConstants.Tasks.multipleAttachmentsTitle, attachments.count))\n\(sizeLimitString)"
                    return combinedString
                } else {
                    return String(format: LocalizationConstants.Tasks.multipleAttachmentsTitle, attachments.count)
                }
            }
        }
        
        return nil
    }
    var attachmentType: AttachmentType = .task
    var tempWorkflowId: String = ""
    var processDefintionTitle: String = ""
    var workflowOperationsModel: WorkflowOperationsModel?
    var isWorkflowTaskAttachments = false
    var isDetailWorkflow = false
    
    func emptyList() -> EmptyListProtocol {
        return EmptyAttachFiles()
    }
}
