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

import Foundation
import AlfrescoContent

// MARK: - Notification Type
enum FormFieldsType: String {
    case message = "message"
    case items = "items"
    case priority = "priority"
    case duedate = "duedate"
    case status = "status"
    case comment = "comment"
}

// MARK: - Workflow's Task detail view model
class WflowTaskDetailViewModel: TaskPropertiesViewModel {
    let rowViewModels = Observable<[RowViewModel]>([])
    var viewAllAttachmentsAction: (() -> Void)?
    var didRefreshWorkflowList: (() -> Void)?
    var taskId: String {
        return task?.taskID ?? ""
    }
    var processDetails: StartFormFields?
    var formFields = [Field]()
    var workflowTaskName: String?
    var workflowtaskDescription: String?
    var workflowTaskPriority: String?
    var taskPriorityValue: TaskPriority? {
        if workflowTaskPriority == TaskPriority.low.rawValue.lowercased() {
            return .low
        } else if workflowTaskPriority == TaskPriority.medium.rawValue.lowercased() {
            return .medium
        } else if workflowTaskPriority == TaskPriority.high.rawValue.lowercased() {
            return .high
        } else {
            return nil
        }
    }

    var workflowTaskDueDate: String?
    var workflowStatus: String?
    var comment: String?
    var workflowTaskAttachments = [ListNode]()
    var workflowStatusOptions = [Option]()
    var selectedStatus: Option?
    var outcomes: [Outcome] {
        return processDetails?.outcomes ?? []
    }
    
    var outcomeTitleOne: String? {
        if !outcomes.isEmpty {
            return outcomes.first?.name
        }
        return nil
    }
    
    var outcomeTitleTwo: String? {
        if outcomes.count > 1 {
            return outcomes[1].name
        }
        return nil
    }
    
    var selectedOutcome: String?
    var taskNode: TaskNode?
    
    var isAllowedToEditStatus: Bool {
        let apsUserID = UserProfile.apsUserID
        if assigneeUserId == apsUserID && !isTaskCompleted {
            return true
        }
        return false
    }
    
    // MARK: - Workflow Task details

    func workflowTaskDetails(completionHandler: @escaping (_ error: Error?) -> Void) {
        guard services?.connectivityService?.hasInternetConnection() == true else { return }
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            TasksAPI.getTaskForm(taskId: self.taskId) {[weak self] data, fields, error in
                guard let sSelf = self else { return }
                sSelf.isLoading.value = false

                if data != nil {
                    sSelf.processDetails = data
                    sSelf.formFields = fields
                    sSelf.processFieldsToGetData()
                    completionHandler(nil)
                } else {
                    completionHandler(error)
                }
            }
        })
    }
    
    private func processFieldsToGetData() {
        workflowTaskName = processDetails?.taskName ?? ""
        
        for field in formFields {
            let formId = field.id
            if formId == FormFieldsType.message.rawValue { // description
                workflowtaskDescription = parseValueType(for: field).stringValue
            } else if formId == FormFieldsType.priority.rawValue { // priority
                workflowTaskPriority = parseValueType(for: field).stringValue?.lowercased()
            } else if formId == FormFieldsType.duedate.rawValue { // due date
                workflowTaskDueDate =  parseValueType(for: field).stringValue
            } else if formId == FormFieldsType.status.rawValue { // status
                workflowStatus = parseValueType(for: field).stringValue
                workflowStatusOptions = field.options ?? []
            } else if formId == FormFieldsType.comment.rawValue { // comment
                comment = parseValueType(for: field).stringValue
            } else if formId == FormFieldsType.items.rawValue { // attachmnets
                if let tAttachments = parseValueType(for: field).arrayValue {
                    workflowTaskAttachments = TaskAttachmentOperations.processWorkflowAttachments(for: tAttachments, taskId: taskId)
                }
            }
        }
    }
    
    private func parseValueType(for field: Field) -> (stringValue: String?, arrayValue: [ValueElement]?) {
        switch field.value {
        case .string(let aString):
            return (aString, nil)
        case .valueElementArray(let elements):
            return (nil, elements)
        case .none:
            AlfrescoLog.debug("Found none")
        case .some(.null):
            AlfrescoLog.debug("Found null")
        }
        return (nil, nil)
    }
    
    func getDueDate(for dueDate: String?) -> String? {
        if let date = dueDate?.toDate(), let dueDate = date.dateString(format: "dd MMM yyyy") {
            return dueDate
        }
        return LocalizationConstants.Tasks.noDueDate
    }
    
    func getSelectedStatus() -> Option? {
        for option in workflowStatusOptions where option.id != "empty" && option.name == workflowStatus {
            return option
        }
        return nil
    }
    
    func isValidationPassed() -> Bool {
        if workflowStatusOptions.isEmpty {
            return true
        } else if selectedStatus != nil {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Approve/Reject Task
    func approveRejectTask(completionHandler: @escaping (_ error: Error?) -> Void) {
        
        guard services?.connectivityService?.hasInternetConnection() == true else { return }
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            
            let params = SaveFormParams(status: self.selectedStatus, comment: self.comment)
            TasksAPI.approveOrRejectTaskForm(taskId: self.taskId, params: params, outcome: self.selectedOutcome) {[weak self] data, error in
                guard let sSelf = self else { return }
                sSelf.isLoading.value = false

                if data != nil {
                    completionHandler(nil)
                } else {
                    completionHandler(error)
                }
            }
        })
    }
    
    // MARK: - Claim / Unclaim Task

    func claimUnclaimTask(isClaim: Bool, completionHandler: @escaping (_ error: Error?) -> Void) {
        guard services?.connectivityService?.hasInternetConnection() == true else { return }
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            TasksAPI.claimOrUnclaimTask(taskId: self.taskId, isClaimTask: isClaim) {[weak self] data, error in
                guard let sSelf = self else { return }
                sSelf.isLoading.value = false
                if data != nil {
                    completionHandler(nil)
                } else {
                    completionHandler(error)
                }
            }
        })
    }
}
