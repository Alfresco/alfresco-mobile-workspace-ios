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

class TaskPropertiesViewModel: NSObject {
    var task: TaskNode?
    var services: CoordinatorServices?
    let isLoading = Observable<Bool>(true)
    var comments = Observable<[TaskCommentModel]>([])
    var attachments = Observable<[TaskAttachmentModel]>([])
    var didSelectTaskAttachment: ((TaskAttachmentModel) -> Void)?

    var taskName: String? {
        return task?.name
    }
    
    var userName: String? {
        return task?.assignee?.userName
    }
    
    var priority: Int {
        return task?.priority ?? 0
    }
    
    var taskPriority: TaskPriority {
        if priority >= 0 && priority <= 3 {
            return .low
        } else if priority >= 4 && priority <= 7 {
            return .medium
        } else {
            return .high
        }
    }
    
    func getPriorityValues(for currentTheme: PresentationTheme) -> (textColor: UIColor, backgroundColor: UIColor, priorityText: String) {
       
        var textColor: UIColor = currentTheme.taskErrorTextColor
        var backgroundColor: UIColor = currentTheme.taskErrorContainer
        var priorityText = LocalizationConstants.Tasks.low
       
        if taskPriority == .low {
            textColor = currentTheme.taskSuccessTextColor
            backgroundColor = currentTheme.taskSuccessContainer
            priorityText = LocalizationConstants.Tasks.low
        } else if taskPriority == .medium {
            textColor = currentTheme.taskWarningTextColor
            backgroundColor = currentTheme.taskWarningContainer
            priorityText = LocalizationConstants.Tasks.medium
        } else if taskPriority == .high {
            textColor = currentTheme.taskErrorTextColor
            backgroundColor = currentTheme.taskErrorContainer
            priorityText = LocalizationConstants.Tasks.high
        }
        return(textColor, backgroundColor, priorityText)
    }
    
    var dueDate: Date? {
        return task?.dueDate
    }
    
    func getDueDate() -> String? {
        if let dueDate = dueDate?.dateString(format: "dd MMM yyyy") {
            return dueDate
        } else {
            return LocalizationConstants.Tasks.noDueDate
        }
    }
    
    var isTaskCompleted: Bool {
        if task?.endDate == nil {
            return false
        }
        return true
    }
    
    var status: String {
        if isTaskCompleted {
            return LocalizationConstants.Tasks.completed
        }
        return LocalizationConstants.Tasks.active
    }
    
    var taskID: String {
        return task?.taskID ?? ""
    }
    
    var latestComment: TaskCommentModel? {
        if let comment = comments.value.last {
            return comment
        }
        return nil
    }
    
    func isAllowedToCompleteTask() -> Bool {
        let userEmail = UserProfile.email
        let assigneeEmail = task?.assignee?.email ?? ""
        if !userEmail.isEmpty {
            if userEmail == assigneeEmail && isTaskCompleted == false {
                return true
            }
        }
        return false
    }
}

// MARK: - Show Preview
extension TaskPropertiesViewModel {
   
    func showPreviewController(with path: String, attachment: TaskAttachmentModel, navigationController: UINavigationController?) {
        if let navigationViewController = navigationController, let node = listNodeForPreview(with: path, attachment: attachment) {
            
            let coordinator = FilePreviewScreenCoordinator(with: navigationViewController,
                                                           listNode: node,
                                                           excludedActions: [.moveTrash,
                                                                             .addFavorite,
                                                                             .removeFavorite],
                                                           shouldPreviewLatestContent: false,
                                                           isLocalFilePreview: true,
                                                           isContentAlreadyDownloaded: true)
            coordinator.start()
        }
    }
    
    private func listNodeForPreview(with path: String, attachment: TaskAttachmentModel) -> ListNode? {
        return ListNode(guid: "0",
                        mimeType: attachment.mimeType,
                        title: attachment.name ?? "",
                        path: path,
                        nodeType: .file,
                        favorite: false,
                        syncStatus: .error,
                        markedOfflineStatus: .upload,
                        allowableOperations: [AllowableOperationsType.delete.rawValue],
                        uploadLocalPath: path)
    }
}

// MARK: - Task Operations
extension TaskPropertiesViewModel {
    
    // MARK: - Assign Task

    func assignTask(taskId: String, assigneeId: String, completionHandler: @escaping ((_ data: TaskNode?, _ error: Error?) -> Void)) {
        
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            let params = AssignUserBody(assignee: assigneeId)
            
            TasksAPI.assignTask(taskId: taskId, params: params) {[weak self] data, error in
                guard let sSelf = self else { return }
                sSelf.isLoading.value = false
                if data != nil {
                    let taskNodes = TaskNodeOperations.processNodes(for: [data!])
                    if !taskNodes.isEmpty {
                        completionHandler(taskNodes.first, nil)
                    }
                } else {
                    completionHandler(nil, error)
                }
            }
        })
    }
}
