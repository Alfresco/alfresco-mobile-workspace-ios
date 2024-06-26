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
    var processDefinition: WFlowProcessDefinitions??
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
    var workflowDetailTasks = [TaskNode]()
    var didRefreshTaskList: (() -> Void)?
    var formFields = [Field]()
    var formData: StartFormFields?
    let isEnabledButton = Observable<Bool>(false)
    var task: TaskNode?
    var isShowDoneCompleteBtn = false
    var isComplexFirstTime = false
    var isAssigneeAndLoggedInSame = false
    var isClaimProcess = false
    var isAttachment = false
    var taskId: String {
        return task?.taskID ?? ""
    }

    var processDefintionTitle: String {
        return appDefinition?.name ?? ""
    }
    
    var processDefintionDescription: String {
        return appDefinition?.description ?? ""
    }

    var dueDate: Date?
    
    var priority: Int = 0
    
    var isSingleReviewer = true
    
    var isAllowedToEditAssignee = false
    
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
        if isAllowedToEditAssignee {
            let apsUserID = UserProfile.apsUserID
            isAssigneeAndLoggedInSame = apsUserID == assigneeUserId
            if apsUserID == assigneeUserId && isSingleReviewer {
                return LocalizationConstants.EditTask.meTitle
            } else if let groupName = assignee?.groupName, !groupName.isEmpty {
                return groupName
            } else {
                return assignee?.userName
            }
        }
        return nil
    }
    
    var assigneeUserId: Int {
        return assignee?.assigneeID ?? -1
    }
    
    var attachmentsCount: String? {
        if let count = workflowOperationsModel?.attachments.value.count, !(workflowOperationsModel?.attachments.value.isEmpty ?? Bool()) {
            return String(format: LocalizationConstants.Tasks.multipleAttachmentsTitle, count)
        }
        return nil
    }
    
    var workflowDetailNode: WorkflowNode?
    var isDetailWorkflow = false
    var isShowTasksCountOnWorkflowDetail = false
    
    var screenTitle: String? {
        if isDetailWorkflow {
            if task != nil {
                let name = task?.name ?? ""
                return name.isEmpty ? LocalizationConstants.Workflows.noName : name
            } else {
                return LocalizationConstants.Workflows.workflowTitle
            }
        } else {
            return LocalizationConstants.Accessibility.startWorkflow
        }
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
                    sSelf.processDefinition = processDefinition
                    completionHandler(processDefinition, nil)
                } else {
                    completionHandler(nil, error)
                }
            }
        })
    }
    
    // MARK: - Workflow Task details

    func workflowTaskDetails(completionHandler: @escaping (_ error: Error?) -> Void) {
        guard services?.connectivityService?.hasInternetConnection() == true else { return }
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            var grpError: Error?
            let group = DispatchGroup()
            group.enter()
            
            TasksAPI.getTasksDetails(with: sSelf.taskId) {[weak self] data, error in
                guard let sSelf = self else { return }
                if data != nil {
                    let taskNodes = TaskNodeOperations.processNodes(for: [data!])
                    sSelf.task = taskNodes.first
                    if !taskNodes.isEmpty, sSelf.task?.memberOfCandidateGroup == true {
                        if let assigneeId = taskNodes.first?.assignee?.assigneeID, assigneeId <= 0 {
                            sSelf.isClaimProcess = true
                        }
                    }
                    sSelf.isAssigneeAndLoggedInSame = taskNodes.first?.assignee?.assigneeID == UserProfile.apsUserID
                    
                } else {
                    grpError = error
                }
                group.leave()
            }
            group.enter()
            TasksAPI.getTaskForm(taskId: sSelf.taskId) { data, fields, error in
                if data != nil {
                    sSelf.formData = data
                    sSelf.formFields = fields
                }
                group.leave()
            }
            group.notify(queue: .main) {
                sSelf.isLoading.value = false
                completionHandler(grpError)
            }
        })
    }
    
    func isReleaseOutcomeRequired() -> Bool {
        return self.task?.memberOfCandidateGroup == true && isAssigneeAndLoggedInSame == true
    }
    
    func claimOrUnclaimTask(taskId: String, isClaimTask: Bool, completionHandler: @escaping (_ error: Error?) -> Void) {
        self.isLoading.value = true
        TasksAPI.claimOrUnclaimTask(taskId: taskId, isClaimTask: isClaimTask) { data, error in
            completionHandler(error)
            self.isLoading.value = false
        }
    }
    
    // MARK: - Check Assignee type
    func getFormFields(completionHandler: @escaping (_ error: Error?) -> Void) {
        
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { [self] authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            var name = ""
            if isDetailWorkflow {
                name = self.formData?.processDefinitionID ?? ""
            } else {
                name = self.processDefinition??.processId ?? ""
            }
            
            ProcessAPI.formFields(name: name) {[weak self] data, fields, error in
                guard let sSelf = self else { return }
                sSelf.isLoading.value = false
                sSelf.isAllowedToEditAssignee = true
                sSelf.formFields = fields
                sSelf.formData = data
                if data != nil && !fields.isEmpty {
                    for field in fields {
                        if field.id == "reviewer" {
                            sSelf.isSingleReviewer = true
                        } else if field.id == "reviewgroups" {
                            sSelf.isSingleReviewer = false
                        }
                    }
                    completionHandler(nil)
                } else {
                    completionHandler(error)
                }
            }
        })
    }
}

// MARK: - Link content to APS
extension StartWorkflowViewModel {
    
    func linkContentToAPS(node: ListNode?, completionHandler: @escaping (_ node: ListNode?, _ error: Error?) -> Void) {
        
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { [self] authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            
            if let params = linkContentParams(node: node) {
                ProcessAPI.linkContentToProcess(params: params) {[weak self] data, error in
                    guard let sSelf = self else { return }
                    sSelf.isLoading.value = false
                    if error == nil {
                        if let data = data {
                            let attachment = WorkflowAttachmentOperations.processAttachment(for: data)
                            completionHandler(attachment, nil)
                        }
                    } else {
                        completionHandler(nil, error)
                    }
                }
            }
        })
    }
    
    private func linkContentParams(node: ListNode?) -> ProcessRequestLinkContent? {
        if let listNode = node {
            let params = ProcessRequestLinkContent(source: "alfresco-1-adw-contentAlfresco",
                                                   mimeType: listNode.mimeType,
                                                   sourceId: listNode.guid,
                                                   name: listNode.title)
            return params
        }
        return nil
    }
    
    func isLocalContentAvailable() -> Bool {
        let attachments = workflowOperationsModel?.attachments.value ?? []
        for attachment in attachments where attachment.syncStatus != .synced {
            return true
        }
        return false
    }
}

// MARK: - Workflow details
extension StartWorkflowViewModel {
    
    func taskList(with params: TaskListParams, completionHandler: @escaping (_ taskNodes: [TaskNode], _ error: Error?) -> Void) {
       
        isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            
            TasksAPI.getTasksList(params: params) {[weak self] data, error in
                guard let sSelf = self else { return }
                sSelf.isLoading.value = false
                sSelf.isShowTasksCountOnWorkflowDetail = true
                if data != nil {
                    let task = data?.data ?? []
                    let taskNodes = TaskNodeOperations.processNodes(for: task)
                    sSelf.workflowDetailTasks = taskNodes
                    completionHandler(taskNodes, nil)
                } else {
                    completionHandler([], error)
                }
            }
        })
    }
}
