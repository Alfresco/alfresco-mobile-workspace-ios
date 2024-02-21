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
        default:
            fatalError("Unexpected view model type: \(viewModel)")
        }
    }
    
    // MARK: - Build View Models
    func buildViewModel() {
        var rowViewModels = [RowViewModel]()
        for field in viewModel.formFields {
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
            default:
                AlfrescoLog.debug("No matching field")
            }
            
            self.viewModel.rowViewModels.value = rowViewModels
        }
    }
    
    // MARK: - Multi Line Text View
    private func multiLineTextCellVM(for field: Field) -> MultiLineTextTableCellViewModel {
        let rowVM = MultiLineTextTableCellViewModel(field: field)
        return rowVM
    }
    
    // MARK: - Single Line Text Field
    private func singleLineTextCellVM(for field: Field) -> SingleLineTextTableCellViewModel {
        let rowVM = SingleLineTextTableCellViewModel(field: field, type: .singleLineText)
        return rowVM
    }
    
    // MARK: - Number Text Field
    private func numberTextCellVM(for field: Field) -> SingleLineTextTableCellViewModel {
        let rowVM = SingleLineTextTableCellViewModel(field: field, type: .numberField)
        return rowVM
    }
    
    // MARK: - Amount Text Field
    private func amountTextCellVM(for field: Field) -> SingleLineTextTableCellViewModel {
        let rowVM = SingleLineTextTableCellViewModel(field: field, type: .amountField)
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
        return rowVM
    }
    
    // MARK: - Display Date
    private func dateCellVM(for field: Field) -> DatePickerTableViewCellViewModel {
        let rowVM = DatePickerTableViewCellViewModel(field: field, type: .date)
        return rowVM
    }
    
    // MARK: - Assignee User
    private func peopleCellVM(for field: Field) -> AssigneeTableViewCellViewModel {
        let rowVM = AssigneeTableViewCellViewModel(field: field, type: .people)
        return rowVM
    }
    
    // MARK: - Assignee Group
    private func groupCellVM(for field: Field) -> AssigneeTableViewCellViewModel {
        let rowVM = AssigneeTableViewCellViewModel(field: field, type: .group)
        return rowVM
    }
    // MARK: - Drop Down
    private func dropDownCellVM(for field: Field) -> DropDownTableViewCellViewModel {
        let rowVM = DropDownTableViewCellViewModel(field: field, type: .dropDown)
        return rowVM
    }
}
