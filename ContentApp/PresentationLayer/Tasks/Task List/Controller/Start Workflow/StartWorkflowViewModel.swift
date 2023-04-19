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

import UIKit
import AlfrescoContent

class StartWorkflowViewModel: NSObject {
    let rowViewModels = Observable<[RowViewModel]>([])
    var services: CoordinatorServices?
    let isLoading = Observable<Bool>(true)
    var appDefinition: WFlowAppDefinitions?
    var isEditMode = false
    var didSelectAttachment: ((ListNode) -> Void)?
    var didSelectDeleteAttachment: ((ListNode) -> Void)?
    let uploadTransferDataAccessor = UploadTransferDataAccessor()
    var viewAllAttachmentsAction: (() -> Void)?
    var tempWorkflowId: String = ""
    var workflowOperationsModel: WorkflowOperationsModel?
    var selectedAttachments = [ListNode]()
    var processDefintionTitle: String {
        return appDefinition?.name ?? ""
    }
    
    var processDefintionDescription: String {
        return appDefinition?.description ?? ""
    }

    var dueDate: Date?
    
    var priority: Int = 0
    
    var taskPriority: TaskPriority {
        if priority >= 0 && priority <= 3 {
            return .low
        } else if priority >= 4 && priority <= 7 {
            return .medium
        } else {
            return .high
        }
    }
    
    var assignee: TaskNodeAssignee?
    
    var userName: String? {
        let apsUserID = UserProfile.apsUserID
        if apsUserID == assigneeUserId {
            return LocalizationConstants.EditTask.meTitle
        } else if let groupName = assignee?.groupName, !groupName.isEmpty {
            return groupName
        } else {
            return assignee?.userName
        }
    }
    
    var assigneeUserId: Int {
        return assignee?.assigneeID ?? -1
    }
    
    var attachmentsCount: String? {
        let count = workflowOperationsModel?.attachments.value.count ?? 0
        if count > 1 {
            return String(format: LocalizationConstants.Tasks.multipleAttachmentsTitle, count)
        }
        return nil
    }
    
    // MARK: - Get Due date
    func getDueDate(for dueDate: Date?) -> String? {
        if let dueDate = dueDate?.dateString(format: "dd MMM yyyy") {
            return dueDate
        } else {
            return LocalizationConstants.Tasks.noDueDate
        }
    }
    
    // MARK: - Process defintion
    func fetchProcessDefinition(completionHandler: @escaping (_ processDefinition: WFlowProcessDefinitions?, _ error: Error?) -> Void) {
        
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { [self] authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            let appDefinitionId = self.appDefinition?.addDefinitionID ?? -1
            
            ProcessAPI.processDefinition(appDefinitionId: String(appDefinitionId)) {[weak self] data, error in
                guard let sSelf = self else { return }
                sSelf.isLoading.value = false

                if data != nil {
                    let processDefinitions = data?.data ?? []
                    let processDefinition = WFlowProcessDefinitionsOperations.processNodes(for: processDefinitions)
                    StartWorkflowModel.shared.processDefiniton = processDefinition
                    completionHandler(processDefinition, nil)
                } else {
                    completionHandler(nil, error)
                }
            }
        })
    }
}
