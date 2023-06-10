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
class WflowTaskDetailViewModel: NSObject {
    var services: CoordinatorServices?
    let isLoading = Observable<Bool>(true)
    let rowViewModels = Observable<[RowViewModel]>([])
    var viewAllAttachmentsAction: (() -> Void)?
    var task: TaskNode?
    var didRefreshWorkflowList: (() -> Void)?
    var didSelectTaskAttachment: ((ListNode) -> Void)?
    
    var taskId: String {
        return task?.taskID ?? ""
    }
    var processDetails: StartFormFields?
    var formFields = [Field]()
    var taskName: String?
    var taskDescription: String?
    var priority: String?
    var taskPriority: TaskPriority? {
        if priority == TaskPriority.low.rawValue.lowercased() {
            return .low
        } else if priority == TaskPriority.medium.rawValue.lowercased() {
            return .medium
        } else if priority == TaskPriority.high.rawValue.lowercased() {
            return .high
        } else {
            return nil
        }
    }

    var dueDate: String?
    var workflowStatus: String?
    var assigneeUserId: Int {
        return task?.assignee?.assigneeID ?? -1
    }
    
    var userName: String? {
        let apsUserID = UserProfile.apsUserID
        if apsUserID == assigneeUserId {
            return LocalizationConstants.EditTask.meTitle
        } else {
            return task?.assignee?.userName
        }
    }
    
    var comment: String?
    var attachments = [ListNode]()
    var workflowStatusOptions = [Option]()
    var isTaskCompleted: Bool {
        if task?.endDate == nil {
            return false
        }
        return true
    }
    
    var completedDate: Date? {
        return task?.endDate
    }
    
    func geCompletedDate() -> String? {
        if isTaskCompleted {
            if let endDate = completedDate?.dateString(format: "dd MMM yyyy") {
                return endDate
            } else {
                return nil
            }
        }
        return nil
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
        taskName = processDetails?.taskName ?? ""
        
        for field in formFields {
            let formId = field.id
            if formId == FormFieldsType.message.rawValue { // description
                taskDescription = parseValueType(for: field).stringValue
            } else if formId == FormFieldsType.priority.rawValue { // priority
                priority = parseValueType(for: field).stringValue?.lowercased()
            } else if formId == FormFieldsType.duedate.rawValue { // due date
                dueDate =  parseValueType(for: field).stringValue
            } else if formId == FormFieldsType.status.rawValue { // status
                workflowStatus = parseValueType(for: field).stringValue
                workflowStatusOptions = field.options ?? []
            } else if formId == FormFieldsType.comment.rawValue { // comment
                comment = parseValueType(for: field).stringValue
            } else if formId == FormFieldsType.items.rawValue { // attachmnets
                if let tAttachments = parseValueType(for: field).arrayValue {
                    attachments = TaskAttachmentOperations.processWorkflowAttachments(for: tAttachments, taskId: taskId)
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
}
