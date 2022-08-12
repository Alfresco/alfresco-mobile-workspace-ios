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

class TaskDetailController: NSObject {
    let viewModel: TaskDetailViewModel
    var currentTheme: PresentationTheme?

    init(viewModel: TaskDetailViewModel = TaskDetailViewModel(), currentTheme: PresentationTheme?) {
        self.viewModel = viewModel
        self.currentTheme = currentTheme
    }
    
    func cellIdentifier(for viewModel: RowViewModel) -> String {
        switch viewModel {
        case is TitleTableCellViewModel:
            return TitleTableViewCell.cellIdentifier()
        case is InfoTableCellViewModel:
            return InfoTableViewCell.cellIdentifier()
        case is PriorityTableCellViewModel:
            return PriorityTableViewCell.cellIdentifier()
        case is AddCommentTableCellViewModel:
            return AddCommentTableViewCell.cellIdentifier()
        case is TaskCommentTableCellViewModel:
            return TaskCommentTableViewCell.cellIdentifier()
        case is TaskHeaderTableCellViewModel:
            return TaskHeaderTableViewCell.cellIdentifier()
        case is EmptyPlaceholderTableCellViewModel:
            return EmptyPlaceholderTableViewCell.cellIdentifier()
        case is TaskAttachmentTableCellViewModel:
            return TaskAttachmentTableViewCell.cellIdentifier()
        default:
            fatalError("Unexpected view model type: \(viewModel)")
        }
    }
    
    // MARK: - Build View Models
    func buildViewModel() {
        var rowViewModels = [RowViewModel]()
        rowViewModels.append(titleCellVM())
        rowViewModels.append(dueDateCellVM())
        
        if priorityCellVM() != nil {
            rowViewModels.append(priorityCellVM()!)
        }

        rowViewModels.append(assignedCellVM())
        rowViewModels.append(statusCellVM())
        rowViewModels.append(identifierCellVM())
         
        if taskHeaderCellVM() != nil {
            rowViewModels.append(taskHeaderCellVM()!)
        }
        
        if lastestCommentCellVM() != nil {
            rowViewModels.append(lastestCommentCellVM()!)
        }
        
        rowViewModels.append(addCommentCellVM())
        rowViewModels.append(attachmentsHeaderCellVM())
        
        if attachmentsPlaceholderCellVM() != nil {
            rowViewModels.append(attachmentsPlaceholderCellVM()!)
        }
        
        let attachments = attachmentsCellVM()
        rowViewModels.append(contentsOf: attachments)
        self.viewModel.rowViewModels.value = rowViewModels
    }
    
    private func titleCellVM() -> TitleTableCellViewModel {
        let rowVM = TitleTableCellViewModel(title: viewModel.taskName)
        return rowVM
    }

    private func dueDateCellVM() -> InfoTableCellViewModel {
        let rowVM = InfoTableCellViewModel(imageName: "ic-calendar-icon", title: LocalizationConstants.Accessibility.dueDate, value: viewModel.getDueDate())
        return rowVM
    }
    
    private func priorityCellVM() -> PriorityTableCellViewModel? {
        if let currentTheme = self.currentTheme {
            let textColor = viewModel.getPriorityValues(for: currentTheme).textColor
            let backgroundColor = viewModel.getPriorityValues(for: currentTheme).backgroundColor
            let priorityText = viewModel.getPriorityValues(for: currentTheme).priorityText

            let rowVM = PriorityTableCellViewModel(title: LocalizationConstants.Accessibility.priority,
                                                   priority: priorityText,
                                                   priorityTextColor: textColor,
                                                   priorityBackgroundColor: backgroundColor)
            return rowVM
        }
        return nil
    }
    
    private func assignedCellVM() -> InfoTableCellViewModel {
        let rowVM = InfoTableCellViewModel(imageName: "ic-assigned-icon", title: LocalizationConstants.Accessibility.assignee, value: viewModel.userName)
        return rowVM
    }
    
