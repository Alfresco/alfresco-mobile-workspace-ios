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

class SingleLineTextTableCellViewModel: RowViewModel {
    
    var didChangeText: ((String?) -> Void)?    
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
        return "SingleLineTextTableViewCell"
    }
    
    init(field: Field, type: ComplexFormFieldType) {
        let text = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
        self.componentID = field.id
        self.title = field.name
        self.placeholder = field.placeholder
        self.text = text
        self.type = type
        self.readOnly = ComplexFormFieldType.displayText.rawValue == type.rawValue || ComplexFormFieldType.displayValue.rawValue == type.rawValue
        self.minLength = field.minLength
        self.maxLength = field.maxLength
        self.minValue = field.minValue
        self.maxValue = field.maxValue
        self.fieldRequired = field.fieldRequired
        self.currency = field.currency
        self.enableFractions = field.enableFractions ?? false
        self.fractionLength = field.fractionLength ?? 0
    }

    func checkForErrorMessages(for text: String) {
        if type == .singleLineText {
            checkErrorForStringValue(text: text)
        } else if type == .numberField {
            checkErrorForIntegerValue(text: text)
        } else if type == .amountField {
            checkErrorForFloatValue(text: text)
        }
    }

    private func checkErrorForStringValue(text: String) {
        let numberOfChars = text.count
        if maxLength == 0 {
            errorMessage = nil
        } else if numberOfChars < minLength {
            errorMessage = "Enter atleast \(minLength) characters"
        } else if numberOfChars > maxLength {
            errorMessage = "Enter maximum \(maxLength) characters"
        } else {
            errorMessage = nil
        }
    }
    
    private func checkErrorForIntegerValue(text: String) {
        guard let maximumValue = maxValue, let minimumValue = minValue else { return }
        if !minimumValue.isEmpty {
            if text.isEmpty {
                errorMessage = nil
            } else if (text.count ) < (Int(minimumValue) ?? 0) {
                errorMessage = "Can't be less than \(minimumValue)"
            } else if (text.count) > (Int(maximumValue) ?? 0) {
                errorMessage = "Can't be greater than \(maximumValue)"
            } else {
                errorMessage = nil
            }
        }
    }
    
    private func checkErrorForFloatValue(text: String) {
        guard let maximumValue = maxValue, let minimumValue = minValue else { return }
        if !minimumValue.isEmpty {
            if text.isEmpty {
                errorMessage = nil
            } else if (Float(text) ?? 0) < (Float(minimumValue) ?? 0) {
                errorMessage = "Can't be less than \(minimumValue)"
            } else if (Float(text) ?? 0) > (Float(maximumValue) ?? 0) {
                errorMessage = "Can't be greater than \(maximumValue)"
            } else {
                errorMessage = nil
            }
        }
        
        if enableFractions && !text.isEmpty && errorMessage == nil {
            let textArray = text.components(separatedBy: ".")
            let count = textArray.count - 1
            if count > 1 {
                errorMessage = "Use a different number format"
            } else if textArray.count > 1 {
                let valueAfterDecimal = textArray[1].count
                if fractionLength != 0 && valueAfterDecimal > fractionLength {
                    errorMessage = "Use a different number format"
                }
            }
        }
    }
}
