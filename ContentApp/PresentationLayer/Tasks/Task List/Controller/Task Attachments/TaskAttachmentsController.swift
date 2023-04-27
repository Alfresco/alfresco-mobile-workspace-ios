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

class TaskAttachmentsController: NSObject {
    let viewModel: TaskAttachmentsControllerViewModel
    var currentTheme: PresentationTheme?
    let uploadTransferDataAccessor = UploadTransferDataAccessor()
    internal var supportedNodeTypes: [NodeType] = []

    init(viewModel: TaskAttachmentsControllerViewModel = TaskAttachmentsControllerViewModel(), currentTheme: PresentationTheme?) {
        self.viewModel = viewModel
        self.currentTheme = currentTheme
    }
    
    func cellIdentifier(for viewModel: RowViewModel) -> String {
        switch viewModel {
        case is TaskAttachmentTableCellViewModel:
            return TaskAttachmentTableViewCell.cellIdentifier()
        default:
            fatalError("Unexpected view model type: \(viewModel)")
        }
    }
    
    // MARK: - Build View Models
    func buildViewModel() {
        var rowViewModels = [RowViewModel]()
        let attachments = attachmentsCellVM()
        rowViewModels.append(contentsOf: attachments)
        self.viewModel.rowViewModels.value = rowViewModels
    }
    
    private func attachmentsCellVM() -> [RowViewModel] {
        var rowVMs = [RowViewModel]()
        var attachments = viewModel.attachments.value
        if viewModel.attachmentType == .workflow {
            attachments = viewModel.workflowOperationsModel?.attachments.value ?? []
        }
        if !attachments.isEmpty {
            for attachment in attachments {
                var syncStatus = viewModel.syncStatus(for: attachment)
                if viewModel.attachmentType == .workflow {
                    syncStatus = viewModel.workflowOperationsModel?.syncStatus(for: attachment) ?? .inProgress
                }
                let rowVM = TaskAttachmentTableCellViewModel(name: attachment.title,
                                                             mimeType: attachment.mimeType,
                                                             syncStatus: syncStatus)
                rowVM.didSelectTaskAttachment = { [weak self] in
                    guard let sSelf = self else { return }
                    sSelf.viewModel.didSelectTaskAttachment?(attachment)
                }
                
                rowVM.didSelectDeleteAttachment = { [weak self] in
                    guard let sSelf = self else { return }
                    sSelf.viewModel.didSelectDeleteAttachment?(attachment)
                }
                
                rowVMs.append(rowVM)
            }
        }
        return rowVMs
    }
}

// MARK: - Task Attachments
extension TaskAttachmentsController: EventObservable {
    
    func registerEvents() {
        viewModel.services?.eventBusService?.register(observer: self,
                                  for: SyncStatusEvent.self,
                                  nodeTypes: [.file])
    }
    
    func handle(event: BaseNodeEvent, on queue: EventQueueType) {
        if let publishedEvent = event as? SyncStatusEvent {
            handleSyncStatus(event: publishedEvent)
        }
    }

    func handleSyncStatus(event: SyncStatusEvent) {
        if viewModel.attachmentType == .workflow {
            self.buildViewModel()
        } else {
            var attachments = viewModel.attachments.value
            let eventNode = event.node
            for (index, listNode) in attachments.enumerated() where listNode.id == eventNode.id {
                attachments[index] = eventNode
                self.viewModel.attachments.value = attachments
                self.buildViewModel()
            }
            
            // Insert nodes to be uploaded
            _ = self.uploadTransferDataAccessor.queryAll(for: viewModel.taskID, attachmentType: .task) { uploadTransfers in
                self.insert(uploadTransfers: uploadTransfers)
            }
        }
    }
    
    func insert(uploadTransfers: [UploadTransfer]) {
        var attachments = viewModel.attachments.value
        uploadTransfers.forEach { transfer in
            let listNode = transfer.listNode()
            if !attachments.contains(listNode) {
                attachments.insert(listNode, at: 0)
                self.viewModel.attachments.value = attachments
                self.buildViewModel()
            }
        }
    }
}
