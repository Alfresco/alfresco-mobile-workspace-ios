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
    var didSelectReadMoreActionForDescription: (() -> Void)?
    var didSelectEditTitle: (() -> Void)?
    var didSelectEditDueDate: (() -> Void)?
    var didSelectResetDueDate: (() -> Void)?
    var didSelectPriority: (() -> Void)?
    var didSelectAssignee: (() -> Void)?

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
        
        if viewModel.isTaskCompleted {
            rowViewModels.append(completedDateCellVM())
        }
        
        rowViewModels.append(dueDateCellVM())
        
        if priorityCellVM() != nil {
            rowViewModels.append(priorityCellVM()!)
        }
        
        rowViewModels.append(assignedCellVM())
        
        if !viewModel.isTaskCompleted {
            rowViewModels.append(statusCellVM())
        }
        
        rowViewModels.append(identifierCellVM())
        
        /* comments */
        if taskHeaderCellVM() != nil {
            rowViewModels.append(taskHeaderCellVM()!)
        }
        
        if latestCommentCellVM() != nil {
            rowViewModels.append(latestCommentCellVM()!)
        }
        
        if !viewModel.isTaskCompleted {
            rowViewModels.append(addCommentCellVM())
        }
        
        /* attachments */
        if viewModel.isAttachmentsLoaded {
            rowViewModels.append(spaceCellVM())
            
            if attachmentsHeaderCellVM() != nil {
                rowViewModels.append(attachmentsHeaderCellVM()!)
            }
            
            if attachmentsPlaceholderCellVM() != nil {
                rowViewModels.append(attachmentsPlaceholderCellVM()!)
            }
            
            let attachments = attachmentsCellVM()
            rowViewModels.append(contentsOf: attachments)
        }
        
        self.viewModel.rowViewModels.value = rowViewModels
    }
    
    // MARK: - Title
    private func titleCellVM() -> TitleTableCellViewModel {
        var taskDescription = viewModel.taskDescription ?? ""
        if taskDescription.isEmpty {
            taskDescription = LocalizationConstants.Tasks.noDescription
        }

        let rowVM = TitleTableCellViewModel(title: viewModel.taskName, subTitle: taskDescription, isEditMode: viewModel.isEditTask)
        rowVM.didSelectReadMoreAction = {
            self.didSelectReadMoreActionForDescription?()
        }
        rowVM.didSelectEditTitle = {
            self.didSelectEditTitle?()
        }
        return rowVM
    }
    
    private func completedDateCellVM() -> InfoTableCellViewModel {
        let rowVM = InfoTableCellViewModel(imageName: "ic-completed-task", title: LocalizationConstants.Tasks.completed, value: viewModel.geCompletedDate(), isEditMode: false)
        return rowVM
    }
    
    private func dueDateCellVM() -> InfoTableCellViewModel {
        let rowVM = InfoTableCellViewModel(imageName: "ic-calendar-icon", title: LocalizationConstants.Accessibility.dueDate, value: viewModel.getDueDate(), isEditMode: viewModel.isEditTask)
        rowVM.didSelectValue = {
            self.didSelectEditDueDate?()
        }
        rowVM.didSelectEditInfo = {
            self.didSelectResetDueDate?()
        }
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
                                                   priorityBackgroundColor: backgroundColor,
                                                   isEditMode: viewModel.isEditTask)
            rowVM.didSelectEditPriority = {
                self.didSelectPriority?()
            }
            return rowVM
        }
        return nil
    }
    
    private func assignedCellVM() -> InfoTableCellViewModel {
        let rowVM = InfoTableCellViewModel(imageName: "ic-assigned-icon", title: LocalizationConstants.Accessibility.assignee, value: viewModel.userName, isEditMode: viewModel.isEditTask)
        rowVM.didSelectEditInfo = {
            self.didSelectAssignee?()
        }
        return rowVM
    }
    
    private func statusCellVM() -> InfoTableCellViewModel {
        let rowVM = InfoTableCellViewModel(imageName: "ic-status-icon", title: LocalizationConstants.Tasks.status, value: viewModel.status, isEditMode: false)
        return rowVM
    }
    
    private func identifierCellVM() -> InfoTableCellViewModel {
        let rowVM = InfoTableCellViewModel(imageName: "ic-identifier-icon", title: LocalizationConstants.Tasks.identifier, value: viewModel.taskID, isHideDivider: false, isEditMode: false)
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
        let isHideDetailButton = commentsCount > 1 ? false:true
        let rowVM = TaskHeaderTableCellViewModel(title: LocalizationConstants.Tasks.commentsTitle,
                                                 subTitle: subTitle,
                                                 buttonTitle: LocalizationConstants.Tasks.viewAllTitle,
                                                 isHideDetailButton: isHideDetailButton)
        rowVM.viewAllAction = {
            if !self.viewModel.isEditTask {
                self.viewModel.viewAllCommentsAction?(false)
            }
        }
        return rowVM
    }
    
    private func addCommentCellVM() -> AddCommentTableCellViewModel {
        let rowVM = AddCommentTableCellViewModel()
        rowVM.addCommentAction = {
            if !self.viewModel.isEditTask {
                self.viewModel.viewAllCommentsAction?(true)
            }
        }
        return rowVM
    }
    
    private func latestCommentCellVM() -> TaskCommentTableCellViewModel? {
        if let comment = self.viewModel.latestComment {
            let rowVM = TaskCommentTableCellViewModel(userID: comment.createdBy?.assigneeID,
                                                      userName: comment.createdBy?.userName,
                                                      commentID: comment.commentID,
                                                      comment: comment.message,
                                                      dateString: comment.messageDate,
                                                      isShowReadMore: true)
            rowVM.didSelectCommentAction = {
                if !self.viewModel.isEditTask {
                    self.viewModel.viewAllCommentsAction?(false)
                }
            }
            return rowVM
        }
        
        return nil
    }
    
    // MARK: - Attachments
    private func spaceCellVM() -> TitleTableCellViewModel {
        let rowVM = TitleTableCellViewModel(title: "", subTitle: nil, isEditMode: false)
        return rowVM
    }
    
    private func attachmentsHeaderCellVM() -> TaskHeaderTableCellViewModel? {
        let attachmentsCount = viewModel.attachments.value.count
        if viewModel.isTaskCompleted && attachmentsCount == 0 {
            return nil
        }

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
            if !self.viewModel.isEditTask {
                self.viewModel.viewAllAttachmentsAction?()
            }
        }
        return rowVM
    }
    
    private func attachmentsPlaceholderCellVM() -> EmptyPlaceholderTableCellViewModel? {
        if viewModel.attachments.value.isEmpty && !viewModel.isTaskCompleted {
            let title = LocalizationConstants.Tasks.noAttachedFilesPlaceholder
            let rowVM = EmptyPlaceholderTableCellViewModel(title: title)
            return rowVM
        }
        return nil
    }
    
    private func attachmentsCellVM() -> [RowViewModel] {
        var rowVMs = [RowViewModel]()
        var attachments = viewModel.attachments.value
        let arraySlice = attachments.prefix(4)
        attachments = Array(arraySlice)
        
        if !attachments.isEmpty {
            for attachment in attachments {
                let rowVM = TaskAttachmentTableCellViewModel(name: attachment.name,
                                                             mimeType: attachment.mimeType)
                rowVM.didSelectTaskAttachment = { [weak self] in
                    guard let sSelf = self else { return }
                    if !sSelf.viewModel.isEditTask {
                        sSelf.viewModel.didSelectTaskAttachment?(attachment)
                    }
                }
                rowVMs.append(rowVM)
            }
        }
        return rowVMs
    }
    
    func updateLatestComment() {
        buildViewModel()
    }
}
