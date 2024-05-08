//
// Copyright (C) 2005-2024 Alfresco Software Limited.
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

class DropDownTableViewCellViewModel: RowViewModel {
    
    var userName: String?
    var componentID: String?
    var title: String?
    var placeholder: String?
    var text: String?
    var readOnly = false
    var type: ComplexFormFieldType
    var minLength = 0
    var maxLength = 0
    var minValue: String?
    var maxValue: String?
    var errorMessage: String?
    var fieldRequired = false
    var currency: String?
    var enableFractions = false
    var fractionLength = 0
    var taskChip: TaskChipItem?
    var didChangeChip: ((TaskChipItem?) -> Void)?
    
    var name: String? {
        if fieldRequired {
            return String(format: "%@*", title ?? "")
        } else {
            return title
        }
    }
    
    var currencyForAmount: String? {
        if type == .amountField && currency == nil {
            return "USD"
        }
        return currency
    }

    var keyboardType: UIKeyboardType {
        if type == .singleLineText {
            return .default
        } else if type == .numberField {
            return .numberPad
        } else if type == .amountField {
            if enableFractions {
                return .decimalPad
            } else {
                return .numberPad
            }
        }
        return .default
    }
    
    func cellIdentifier() -> String {
        return "DropDownTableViewCell"
    }
    
    init(field: Field, type: ComplexFormFieldType) {
        let text = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
        self.componentID = field.id
        self.title = field.name
        self.placeholder = field.placeholder
        self.text = text
        self.readOnly = field.readOnly
        self.type = type
        self.minLength = field.minLength
        self.maxLength = field.maxLength
        self.minValue = field.minValue
        self.maxValue = field.maxValue
        self.fieldRequired = field.fieldRequired
        self.currency = field.currency
        self.enableFractions = field.enableFractions ?? false
        self.fractionLength = field.fractionLength ?? 0
        var isUpdateDropDown = false
        if (text?.count ?? 0) > 0 {
            if (field.value?.getDictValue() == nil) {
                isUpdateDropDown = true
            }
        }
        self.taskChip = getTaskChipItem(for: field.options ?? [], name: field.name ?? "", id: field.id, text: text ?? "", isUpdateDropDown: isUpdateDropDown, field: field)
    }
    
    private func getTaskChipItem(for options: [Option], name: String, id: String, text: String, isUpdateDropDown: Bool, field: Field) -> TaskChipItem? {
        var taskOptions = [TaskOptions]()
       
        for option in options where option.id != "empty" {
            let tOptions = TaskOptions(label: option.name,
                                            query: option.id,
                                            value: option.name,
                                            accessibilityIdentifier: option.name)
            taskOptions.append(tOptions)
            if isUpdateDropDown {
                if text == option.name {
                    let dropDown = DropDownValue(id: option.id, name: option.name)
                    field.value = .valueElementDict(dropDown)
                }
            }
        }
        
        let chip = TaskChipItem(chipId: Int(id),
                                     name: name,
                                     selectedValue: nil,
                                     componentType: nil,
                                     query: nil,
                                     options: taskOptions,
                                     accessibilityIdentifier: nil)
        
        return chip
    }

}
