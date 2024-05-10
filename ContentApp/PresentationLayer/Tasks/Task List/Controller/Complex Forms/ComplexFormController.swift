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

class ComplexFormController: NSObject {
    let viewModel: StartWorkflowViewModel
    var currentTheme: PresentationTheme?
    lazy var complexFormViewModel = ComplexFormViewModel()
    internal var supportedNodeTypes: [NodeType] = []

    init(viewModel: StartWorkflowViewModel = StartWorkflowViewModel(), currentTheme: PresentationTheme?) {
        self.viewModel = viewModel
        self.currentTheme = currentTheme
    }
    
    func cellIdentifier(for viewModel: RowViewModel) -> String {
        switch viewModel {
        case is MultiLineTextTableCellViewModel:
            return MultiLineTextTableViewCell.cellIdentifier()
        case is SingleLineTextTableCellViewModel:
            return SingleLineTextTableViewCell.cellIdentifier()
        case is DatePickerTableViewCellViewModel:
            return DatePickerTableViewCell.cellIdentifier()
        case is AssigneeTableViewCellViewModel:
            return AssigneeTableViewCell.cellIdentifier()
        case is DropDownTableViewCellViewModel:
            return DropDownTableViewCell.cellIdentifier()
        case is HyperlinkTableViewCellViewModel:
            return HyperlinkTableViewCell.cellIdentifier()
        case is CheckBoxTableViewCellViewModel:
            return CheckBoxTableViewCell.cellIdentifier()
        case is AddAttachmentComplexTableViewCellViewModel:
            return AddAttachmentComplexTableViewCell.cellIdentifier()
        default:
            fatalError("Unexpected view model type: \(viewModel)")
        }
    }
    
    // MARK: - Build View Models
    func buildViewModel() {
        var rowViewModels = [RowViewModel]()
        let localFormFields = viewModel.formFields
        if !localFormFields.isEmpty {
            if viewModel.isAttachment {
                checkAttachments(localFormFields: localFormFields)
            }
            for field in localFormFields {
                let type = field.type
                switch type {
                case ComplexFormFieldType.multiLineText.rawValue:
                    let cellVM = multiLineTextCellVM(for: field)
                    rowViewModels.append(cellVM)
                case ComplexFormFieldType.singleLineText.rawValue:
                    let cellVM = singleLineTextCellVM(for: field)
                    rowViewModels.append(cellVM)
                case ComplexFormFieldType.numberField.rawValue:
                    let cellVM = numberTextCellVM(for: field)
                    rowViewModels.append(cellVM)
                case ComplexFormFieldType.amountField.rawValue:
                    let cellVM = amountTextCellVM(for: field)
                    rowViewModels.append(cellVM)
                case ComplexFormFieldType.displayValue.rawValue:
                    let cellVM = displayValueCellVM(for: field)
                    rowViewModels.append(cellVM)
                case ComplexFormFieldType.displayText.rawValue:
                    let cellVM = displayTextCellVM(for: field)
                    rowViewModels.append(cellVM)
                case ComplexFormFieldType.date.rawValue:
                    let cellVM = dateCellVM(for: field)
                    rowViewModels.append(cellVM)
                case ComplexFormFieldType.dateTime.rawValue:
                    let cellVM = dateTimeCellVM(for: field)
                    rowViewModels.append(cellVM)
                case ComplexFormFieldType.people.rawValue:
                    let cellVM = peopleCellVM(for: field)
                    rowViewModels.append(cellVM)
                case ComplexFormFieldType.group.rawValue:
                    let cellVM = groupCellVM(for: field)
                    rowViewModels.append(cellVM)
                case ComplexFormFieldType.dropDown.rawValue:
                    let cellVM = dropDownCellVM(for: field)
                    rowViewModels.append(cellVM)
                case ComplexFormFieldType.radioButton.rawValue:
                    let cellVM = radioButtonCellVM(for: field)
                    rowViewModels.append(cellVM)
                case ComplexFormFieldType.hyperlink.rawValue:
                    let cellVM = hyperlinkCellVM(for: field)
                    rowViewModels.append(cellVM)
                case ComplexFormFieldType.checkbox.rawValue:
                    let cellVM = checkBoxCellVM(for: field)
                    rowViewModels.append(cellVM)
                case ComplexFormFieldType.upload.rawValue:
                    let cellVM = attachmentCellVM(for: field)
                    rowViewModels.append(cellVM)
                case ComplexFormFieldType.selectfolder.rawValue:
                    let cellVM = attachmentCellVM(for: field)
                    rowViewModels.append(cellVM)
                default:
                    AlfrescoLog.debug("No matching field")
                }
                
                self.viewModel.rowViewModels.value = rowViewModels
            }
        }
    }
    
