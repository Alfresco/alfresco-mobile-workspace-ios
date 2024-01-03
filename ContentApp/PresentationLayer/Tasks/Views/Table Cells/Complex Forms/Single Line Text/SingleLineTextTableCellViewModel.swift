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

class SingleLineTextTableCellViewModel: RowViewModel {
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
    
    init(componentID: String?,
         title: String?,
         placeholder: String?,
         text: String?,
         readOnly: Bool = false,
         type: ComplexFormFieldType,
         minLength: Int?,
         maxLength: Int?,
         minValue: String?,
         maxValue: String?,
         fieldRequired: Bool?,
         currency: String?,
         enableFractions: Bool?,
         fractionLength: Int?) {
        self.componentID = componentID
        self.title = title
        self.placeholder = placeholder
        self.text = text
        self.readOnly = readOnly
        self.type = type
        self.minLength = minLength ?? 0
        self.maxLength = maxLength ?? 0
        self.minValue = minValue
        self.maxValue = maxValue
        self.fieldRequired = fieldRequired ?? false
        self.currency = currency
        self.enableFractions = enableFractions ?? false
        self.fractionLength = fractionLength ?? 0
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
            } else if (Int(text) ?? 0) < (Int(minimumValue) ?? 0) {
                errorMessage = "Can't be less than \(minimumValue)"
            } else if (Int(text) ?? 0) > (Int(maximumValue) ?? 0) {
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
    }
}
