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
import MaterialComponents.MaterialDialogs

// MARK: - Task APIs
extension TaskPropertiesViewModel {
    
    // MARK: - Task details

    func taskDetails(with taskId: String, completionHandler: @escaping (_ taskNodes: TaskNode?, _ error: Error?) -> Void) {
        guard services?.connectivityService?.hasInternetConnection() == true else { return }
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
        guard services?.connectivityService?.hasInternetConnection() == true else { return }
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
        guard services?.connectivityService?.hasInternetConnection() == true else { return }
        self.isLoading.value = true
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
                self.isLoading.value = false
            }
        })
    }
    
    // MARK: - Task attachments

    func taskAttachments(with taskId: String, completionHandler: @escaping (_ taskAttachments: [ListNode], _ error: Error?) -> Void) {
        guard services?.connectivityService?.hasInternetConnection() == true else { return }
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            TaskAttachmentsAPI.getTaskAttachments(with: taskId) {[weak self] data, error in
                guard let sSelf = self else { return }
                sSelf.isLoading.value = false
                if data != nil {
                    if let taskAttachments = data?.data {
                        let attachements = TaskAttachmentOperations.processAttachments(for: taskAttachments, taskId: taskId)
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
    
    func downloadContent(for title: String,
                         contentId: String,
                         completionHandler: @escaping (_ downloadedPath: String?, _ error: Error?) -> Void) {
        guard let accountIdentifier = self.services?.accountService?.activeAccount?.identifier else { return }
       
        if let path = DiskService.isFileExists(accountIdentifier: accountIdentifier, attachmentId: contentId, name: title) {
            completionHandler(path, nil)
        } else {
            var isCancelDownload = false
            var downloadDialog: MDCAlertController?
            downloadDialog = self.showDownloadDialog(title: title, actionHandler: { _ in
                isCancelDownload = true
                downloadDialog?.dismiss(animated: true, completion: nil)
            })
            
            services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
                AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
                
                TaskAttachmentsAPI.getTaskAttachmentContent(contentId: contentId) { data, error in
                    if data != nil && isCancelDownload == false {
                        if let path = DiskService.saveAttachment(accountIdentifier: accountIdentifier, attachmentId: contentId, data: data, name: title) {
                            completionHandler(path, nil)
                        }
                    } else {
                        completionHandler(nil, error)
                    }
                    downloadDialog?.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    private func showDownloadDialog(title: String, actionHandler: @escaping (MDCAlertAction) -> Void) -> MDCAlertController? {
        if let downloadDialogView: DownloadDialog = .fromNib() {
            let themingService = services?.themingService
            downloadDialogView.messageLabel.text =
                String(format: LocalizationConstants.Dialog.downloadMessage,
                       title)
            downloadDialogView.activityIndicator.startAnimating()
            downloadDialogView.applyTheme(themingService?.activeTheme)

            let cancelAction =
                MDCAlertAction(title: LocalizationConstants.General.cancel) { action in
                    actionHandler(action)
            }
            cancelAction.accessibilityIdentifier = "cancelActionButton"

            if let presentationContext = UIViewController.applicationTopMostPresented {
                let downloadDialog = presentationContext.showDialog(title: nil,
                                                                    message: nil,
                                                                    actions: [cancelAction],
                                                                    accesoryView: downloadDialogView,
                                                                    completionHandler: {})

                return downloadDialog
            }
        }

        return nil
    }
    
    // MARK: - Task attachments

    func completeTask(with taskId: String, completionHandler: @escaping (_ isSuccess: Bool) -> Void) {
        guard services?.connectivityService?.hasInternetConnection() == true else { return }
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            TasksAPI.completeTask(with: taskId) {[weak self] data, error in
                guard let sSelf = self else { return }
                sSelf.isLoading.value = false
                if error == nil {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
        })
    }
    
    // MARK: - Edit Task
    func editTaskDetails(with taskId: String, params: TaskBodyCreate, completionHandler: @escaping ((_ data: TaskNode?, _ error: Error?) -> Void)) {
        guard services?.connectivityService?.hasInternetConnection() == true else { return }
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            
            TasksAPI.updateTask(taskId: taskId, params: params) {[weak self] data, error in
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
    
    // MARK: - Assign Task
    func assignTask(with taskId: String, params: AssignUserBody, completionHandler: @escaping ((_ data: TaskNode?, _ error: Error?) -> Void)) {
        guard services?.connectivityService?.hasInternetConnection() == true else { return }
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            
            TasksAPI.assignTask(taskId: taskId, params: params) {[weak self] data, error in
                guard let sSelf = self else { return }
                if data != nil {
                    AnalyticsManager.shared.apiTracker(name: Event.API.apiAssignUser.rawValue, fileSize: 0, success: true)
                    let taskNodes = TaskNodeOperations.processNodes(for: [data!])
                    if !taskNodes.isEmpty {
                        completionHandler(taskNodes.first, nil)
                    }
                } else {
                    AnalyticsManager.shared.apiTracker(name: Event.API.apiAssignUser.rawValue, fileSize: 0, success: false)
                    completionHandler(nil, error)
                }
                sSelf.isLoading.value = false
            }
        })
    }
}

// MARK: - Delete Attachment
extension TaskPropertiesViewModel {
    
    func showDeleteAttachmentAlert(for attachment: ListNode?, on controller: UIViewController?, completionHandler: @escaping ((_ success: Bool) -> Void)) {
        
        let title = LocalizationConstants.EditTask.deleteAttachmentAlertTitle
        let confirmAction = MDCAlertAction(title: LocalizationConstants.Dialog.confirmTitle) { [weak self] _ in
            guard let sSelf = self else { return }
            sSelf.deleteAttachment(with: attachment?.guid) { success in
                completionHandler(success)
            }
        }
        confirmAction.accessibilityIdentifier = "confirmActionButton"
        
        let cancelAction = MDCAlertAction(title: LocalizationConstants.General.cancel) { _ in }
        cancelAction.accessibilityIdentifier = "cancelActionButton"

        _ = controller?.showDialog(title: title,
                                   message: attachment?.title,
                                       actions: [confirmAction, cancelAction],
                                       completionHandler: {})
    }
    
    private func deleteAttachment(with attachmentID: String?, completionHandler: @escaping ((_ success: Bool) -> Void)) {
        guard services?.connectivityService?.hasInternetConnection() == true else { return }
        if let attachmentID = attachmentID, attachmentID != "-1", !attachmentID.isEmpty {
            self.isLoading.value = true
            services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
                AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
                
                TasksAPI.deleteRawContent(contentId: attachmentID) {[weak self] data, error in
                    guard let sSelf = self else { return }
                    if data != nil {
                        completionHandler(true)
                    } else {
                        completionHandler(false)
                    }
                    sSelf.isLoading.value = false
                }
            })
        }
    }
}