    private func checkAttachments(localFormFields: [Field]) {
        // Filter the upload fields
        let uploadFields = localFormFields.filter { $0.type == ComplexFormFieldType.upload.rawValue }
        
        if !uploadFields.isEmpty {
            // Check the multipal value for all upload fields
            let multipalValues = uploadFields.map { $0.params?.multipal ?? false }
            
            let falseValues = multipalValues.filter { !$0 }
            
            if !falseValues.isEmpty {
                // Condition: multipalValues contains one or more false values
                print("multipalValues contains one or more false values")
                // Insert field.value = "ABC" on the first false value
                if let index = multipalValues.firstIndex(where: { !$0 }) {
                    self.updateAttachment(uploadFields: uploadFields, index: index)
                }
            } else {
                // Condition: multipalValues contains only true values
                print("multipalValues contains only true values")
                // Insert field.value = "ABC" on the first true value
                if let index = multipalValues.firstIndex(where: { $0 }) {
                    self.updateAttachment(uploadFields: uploadFields, index: index)
                }
            }
        } else {
            // Upload field is not available
            print("Upload field is not available")
            Snackbar.display(with: LocalizationConstants.Workflows.notAbleToAttachTheSelectedContent,
                             type: .error,
                             automaticallyDismisses: true, finish: nil)
        }
    }
    
    private func updateAttachment(uploadFields: [Field], index: Int) {
        let attachments = viewModel.workflowOperationsModel?.attachments.value ?? []
        if let firstAttachment = attachments.first {
            let value = TaskAttachmentOperations.processWorkflowAttachmentszFromValueElement(for: firstAttachment, taskId: "")
            uploadFields[index].value = .valueElementArray([value])
        }
    }

    // MARK: - Multi Line Text View
    private func multiLineTextCellVM(for field: Field) -> MultiLineTextTableCellViewModel {
        let rowVM = MultiLineTextTableCellViewModel(field: field)
        rowVM.didChangeText = { [weak self] (text) in
            guard let enterText = text else { return }
            self?.updateText(for: field, text: enterText)
        }
        return rowVM
    }
    
    // MARK: - Single Line Text Field
    private func singleLineTextCellVM(for field: Field) -> SingleLineTextTableCellViewModel {
        let rowVM = SingleLineTextTableCellViewModel(field: field, type: .singleLineText)
        rowVM.didChangeText = { [weak self] (text) in
            guard let enterText = text else { return }
            self?.updateText(for: field, text: enterText)
        }
        return rowVM
    }
    
    // MARK: - Number Text Field
    private func numberTextCellVM(for field: Field) -> SingleLineTextTableCellViewModel {
        let rowVM = SingleLineTextTableCellViewModel(field: field, type: .numberField)
        rowVM.didChangeText = { [weak self] (text) in
            guard let enterText = text else { return }
            self?.updateText(for: field, text: enterText)
        }
        return rowVM
    }
    
    // MARK: - Amount Text Field
    private func amountTextCellVM(for field: Field) -> SingleLineTextTableCellViewModel {
        let rowVM = SingleLineTextTableCellViewModel(field: field, type: .amountField)
        rowVM.didChangeText = { [weak self] (text) in
            guard let enterText = text else { return }
            self?.updateText(for: field, text: enterText)
        }
        return rowVM
    }
    
    // MARK: - Display Value Field
    private func displayValueCellVM(for field: Field) -> SingleLineTextTableCellViewModel {
        let rowVM = SingleLineTextTableCellViewModel(field: field, type: .displayValue)
        return rowVM
    }
    
    // MARK: - Display Text Field
    private func displayTextCellVM(for field: Field) -> SingleLineTextTableCellViewModel {
        let rowVM = SingleLineTextTableCellViewModel(field: field, type: .displayText)
        return rowVM
    }
    
    // MARK: - Display Date Time
    private func dateTimeCellVM(for field: Field) -> DatePickerTableViewCellViewModel {
        let rowVM = DatePickerTableViewCellViewModel(field: field, type: .dateTime)
        rowVM.didChangeText = { [weak self] (text) in
            guard let enterText = text else { return }
            self?.updateText(for: field, text: enterText)
        }
        return rowVM
    }
    
    // MARK: - Display Date
    private func dateCellVM(for field: Field) -> DatePickerTableViewCellViewModel {
        let rowVM = DatePickerTableViewCellViewModel(field: field, type: .date)
        rowVM.didChangeText = { [weak self] (text) in
            guard let enterText = text else { return }
            self?.updateText(for: field, text: enterText)
        }
        return rowVM
    }
    
