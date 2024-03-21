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
        DispatchQueue.global(qos: .background).async { [] in
            // Check if all required fields have non-empty entered values
            let allRequiredFieldsNonEmpty = formFields.allSatisfy { field in
                if field.type == "boolean" {
                    // For boolean fields, no need to check if they are required or have non-empty entered values
                    return true
                } else {
                    // For other types of fields, check if they are required and have non-empty entered values
                    let text = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
                    return !field.fieldRequired || !(text?.isEmpty ?? true)
                }
                
            }
            // Call the completion handler with the result
            completion(allRequiredFieldsNonEmpty)
        }
    }
}
