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

class WflowTaskDetailController: NSObject {
    let viewModel: WflowTaskDetailViewModel
    var currentTheme: PresentationTheme?
    var didSelectReadMoreActionForDescription: (() -> Void)?
    var didSelectWorkflowTasksStatus: (() -> Void)?

    init(viewModel: WflowTaskDetailViewModel = WflowTaskDetailViewModel(), currentTheme: PresentationTheme?) {
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
        case is TaskHeaderTableCellViewModel:
            return TaskHeaderTableViewCell.cellIdentifier()
        case is EmptyPlaceholderTableCellViewModel:
            return EmptyPlaceholderTableViewCell.cellIdentifier()
        case is TaskAttachmentTableCellViewModel:
            return TaskAttachmentTableViewCell.cellIdentifier()
        case is SpaceTableCellViewModel:
            return SpaceTableViewCell.cellIdentifier()
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
        
        if statusCellVM() != nil {
            rowViewModels.append(statusCellVM()!)
        }
        
        /* attachments */
        rowViewModels.append(spaceCellVM())
        
        if attachmentsHeaderCellVM() != nil {
            rowViewModels.append(attachmentsHeaderCellVM()!)
        }
        
        if attachmentsPlaceholderCellVM() != nil {
            rowViewModels.append(attachmentsPlaceholderCellVM()!)
        }
        
        let attachments = attachmentsCellVM()
        rowViewModels.append(contentsOf: attachments)
        
        self.viewModel.rowViewModels.value = rowViewModels
    }
    
    // MARK: - Title
    private func titleCellVM() -> TitleTableCellViewModel {
        var taskDescription = viewModel.workflowtaskDescription ?? ""
        if taskDescription.isEmpty {
            taskDescription = LocalizationConstants.Tasks.noDescription
        }

        let rowVM = TitleTableCellViewModel(title: viewModel.workflowTaskName, subTitle: taskDescription, isEditMode: false)
        rowVM.didSelectReadMoreAction = {
            self.didSelectReadMoreActionForDescription?()
        }
        return rowVM
    }
    
    private func completedDateCellVM() -> InfoTableCellViewModel {
        let rowVM = InfoTableCellViewModel(imageName: "ic-completed-task", title: LocalizationConstants.Tasks.completed, value: viewModel.geCompletedDate(), isEditMode: false, editImage: nil)
        return rowVM
    }
    
    private func dueDateCellVM() -> InfoTableCellViewModel {
        let rowVM = InfoTableCellViewModel(imageName: "ic-calendar-icon",
                                           title: LocalizationConstants.Accessibility.dueDate,
                                           value: viewModel.getDueDate(for: viewModel.workflowTaskDueDate),
                                           isEditMode: false,
                                           editImage: nil,
                                           accesssibilityLabel: nil)
        return rowVM
    }
    
    private func priorityCellVM() -> PriorityTableCellViewModel? {
        if let currentTheme = self.currentTheme, let taskPriority = viewModel.taskPriorityValue {
            let textColor = UIFunction.getPriorityValues(for: currentTheme, taskPriority: taskPriority).textColor
            let backgroundColor = UIFunction.getPriorityValues(for: currentTheme, taskPriority: taskPriority).backgroundColor
            let priorityText = UIFunction.getPriorityValues(for: currentTheme, taskPriority: taskPriority).priorityText

            let rowVM = PriorityTableCellViewModel(title: LocalizationConstants.Accessibility.priority,
                                                   priority: priorityText,
                                                   priorityTextColor: textColor,
                                                   priorityBackgroundColor: backgroundColor,
                                                   isEditMode: false)
            return rowVM
        }
        return nil
    }
    
    private func assignedCellVM() -> InfoTableCellViewModel {
        let rowVM = InfoTableCellViewModel(imageName: "ic-assigned-icon",
                                           title: LocalizationConstants.Accessibility.assignee,
                                           value: viewModel.userName,
                                           isEditMode: false,
                                           editImage: nil)
        return rowVM
    }
    
    private func statusCellVM() -> InfoTableCellViewModel? {
        let status = viewModel.workflowStatus ?? ""
        if !status.isEmpty {
            let rowVM = InfoTableCellViewModel(imageName: "ic-workflow-status-icon",
                                               title: LocalizationConstants.Tasks.status,
                                               value: viewModel.workflowStatus,
                                               isEditMode: true,
                                               editImage: "ic-next")
            rowVM.didSelectEditInfo = {[weak self] in
                guard let sSelf = self else { return }
                sSelf.didSelectWorkflowTasksStatus?()
            }
            rowVM.didSelectValue = {[weak self] in
                guard let sSelf = self else { return }
                sSelf.didSelectWorkflowTasksStatus?()
            }
            return rowVM
        }
        return nil
    }
    
    // MARK: - Attachments
    private func spaceCellVM() -> SpaceTableCellViewModel {
        let rowVM = SpaceTableCellViewModel()
        return rowVM
    }
    
    private func attachmentsHeaderCellVM() -> TaskHeaderTableCellViewModel? {
        let attachmentsCount = viewModel.workflowTaskAttachments.count
        let title = LocalizationConstants.Tasks.attachedFilesTitle
        var subTitle = String(format: LocalizationConstants.Tasks.multipleAttachmentsTitle, attachmentsCount)
        if attachmentsCount < 2 {
            subTitle = ""
        }
        let isHideDetailButton = attachmentsCount > 4 ? false:true
        let rowVM = TaskHeaderTableCellViewModel(title: title,
                                                 subTitle: subTitle,
                                                 buttonTitle: LocalizationConstants.Tasks.viewAllTitle,
                                                 isHideDetailButton: isHideDetailButton)
        rowVM.viewAllAction = {
            self.viewModel.viewAllAttachmentsAction?()
        }
        return rowVM
    }
    
    private func attachmentsPlaceholderCellVM() -> EmptyPlaceholderTableCellViewModel? {
        if viewModel.workflowTaskAttachments.isEmpty {
            let title = LocalizationConstants.Tasks.noAttachedFilesPlaceholder
            let rowVM = EmptyPlaceholderTableCellViewModel(title: title)
            return rowVM
        }
        return nil
    }
    
    private func attachmentsCellVM() -> [RowViewModel] {
        var rowVMs = [RowViewModel]()
        var attachments = viewModel.workflowTaskAttachments
        let arraySlice = attachments.prefix(4)
        attachments = Array(arraySlice)
        
        if !attachments.isEmpty {
            for attachment in attachments {
                let rowVM = TaskAttachmentTableCellViewModel(name: attachment.title,
                                                             mimeType: attachment.mimeType,
                                                             syncStatus: .uploaded,
                                                             isHideAllOptionsFromRight: true)
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
