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

class StartWorkflowController: NSObject {
    let viewModel: StartWorkflowViewModel
    var currentTheme: PresentationTheme?
    var didSelectReadMoreActionForDescription: (() -> Void)?
    var didSelectEditTitle: (() -> Void)?
    var didSelectEditDueDate: (() -> Void)?
    var didSelectResetDueDate: (() -> Void)?
    var didSelectPriority: (() -> Void)?
    var didSelectAssignee: (() -> Void)?
    var didSelectAddAttachment: (() -> Void)?
    
    init(viewModel: StartWorkflowViewModel = StartWorkflowViewModel(), currentTheme: PresentationTheme?) {
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
        case is AddAttachmentTableCellViewModel:
            return AddAttachmentTableViewCell.cellIdentifier()
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
        rowViewModels.append(dueDateCellVM())
        rowViewModels.append(priorityCellVM()!)
        rowViewModels.append(assignedCellVM())
        
        /* attachments */
        rowViewModels.append(spaceCellVM())
        
        if attachmentsHeaderCellVM() != nil {
            rowViewModels.append(attachmentsHeaderCellVM()!)
        }
        
        if addAttachmentCellVM() != nil {
            rowViewModels.append(addAttachmentCellVM()!)
        }
        
        if attachmentsPlaceholderCellVM() != nil {
            rowViewModels.append(attachmentsPlaceholderCellVM()!)
        }
        
        self.viewModel.rowViewModels.value = rowViewModels
    }
    
    // MARK: - Title
    private func titleCellVM() -> TitleTableCellViewModel {
        var processDescription = viewModel.processDefintionDescription
        if processDescription.isEmpty {
            processDescription = LocalizationConstants.Tasks.noDescription
        }

        let rowVM = TitleTableCellViewModel(title: viewModel.processDefintionTitle, subTitle: processDescription, isEditMode: viewModel.isEditMode)
        rowVM.didSelectReadMoreAction = {
            self.didSelectReadMoreActionForDescription?()
        }
        rowVM.didSelectEditTitle = {
            self.didSelectEditTitle?()
        }
        return rowVM
    }
    
    // MARK: - Due Date
    private func dueDateCellVM() -> InfoTableCellViewModel {
        var accesssibilityLabel: String?
        var editImage = "ic-edit-icon"
        if viewModel.dueDate != nil {
            editImage = "ic-cross-grey"
            accesssibilityLabel = LocalizationConstants.AdvanceSearch.reset
        }
        let rowVM = InfoTableCellViewModel(imageName: "ic-calendar-icon",
                                           title: LocalizationConstants.Accessibility.dueDate,
                                           value: viewModel.getDueDate(for: viewModel.dueDate),
                                           isEditMode: viewModel.isEditMode,
                                           editImage: editImage,
                                           accesssibilityLabel: accesssibilityLabel)
        rowVM.didSelectValue = { [weak self] in
            guard let sSelf = self else { return }
            sSelf.didSelectEditDueDate?()
        }
        
        rowVM.didSelectEditInfo = { [weak self] in
            guard let sSelf = self else { return }
            if sSelf.viewModel.dueDate == nil {
                sSelf.didSelectEditDueDate?()
            } else {
                sSelf.didSelectResetDueDate?()
            }
        }
        return rowVM
    }
    
    // MARK: - Priority
    private func priorityCellVM() -> PriorityTableCellViewModel? {
        if let currentTheme = self.currentTheme {
            let textColor = viewModel.getPriorityValues(for: currentTheme).textColor
            let backgroundColor = viewModel.getPriorityValues(for: currentTheme).backgroundColor
            let priorityText = viewModel.getPriorityValues(for: currentTheme).priorityText

            let rowVM = PriorityTableCellViewModel(title: LocalizationConstants.Accessibility.priority,
                                                   priority: priorityText,
                                                   priorityTextColor: textColor,
                                                   priorityBackgroundColor: backgroundColor,
                                                   isEditMode: viewModel.isEditMode)
            rowVM.didSelectEditPriority = {
                self.didSelectPriority?()
            }
            return rowVM
        }
        return nil
    }
    
    // MARK: - Assigned
    private func assignedCellVM() -> InfoTableCellViewModel {
        let rowVM = InfoTableCellViewModel(imageName: "ic-assigned-icon",
                                           title: LocalizationConstants.Accessibility.assignee,
                                           value: viewModel.userName,
                                           isEditMode: viewModel.isEditMode,
                                           editImage: "ic-edit-icon")
        rowVM.didSelectEditInfo = {
            self.didSelectAssignee?()
        }
        return rowVM
    }
    
    // MARK: - Attachments
    private func spaceCellVM() -> SpaceTableCellViewModel {
        let rowVM = SpaceTableCellViewModel()
        return rowVM
    }
    
    private func attachmentsHeaderCellVM() -> TaskHeaderTableCellViewModel? {
        let title = LocalizationConstants.Tasks.attachedFilesTitle
        let subTitle = ""
        let isHideDetailButton = true
        let rowVM = TaskHeaderTableCellViewModel(title: title,
                                                 subTitle: subTitle,
                                                 buttonTitle: LocalizationConstants.Tasks.viewAllTitle,
                                                 isHideDetailButton: isHideDetailButton)
        return rowVM
    }
    
    private func addAttachmentCellVM() -> AddAttachmentTableCellViewModel? {
        let title = LocalizationConstants.EditTask.addAttachments
        let rowVM = AddAttachmentTableCellViewModel(title: title)
        rowVM.didSelectAddAttachment = {
            self.didSelectAddAttachment?()
        }
        return rowVM
    }
    
    private func attachmentsPlaceholderCellVM() -> EmptyPlaceholderTableCellViewModel? {
        let title = LocalizationConstants.Tasks.noAttachedFilesPlaceholder
        let rowVM = EmptyPlaceholderTableCellViewModel(title: title)
        return rowVM
    }
}