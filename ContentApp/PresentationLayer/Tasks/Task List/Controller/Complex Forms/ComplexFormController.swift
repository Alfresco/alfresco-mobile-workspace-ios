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
            default:
                AlfrescoLog.debug("No matching field")
            }
            
            self.viewModel.rowViewModels.value = rowViewModels
        }
    }
    
    // MARK: - Multi Line Text View
    private func multiLineTextCellVM(for field: Field) -> MultiLineTextTableCellViewModel {
        let text = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
        let rowVM = MultiLineTextTableCellViewModel(componentID: field.id,
                                                    title: field.name,
                                                    placeholder: field.placeholder,
                                                    text: text,
                                                    readOnly: field.readOnly,
                                                    minLength: field.minLength,
                                                    maxLength: field.maxLength, 
                                                    fieldRequired: field.fieldRequired)
        return rowVM
    }
    
    // MARK: - Single Line Text Field
    private func singleLineTextCellVM(for field: Field) -> SingleLineTextTableCellViewModel {
        let text = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
        let rowVM = SingleLineTextTableCellViewModel(componentID: field.id,
                                                     title: field.name,
                                                     placeholder: field.placeholder,
                                                     text: text,
                                                     readOnly: field.readOnly,
                                                     type: .singleLineText,
                                                     minLength: field.minLength,
                                                     maxLength: field.maxLength,
                                                     minValue: field.minValue,
                                                     maxValue: field.maxValue,
                                                     fieldRequired: field.fieldRequired,
                                                     currency: field.currency,
                                                     enableFractions: field.enableFractions,
                                                     fractionLength: field.params?.fractionLength)
        return rowVM
    }
    
    // MARK: - Number Text Field
    private func numberTextCellVM(for field: Field) -> SingleLineTextTableCellViewModel {
        let text = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
        let rowVM = SingleLineTextTableCellViewModel(componentID: field.id,
                                                     title: field.name,
                                                     placeholder: field.placeholder,
                                                     text: text,
                                                     readOnly: field.readOnly,
                                                     type: .numberField,
                                                     minLength: field.minLength,
                                                     maxLength: field.maxLength,
                                                     minValue: field.minValue,
                                                     maxValue: field.maxValue,
                                                     fieldRequired: field.fieldRequired,
                                                     currency: field.currency,
                                                     enableFractions: field.enableFractions,
                                                     fractionLength: field.params?.fractionLength)
        return rowVM
    }
    
    // MARK: - Amount Text Field
    private func amountTextCellVM(for field: Field) -> SingleLineTextTableCellViewModel {
        let text = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
        let rowVM = SingleLineTextTableCellViewModel(componentID: field.id,
                                                     title: field.name,
                                                     placeholder: field.placeholder,
                                                     text: text,
                                                     readOnly: field.readOnly,
                                                     type: .amountField,
                                                     minLength: field.minLength,
                                                     maxLength: field.maxLength,
                                                     minValue: field.minValue,
                                                     maxValue: field.maxValue,
                                                     fieldRequired: field.fieldRequired,
                                                     currency: field.currency,
                                                     enableFractions: field.enableFractions,
                                                     fractionLength: field.params?.fractionLength)
        return rowVM
    }
    
    // MARK: - Display Value Field
    private func displayValueCellVM(for field: Field) -> SingleLineTextTableCellViewModel {
        let text = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
        let type = field.type
        var readOnly = false
        if type == ComplexFormFieldType.displayValue.rawValue {
            readOnly = true
        }
        let rowVM = SingleLineTextTableCellViewModel(componentID: field.id,
                                                     title: field.name,
                                                     placeholder: field.placeholder,
                                                     text: text,
                                                     readOnly: readOnly,
                                                     type: .displayValue,
                                                     minLength: field.minLength,
                                                     maxLength: field.maxLength,
                                                     minValue: field.minValue,
                                                     maxValue: field.maxValue,
                                                     fieldRequired: field.fieldRequired,
                                                     currency: field.currency,
                                                     enableFractions: field.enableFractions,
                                                     fractionLength: field.params?.fractionLength)
        return rowVM
    }
    
    // MARK: - Display Text Field
    private func displayTextCellVM(for field: Field) -> SingleLineTextTableCellViewModel {
        let text = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
        let type = field.type
        var readOnly = false
        if type == ComplexFormFieldType.displayText.rawValue {
            readOnly = true
        }
        let rowVM = SingleLineTextTableCellViewModel(componentID: field.id,
                                                     title: field.name,
                                                     placeholder: field.placeholder,
                                                     text: text,
                                                     readOnly: readOnly,
                                                     type: .displayText,
                                                     minLength: field.minLength,
                                                     maxLength: field.maxLength,
                                                     minValue: field.minValue,
                                                     maxValue: field.maxValue,
                                                     fieldRequired: field.fieldRequired,
                                                     currency: field.currency,
                                                     enableFractions: field.enableFractions,
                                                     fractionLength: field.params?.fractionLength)
        return rowVM
    }
    
    // MARK: - Display Date Time
    private func dateTimeCellVM(for field: Field) -> DatePickerTableViewCellViewModel {
        let text = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
        let rowVM = DatePickerTableViewCellViewModel(componentID: field.id,
                                                     title: field.name,
                                                     placeholder: field.placeholder,
                                                     text: text,
                                                     readOnly: field.readOnly,
                                                     type: .dateTime,
                                                     minLength: field.minLength,
                                                     maxLength: field.maxLength,
                                                     minValue: field.minValue,
                                                     maxValue: field.maxValue,
                                                     fieldRequired: field.fieldRequired,
                                                     currency: field.currency,
                                                     enableFractions: field.enableFractions,
                                                     fractionLength: field.params?.fractionLength)
        return rowVM
    }
    
    // MARK: - Display Date
    private func dateCellVM(for field: Field) -> DatePickerTableViewCellViewModel {
        let text = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
        let rowVM = DatePickerTableViewCellViewModel(componentID: field.id,
                                                     title: field.name,
                                                     placeholder: field.placeholder,
                                                     text: text,
                                                     readOnly: field.readOnly,
                                                     type: .date,
                                                     minLength: field.minLength,
                                                     maxLength: field.maxLength,
                                                     minValue: field.minValue,
                                                     maxValue: field.maxValue,
                                                     fieldRequired: field.fieldRequired,
                                                     currency: field.currency,
                                                     enableFractions: field.enableFractions,
                                                     fractionLength: field.params?.fractionLength)
        return rowVM
    }
    
    // MARK: - Assignee User
    private func peopleCellVM(for field: Field) -> AssigneeTableViewCellViewModel {
        let text = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
        let rowVM = AssigneeTableViewCellViewModel(componentID: field.id,
                                                     title: field.name,
                                                     placeholder: field.placeholder,
                                                     text: text,
                                                     readOnly: field.readOnly,
                                                     type: .people,
                                                     minLength: field.minLength,
                                                     maxLength: field.maxLength,
                                                     minValue: field.minValue,
                                                     maxValue: field.maxValue,
                                                     fieldRequired: field.fieldRequired,
                                                     currency: field.currency,
                                                     enableFractions: field.enableFractions,
                                                     fractionLength: field.params?.fractionLength)
        return rowVM
    }
    
    // MARK: - Assignee Group
    private func groupCellVM(for field: Field) -> AssigneeTableViewCellViewModel {
        let text = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
        let rowVM = AssigneeTableViewCellViewModel(componentID: field.id,
                                                     title: field.name,
                                                     placeholder: field.placeholder,
                                                     text: text,
                                                     readOnly: field.readOnly,
                                                     type: .group,
                                                     minLength: field.minLength,
                                                     maxLength: field.maxLength,
                                                     minValue: field.minValue,
                                                     maxValue: field.maxValue,
                                                     fieldRequired: field.fieldRequired,
                                                     currency: field.currency,
                                                     enableFractions: field.enableFractions,
                                                     fractionLength: field.params?.fractionLength)
        return rowVM
    }
}