    // MARK: - Assignee User
    private func peopleCellVM(for field: Field) -> AssigneeTableViewCellViewModel {
        let rowVM = AssigneeTableViewCellViewModel(field: field, type: .people)
        rowVM.didChangeAssignee = { [weak self] (assignee) in
            guard let selectedAssignee = assignee else { return }
            self?.updateAssignee(for: field, assignee: selectedAssignee)
        }
        return rowVM
    }
    
    // MARK: - Assignee Group
    private func groupCellVM(for field: Field) -> AssigneeTableViewCellViewModel {
        let rowVM = AssigneeTableViewCellViewModel(field: field, type: .group)
        rowVM.didChangeAssignee = { [weak self] (assignee) in
            guard let selectedAssignee = assignee else { return }
            self?.updateAssignee(for: field, assignee: selectedAssignee)
        }
        return rowVM
    }
    
    // MARK: - Drop Down
    private func dropDownCellVM(for field: Field) -> DropDownTableViewCellViewModel {
        let rowVM = DropDownTableViewCellViewModel(field: field, type: .dropDown)
        rowVM.didChangeChip = { [weak self] (taskChip) in
            guard let selectedChip = taskChip else { return }
            self?.updateChip(for: field, selectedChip: selectedChip)
        }
        return rowVM
    }
    
    // MARK: - Radio Button
    private func radioButtonCellVM(for field: Field) -> DropDownTableViewCellViewModel {
        let rowVM = DropDownTableViewCellViewModel(field: field, type: .radioButton)
        rowVM.didChangeChip = { [weak self] (taskChip) in
            guard let selectedChip = taskChip else { return }
            self?.updateChip(for: field, selectedChip: selectedChip)
        }
        return rowVM
    }
    
    // MARK: - Hyperlink
    private func hyperlinkCellVM(for field: Field) -> HyperlinkTableViewCellViewModel {
        let rowVM = HyperlinkTableViewCellViewModel(field: field, type: .hyperlink)
        return rowVM
    }
    
    // MARK: - CheckBox
    private func checkBoxCellVM(for field: Field) -> CheckBoxTableViewCellViewModel {
        let rowVM = CheckBoxTableViewCellViewModel(field: field, type: .checkbox)
        rowVM.didChangeValue = { [weak self] (isSelected) in
            guard let self = self else { return }
            guard let checkBoxValue = isSelected else { return }
            field.value = .bool(checkBoxValue)
            self.checkRequiredTextField()
        }
        return rowVM
    }
    
    // MARK: - Attachment
    private func attachmentCellVM(for field: Field) -> AddAttachmentComplexTableViewCellViewModel {
        let rowVM = AddAttachmentComplexTableViewCellViewModel(field: field, type: .checkbox, isComplexFirstTime: viewModel.isComplexFirstTime)
        rowVM.didChangeText = { [weak self] (text) in
            guard let enterText = text else { return }
            self?.updateText(for: field, text: enterText)
        }
        return rowVM
    }
    
    // MARK: - Changed text
    fileprivate func updateText(for field: Field, text: String) {
        let type = ComplexFormFieldType(rawValue: field.type)
        
        if type == .amountField || type == .numberField {
            field.value = .int(Int(text) ?? 0)
        } else {
            field.value = .string(text)
        }
        self.checkRequiredTextField()
    }
    
    // MARK: - Update DropDown
    fileprivate func updateChip(for field: Field, selectedChip: TaskChipItem) {
        selectedChip.options.filter { $0.isSelected }.forEach { [weak self] option in
            guard let self = self else { return }
            let dropDown = DropDownValue(id: option.query ?? "", name: option.value ?? "")
            field.value = .valueElementDict(dropDown)
            self.checkRequiredTextField()
        }
    }
    
    // MARK: - Update Assignee
    fileprivate func updateAssignee(for field: Field, assignee: TaskNodeAssignee) {
        
        let taskAssignee = TaskAssignee(assigneeID: assignee.assigneeID, firstName: assignee.firstName, lastName: assignee.lastName, email: assignee.email, groupName: assignee.groupName, externalId: assignee.externalId, status: assignee.status, parentGroupId: assignee.parentGroupId)
        field.value = .assignee(taskAssignee)
        self.checkRequiredTextField()
    }
    
    func checkRequiredTextField() {
        complexFormViewModel.checkRequiredField(formFields: self.viewModel.formFields, completion: {[weak self] value in
            if value {
                self?.viewModel.isEnabledButton.value = true
            } else {
                self?.viewModel.isEnabledButton.value = false
            }
        })
    }
}
