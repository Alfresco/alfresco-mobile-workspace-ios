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
        let attachments = viewModel.attachments.value
        
        var isFirst = false
        var isLast = false
        if !attachments.isEmpty {
            for index in 0 ..< attachments.count {
                if index == 0 {
                    isFirst = true
                } else if index == attachments.count - 1 {
                    isLast = true
                }
            
                let attachment = attachments[index]
                let rowVM = TaskAttachmentTableCellViewModel(attachment: attachment,
                                                             isFirst: isFirst,
                                                             isLast: isLast)
                rowVM.didSelectTaskAttachment = { [weak self] in
                    guard let sSelf = self else { return }
                    sSelf.viewModel.didSelectTaskAttachment?(attachment)
                }
                rowVMs.append(rowVM)
            }
        }
        return rowVMs
    }
}
