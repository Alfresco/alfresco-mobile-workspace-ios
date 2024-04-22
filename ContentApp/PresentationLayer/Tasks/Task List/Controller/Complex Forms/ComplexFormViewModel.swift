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
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class ComplexFormViewModel: NSObject {
    var selectedDateTimeTextField: MDCOutlinedTextField!
    var selectedDateTextField: MDCOutlinedTextField!
    var services: CoordinatorServices?
    let isLoading = Observable<Bool>(true)
    var formData: StartFormFields?
    
    func isoDateFormat() -> ISO8601DateFormatter {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }
    
    func selectedDateString(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yy"
        return dateFormatter.string(from: date)
    }
    
    func selectedDateTimeString(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yy HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    func convertStringToDateTime(dateStr: String) -> Date? {
        // Create an instance of DateFormatter
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        // Convert the string to a Date object
        return formatter.date(from: dateStr)
    }
    func convertStringToDate(dateStr: String) -> Date? {
        // Create an instance of DateFormatter
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        // Convert the string to a Date object
        return formatter.date(from: dateStr)
    }
    
    func checkRequiredField(formFields: [Field], completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            
            guard let sself = self else { return } // Unwrap weak self

            // Check if all required fields have non-empty entered values
            let allRequiredFieldsNonEmpty = formFields.allSatisfy { field in
                let type = ComplexFormFieldType(rawValue: field.type)
                switch type {
                case .amountField, .numberField:
                    let text = ValueUnion.int(field.value?.getIntValue() ?? 0).getIntValue()
                    return !field.fieldRequired || sself.checkIntegerValue(minValue: field.minValue ?? "", maxValue: field.maxValue ?? "", text: String(text ?? 0))
                    
                case .checkbox:
                    // For boolean fields, no need to check if they are required or have non-empty entered values
                    return true
                    
                case .radioButton, .dropDown:
                    if let dictValue = field.value?.getDictValue() {
                        let value = ValueUnion.valueElementDict(dictValue).getDictValue()
                        return !field.fieldRequired || !(value?.name.isEmpty ?? true)
                    } else {
                        return false
                    }
                    
                case .people, .group:
                    if let assignee = field.value?.getAssignee() {
                        let value = ValueUnion.assignee(assignee).getAssignee()
                        return !field.fieldRequired || !(value?.id == -1)
                    } else {
                        return false
                    }
                    
                case .upload:
                    let text = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
                    return sself.checkAttachFiles(text: text, field: field)

                default:
                    // For other types of fields, check if they are required and have non-empty entered values
                    let text = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
                    return !field.fieldRequired || sself.checkErrorForStringValue(minLength: field.minLength, maxLength: field.maxLength, text: text ?? "")
                }
            }
            // Call the completion handler with the result
            completion(allRequiredFieldsNonEmpty)
        }
    }
    
    private func checkAttachFiles(text: String?, field: Field) -> Bool {
        // Split text by comma and remove empty values
        let values = text?.split(separator: ",").filter { !$0.isEmpty }

        if field.fieldRequired {
            // If field is required, check if any non-zero value is present
            if let nonZeroValues = values?.filter({ $0 != "0" }), !nonZeroValues.isEmpty {
                // At least one non-zero value is found
                return true
            } else {
                // No non-zero value found, or text is empty
                return false
            }
        } else {
            // If field is not required, return true if any non-empty value is present
            return true
        }
    }
    
    private func checkErrorForStringValue(minLength: Int, maxLength: Int, text: String) -> Bool {
        let numberOfChars = text.count
        
        // Check if maxLength is 0 (indicating no maximum length)
        if maxLength == 0 {
            return numberOfChars > 0
        }
        
        // Check if numberOfChars is within the specified range
        return numberOfChars >= minLength && numberOfChars <= maxLength
    }

    private func checkIntegerValue(minValue: String, maxValue: String, text: String) -> Bool {
        if !minValue.isEmpty {
            if text.isEmpty {
                return true
            } else if (Int(text) ?? 0) < (Int(minValue) ?? 0) {
               return false
            } else if (Int(text) ?? 0) > (Int(maxValue) ?? 0) {
                return false
            } else {
                return true
            }
        }
        return true
    }
}

// MARK: - Start Workflow
extension ComplexFormViewModel {
    
    func startWorkflowProcess(for formFields: [Field], name: String, processDefinitionId: String, completionHandler: @escaping (_ isError: Bool) -> Void) {
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: {[weak self] authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            guard let sSelf = self else { return }
            let params = sSelf.startWorkFlowParams(for: formFields, name: name, processDefinitionId: processDefinitionId )
            ProcessAPI.startWorkFlowProcess(params: params) { data, error in
                sSelf.isLoading.value = false
                if error == nil {
                    completionHandler(false)
                } else {
                    completionHandler(true)
                }
            }
        })
    }

    private func startWorkFlowParams(for formFields: [Field], name: String, processDefinitionId: String) -> StartWorkFlowBodyCreate {
        let name = name
        let processDefinitionId = processDefinitionId
        var params = [String: AnyEncodable]()
        for field in formFields {
            let key = field.id
            let type = ComplexFormFieldType(rawValue: field.type)
            var localParams: [String: AnyEncodable]
            switch type {
            case .amountField, .numberField:
                let value = ValueUnion.int(field.value?.getIntValue() ?? 0).getIntValue()
                localParams = [key: AnyEncodable(value ?? 0)]
            case .checkbox:
                let value = ValueUnion.bool(field.value?.getBoolValue() ?? false).getBoolValue()
                localParams = [key: AnyEncodable(value ?? false)]
            case .radioButton, .dropDown:
                if let dictValue = field.value?.getDictValue() {
                    let value = ValueUnion.valueElementDict(dictValue).getDictValue()
                    localParams = [key: AnyEncodable(value)]
                } else {
                    localParams = [:]
                }
            case .people, .group:
                if let assignee = field.value?.getAssignee() {
                    let value = ValueUnion.assignee(assignee).getAssignee()
                    localParams = [key: AnyEncodable(value)]
                } else {
                    localParams = [:]
                }
            default:
                let value = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
                localParams = [key: AnyEncodable(value ?? "")]
            }
            // Append localParams to params
            params.merge(localParams) { (_, new) in new }
        }
        return StartWorkFlowBodyCreate(name: name,
                                       processDefinitionId: processDefinitionId,
                                       params: params)
    }
}
