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
        let count = workflowOperationsModel?.attachments.value.count ?? 0
        if count > 1 {
            return String(format: LocalizationConstants.Tasks.multipleAttachmentsTitle, count)
        }
        return nil
    }
    
    var workflowDetailNode: WorkflowNode?
    var isDetailWorkflow = false
    var isShowTasksCountOnWorkflowDetail = false
    
    var screenTitle: String? {
        if isDetailWorkflow {
            return LocalizationConstants.Workflows.workflowTitle
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
    
    // MARK: - Check Assignee type
    func getFormFields(completionHandler: @escaping (_ error: Error?) -> Void) {
        
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { [self] authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            let name = self.processDefinition??.processId ?? ""
            
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

// MARK: - Start Workflow
extension StartWorkflowViewModel {
    
    func isAllowedToStartWorkflow() -> Bool {
        if assigneeUserId >= 0 {
            return true
        }
        return false
    }
    
    func startWorkflow(completionHandler: @escaping (_ isError: Bool) -> Void) {
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: {[weak self] authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            guard let sSelf = self else { return }
            let params = sSelf.startProcessParams()
            ProcessAPI.startProcess(params: params) { data, error in
                sSelf.isLoading.value = false
                if error == nil {
                    completionHandler(false)
                } else {
                    completionHandler(true)
                }
            }
        })
    }
    
    private func startProcessParams() -> StartProcessBodyCreate {
        let priority = String(format: "%@", taskPriority.rawValue)
        var dateString = dueDate?.dateString(format: "yyyy-MM-dd") ?? ""
        if !dateString.isEmpty {
            dateString = String(format: "%@T00:00:00Z", dateString)
        }
        let attachIds = attachmentIds()        
        let params = StartProcessParams(message: appDefinition?.description ?? "",
                                        dueDate: dateString,
                                        attachmentIds: attachIds,
                                        priority: priority,
                                        reviewer: reviewer().singleReviewer,
                                        reviewgroups: reviewer().groupReviewer,
                                        sendemailnotifications: false)
        
        let processDefinitionId = self.processDefinition??.processId ?? ""
        return StartProcessBodyCreate(name: appDefinition?.name ?? "",
                                      processDefinitionId: processDefinitionId,
                                      params: params)
    }
    
    private func attachmentIds() -> String {
        var attachIds = ""
        let attachments = workflowOperationsModel?.attachments.value ?? []
        for attachment in attachments where attachment.syncStatus == .synced {
            if !attachIds.isEmpty {
                attachIds = String(format: "%@,", attachIds)
            }
            
            let guid = attachment.guid
            if !guid.isEmpty {
                attachIds = String(format: "%@%@", attachIds, guid)
            }
        }
        
        return attachIds
    }
    
    private func reviewer() -> (singleReviewer: ReviewerParams?, groupReviewer: GroupReviewerParams?) {
        
        if isSingleReviewer {
            let reviewer = ReviewerParams(email: assignee?.email ?? "",
                                          firstName: assignee?.firstName ?? "",
                                          lastName: assignee?.lastName ?? "",
                                          id: assigneeUserId)
            return (reviewer, nil)
        } else {
            let reviewer = GroupReviewerParams(id: assignee?.assigneeID ?? -1,
                                             name: assignee?.groupName ?? "",
                                             externalId: assignee?.externalId,
                                             status: assignee?.status,
                                             parentGroupId: assignee?.parentGroupId,
                                             groups: nil)
            return (nil, reviewer)
        }
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