    private func statusCellVM() -> InfoTableCellViewModel {
        let rowVM = InfoTableCellViewModel(imageName: "ic-status-icon", title: LocalizationConstants.Tasks.status, value: viewModel.status)
        return rowVM
    }
    
    private func identifierCellVM() -> InfoTableCellViewModel {
        let rowVM = InfoTableCellViewModel(imageName: "ic-identifier-icon", title: LocalizationConstants.Tasks.identifier, value: viewModel.taskID, isHideDivider: false)
        return rowVM
    }
    
    // MARK: - Comments
    private func taskHeaderCellVM() -> TaskHeaderTableCellViewModel? {
        let commentsCount = viewModel.comments.value.count
        if commentsCount == 0 {
            return nil
        }
        var subTitle = String(format: LocalizationConstants.Tasks.multipleCommentTitle, commentsCount)
        if commentsCount < 2 {
            subTitle = ""
        }
        let isHideDetailButton = commentsCount == 0 ? true:false
        let rowVM = TaskHeaderTableCellViewModel(title: LocalizationConstants.Tasks.commentsTitle,
                                                 subTitle: subTitle,
                                                 buttonTitle: LocalizationConstants.Tasks.viewAllTitle,
                                                 isHideDetailButton: isHideDetailButton)
        rowVM.viewAllAction = {
            self.viewModel.viewAllCommentsAction?(false)
        }
        return rowVM
    }
    
    private func addCommentCellVM() -> AddCommentTableCellViewModel {
        let rowVM = AddCommentTableCellViewModel()
        rowVM.addCommentAction = {
            self.viewModel.viewAllCommentsAction?(true)
        }
        return rowVM
    }
    
    private func lastestCommentCellVM() -> TaskCommentTableCellViewModel? {
        if let comment = self.viewModel.comments.value.last {
            let rowVM = TaskCommentTableCellViewModel(userID: comment.createdBy?.assigneeID,
                                                      userName: comment.createdBy?.userName,
                                                      commentID: comment.commentID,
                                                      comment: comment.message,
                                                      dateString: comment.messageDate,
                                                      isShowReadMore: true)
            rowVM.didSelectCommentAction = {
                self.viewModel.viewAllCommentsAction?(false)
            }
            return rowVM
        }
        
        return nil
    }
    
    // MARK: - Attachments
    private func attachmentsHeaderCellVM() -> TaskHeaderTableCellViewModel {
        let attachmentsCount = viewModel.attachments.value.count
        let title = LocalizationConstants.Tasks.attachedFilesTitle
        var subTitle = String(format: LocalizationConstants.Tasks.multipleAttachmentsTitle, attachmentsCount)
        if attachmentsCount < 2 {
            subTitle = ""
        }
        let isHideDetailButton = attachmentsCount > 4 ? false:true
        let rowVM = TaskHeaderTableCellViewModel(title: title ,
                                                 subTitle: subTitle,
                                                 buttonTitle: LocalizationConstants.Tasks.viewAllTitle,
                                                 isHideDetailButton: isHideDetailButton)
        rowVM.viewAllAction = {
            self.viewModel.viewAllAttachmentsAction?()
        }
        return rowVM
    }
    
    private func attachmentsPlaceholderCellVM() -> EmptyPlaceholderTableCellViewModel? {
        if viewModel.attachments.value.isEmpty {
            let title = LocalizationConstants.Tasks.noAttachedFilesPlaceholder
            let rowVM = EmptyPlaceholderTableCellViewModel(title: title)
            return rowVM
        }
        return nil
    }
    
    private func attachmentsCellVM() -> [RowViewModel] {
        var rowVMs = [RowViewModel]()
        let attachments = viewModel.attachments.value
        if !attachments.isEmpty {
            for attachment in attachments {
                let rowVM = TaskAttachmentTableCellViewModel(attachment: attachment)
                rowVMs.append(rowVM)
            }
        }
        return rowVMs
    }
}
