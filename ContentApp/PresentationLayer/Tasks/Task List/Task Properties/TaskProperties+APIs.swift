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

import Foundation
import AlfrescoContent

// MARK: - Task APIs
extension TaskPropertiesViewModel {
    
    // MARK: - Task details

    func taskDetails(with taskId: String, completionHandler: @escaping (_ taskNodes: TaskNode?, _ error: Error?) -> Void) {
        
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            
            TasksAPI.getTasksDetails(with: taskId) {[weak self] data, error in
                guard let sSelf = self else { return }
                sSelf.isLoading.value = false
                if data != nil {
                    let taskNodes = TaskNodeOperations.processNodes(for: [data!])
                    if !taskNodes.isEmpty {
                        sSelf.task = taskNodes.first
                        completionHandler(sSelf.task, nil)
                    }
                    
                } else {
                    completionHandler(nil, error)
                }
            }
        })
    }
    
    // MARK: - Task comment history

    func taskComments(with taskId: String, completionHandler: @escaping (_ taskComments: [TaskCommentModel], _ error: Error?) -> Void) {
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            TaskCommentsAPI.getTaskComments(with: taskId) {[weak self] data, error in
                guard let sSelf = self else { return }
                sSelf.isLoading.value = false
                if data != nil {
                    if let taskComments = data?.data {
                        let comments = TaskCommentOperations.processComments(for: taskComments)
                        completionHandler(comments, nil)
                    } else {
                        completionHandler([], nil)
                    }
                } else {
                    completionHandler([], error)
                }
            }
        })
    }
    
    // MARK: - Task add a comment
    
    func addTaskComment(with taskId: String, message: String, completionHandler: @escaping (_ taskComment: [TaskCommentModel], _ error: Error?) -> Void) {
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            let params = TaskCommentParams(message: message)
            TaskCommentsAPI.postTaskComment(taskId: taskId, params: params) { data, error in
                if data != nil {
                    if let taskComment = data {
                        let comments = TaskCommentOperations.processComments(for: [taskComment])
                        completionHandler(comments, nil)
                    } else {
                        completionHandler([], nil)
                    }
                } else {
                    completionHandler([], error)
                }
            }
        })
    }
    
    // MARK: - Task attachments

    func taskAttachments(with taskId: String, completionHandler: @escaping (_ taskAttachments: [TaskAttachmentModel], _ error: Error?) -> Void) {
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            TaskAttachmentsAPI.getTaskAttachments(with: taskId) {[weak self] data, error in
                guard let sSelf = self else { return }
                sSelf.isLoading.value = false
                if data != nil {
                    if let taskAttachments = data?.data {
                        let attachements = TaskAttachmentOperations.processAttachments(for: taskAttachments)
                        completionHandler(attachements, nil)
                    } else {
                        completionHandler([], nil)
                    }
                } else {
                    completionHandler([], error)
                }
            }
        })
    }
}
