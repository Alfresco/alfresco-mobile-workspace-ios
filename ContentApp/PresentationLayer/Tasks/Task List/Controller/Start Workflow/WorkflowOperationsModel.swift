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

class WorkflowOperationsModel: NSObject {
    var services: CoordinatorServices?
    var tempWorkflowId: String = ""
    var attachments = Observable<[ListNode]>([])
    let uploadTransferDataAccessor = UploadTransferDataAccessor()
    internal var filePreviewCoordinator: FilePreviewScreenCoordinator?

    init(services: CoordinatorServices? = nil, tempWorkflowId: String) {
        self.services = services
        self.tempWorkflowId = tempWorkflowId
    }
    
    func uploadAttachmentOperation(transfer: UploadTransfer, completionHandler: @escaping (_ isError: Bool) -> Void) {
        
        transfer.syncStatus = .inProgress
        handleSyncStatus(eventNode: transfer.listNode())
        completionHandler(false)
        
        let transferDataAccessor = UploadTransferDataAccessor()
        services?.accountService?.getSessionForCurrentAccount(completionHandler: {[weak self] authenticationProvider in 
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            guard let fileURL = transferDataAccessor.uploadLocalPath(for: transfer) else { return }
            guard let sSelf = self else { return }

            do {
                let fileData = try Data(contentsOf: fileURL)
                let fileSize = fileURL.fileSize
                let fileName = String(format: "%@.%@", transfer.nodeName, transfer.extensionType)

                TasksAPI.uploadContentToWorkflow(fileData: fileData,
                                                 fileName: fileName,
                                                 mimeType: transfer.mimetype) { data, error in
                    
                    if error == nil, let node = data {
                        AnalyticsManager.shared.apiTracker(name: Event.API.apiUploadWorkflowAttachment.rawValue, fileSize: fileSize, success: true)
                        transfer.syncStatus = .synced
                        
                        if let attachement = TaskAttachmentOperations.processAttachments(for: [node], taskId: transfer.parentNodeId).first {
                            let listNode = transfer.updateListNode(with: attachement)
                            transferDataAccessor.updateNode(node: transfer)
                            sSelf.handleSyncStatus(eventNode: listNode)
                            completionHandler(false)
                        }
                    } else {
                        AnalyticsManager.shared.apiTracker(name: Event.API.apiUploadWorkflowAttachment.rawValue, fileSize: fileSize, success: false)
                        transfer.syncStatus = .error
                        let listNode = transfer.listNode()
                        sSelf.handleSyncStatus(eventNode: listNode)
                        completionHandler(false)
                    }
                }
            } catch {
                transfer.syncStatus = .error
                sSelf.handleSyncStatus(eventNode: transfer.listNode())
                completionHandler(false)
            }
        })
    }
    
    func handleSyncStatus(eventNode: ListNode) {
        var attachments = attachments.value
        if eventNode.syncStatus != .error {
            for (index, listNode) in attachments.enumerated() where listNode.id == eventNode.id {
                attachments[index] = eventNode
                self.attachments.value = attachments
            }
            
            // Insert nodes to be uploaded
            _ = self.uploadTransferDataAccessor.queryAll(for: self.tempWorkflowId, attachmentType: .workflow) { uploadTransfers in
                self.insert(uploadTransfers: uploadTransfers)
            }
        }
    }
    
    func insert(uploadTransfers: [UploadTransfer]) {
        var attachments = attachments.value
        uploadTransfers.forEach { transfer in
            let listNode = transfer.listNode()
            if !attachments.contains(listNode) {
                attachments.insert(listNode, at: 0)
                self.attachments.value = attachments
            }
        }
    }
}

// MARK: - Sync status
extension WorkflowOperationsModel {
    func syncStatus(for node: ListNode) -> ListEntrySyncStatus {
        if node.isAFileType() && node.markedFor == .upload {
            let nodeSyncStatus = node.syncStatus
            var entryListStatus: ListEntrySyncStatus
            
            switch nodeSyncStatus {
            case .pending, .error, .inProgress:
                entryListStatus = .inProgress
            case .synced:
                entryListStatus = .uploaded
            default:
                entryListStatus = .undefined
            }
            return entryListStatus
        }
        return node.isMarkedOffline() ? .uploaded : .undefined
    }

    func startFileCoordinator(for node: ListNode, presenter: UINavigationController?) {
        if let presenter = presenter {
            let filePreviewCoordinator = FilePreviewScreenCoordinator(with: presenter,
                                                           listNode: node,
                                                           excludedActions: [.moveTrash,
                                                                             .addFavorite,
                                                                             .removeFavorite,
                                                                             .download,
                                                                             .startWorkflow,
                                                                             .renameNode,
                                                                             .more,
                                                                             .moveToFolder,
                                                                             .markOffline,
                                                                             .removeOffline,
                                                                             .permanentlyDelete],
                                                           shouldPreviewLatestContent: false,
                                                                      isLocalFilePreview: true)
            filePreviewCoordinator.start()
            self.filePreviewCoordinator = filePreviewCoordinator
        }
    }
}
