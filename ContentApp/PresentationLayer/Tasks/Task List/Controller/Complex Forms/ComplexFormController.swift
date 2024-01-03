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
                                                     fractionLength: field.fractionLength)
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
                                                     fractionLength: field.fractionLength)
        return rowVM
    }
    
    // MARK: - Amount Text Field
    private func amountTextCellVM(for field: Field) -> SingleLineTextTableCellViewModel {
        print("---- CURRENCY ----- \(field.currency)")
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
                                                     fractionLength: field.fractionLength)
        return rowVM
    }
}
