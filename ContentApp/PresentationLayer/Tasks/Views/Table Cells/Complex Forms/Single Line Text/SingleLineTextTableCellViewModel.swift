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
    var isHiddenSelectBtn = true
    var attachments = [ListNode]()
    var appDefinition: WFlowAppDefinitions?
    var field: Field
    
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
        self.field = field
        let text = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
        let parmsType = field.params?.field?.type ?? ""
        
        var stringText = ""
        switch type {
        case .displayText, .displayValue:
            if let fieldType = FieldType(rawValue: parmsType) {
                switch fieldType {
                case .date:
                    stringText = DateFormatterUtility.formattedDateString(from: text ?? "", dateTime: false)
                case .dateTime:
                    stringText = DateFormatterUtility.formattedDateString(from: text ?? "", dateTime: true)
                case .integer, .amount:
                    let intText = ValueUnion.int(field.value?.getIntValue() ?? 0).getIntValue()
                    stringText = String(intText ?? 0)
                case .bool:
                    let boolText = ValueUnion.bool(field.value?.getBoolValue() ?? false).getBoolValue()
                    stringText = String(boolText ?? false)
                case .string:
                    stringText = text ?? ""
                case .people:
                    stringText = Self.getUserName(field: field)
                case .upload:
                    stringText = Self.getAttachmentsCount(for: field, attachments: &attachments, isHiddenSelectBtn: &isHiddenSelectBtn)
                case .text, .multilineText:
                    isHiddenSelectBtn = false
                    stringText = text ?? ""
                    self.appDefinition = WFlowAppDefinitions(addDefinitionID: 123, defaultAppId: "", name: "", description: stringText, modelId: 0, theme: "", icon: "", deploymentId: "", tenantId: 0)
                }
            } else {
                stringText = text ?? ""
            }
        default:
            stringText = text ?? ""
        }
        
        self.text = stringText
        self.componentID = field.id
        self.placeholder = field.name
        self.title = field.name
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
    
    static private func getUserName(field: Field) -> String {
        var localUserName = ""
        if let assignee = field.value?.getAssignee() {
            if let apsUserID = UserProfile.apsUserID {
                if assignee.id == apsUserID {
                    let name = LocalizationConstants.EditTask.meTitle
                    localUserName = name
                } else {
                    if let groupName = assignee.groupName, !groupName.isEmpty {
                        localUserName = groupName
                    } else {
                        localUserName = assignee.userName ?? ""
                    }
                }
            }
        }
        return localUserName
    }
    
    static func getAttachmentsCount(for field: Field, attachments: inout [ListNode], isHiddenSelectBtn: inout Bool) -> String {
        if let assignee = field.value?.getValueElementArray() {
            attachments = TaskAttachmentOperations.processWorkflowAttachments(for: assignee, taskId: "")
            if (attachments.count) > 0 {
                isHiddenSelectBtn = false
                return String(format: LocalizationConstants.Tasks.multipleAttachmentsTitle, assignee.count)
            } else {
                isHiddenSelectBtn = true
                return String(format: LocalizationConstants.Tasks.noAttachedFilesPlaceholder)
            }
        }
        return ""
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
            errorMessage = String(format: LocalizationConstants.Workflows.enterAtleastCharacters,
                                  minLength)
        } else if numberOfChars > maxLength {
            errorMessage = String(format: LocalizationConstants.Workflows.enterMaximumCharacters,
                                  maxLength)
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
                errorMessage = String(format: LocalizationConstants.Workflows.cannotBeLessThan, minimumValue)
            } else if (text.count) > (Int(maximumValue) ?? 0) {
                errorMessage = String(format: LocalizationConstants.Workflows.cannotBeGreaterThan, maximumValue)
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
                errorMessage = String(format: LocalizationConstants.Workflows.cannotBeLessThan, minimumValue)
            } else if (Float(text) ?? 0) > (Float(maximumValue) ?? 0) {
                errorMessage = String(format: LocalizationConstants.Workflows.cannotBeGreaterThan, maximumValue)
            } else {
                errorMessage = nil
            }
        }
        
        if enableFractions && !text.isEmpty {
            let textArray = text.components(separatedBy: ".")
            let count = textArray.count - 1
            if count > 1 {
                errorMessage = LocalizationConstants.Workflows.useADifferentNumberFormat
            } else if textArray.count > 1 {
                let valueAfterDecimal = textArray[1].count
                if fractionLength != 0 && valueAfterDecimal > fractionLength {
                    errorMessage = LocalizationConstants.Workflows.useADifferentNumberFormat
                }
            }
        }
    }
}
