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

class MultiLineTextTableCellViewModel: RowViewModel {
    var componentID: String?
    var title: String?
    var placeholder: String?
    var text: String?
    var readOnly = false
    var minLength = 0
    var maxLength = 0
    var errorMessage: String?
    var fieldRequired = false
    var didChangeText: ((String?) -> Void)?  
    
    var name: String? {
        if fieldRequired {
            return String(format: "%@*", title ?? "")
        } else {
            return title
        }
    }

    func cellIdentifier() -> String {
        return "MultiLineTextTableViewCell"
    }
    init(field: Field) {
        let text = ValueUnion.string(field.value?.getStringValue() ?? "").getStringValue()
        self.componentID = field.id
        self.title = field.name
        self.placeholder = field.placeholder
        self.text = text
        self.readOnly = field.readOnly
        self.minLength = field.minLength
        self.maxLength = field.maxLength
        self.fieldRequired = field.fieldRequired 
    }
    
    func checkForErrorMessages(for text: String) {
        guard maxLength != 0 else { return }
        let numberOfChars = text.count
        if numberOfChars < minLength {
            errorMessage = "Enter atleast \(minLength) characters"
        } else if numberOfChars > maxLength {
            errorMessage = "Enter maximum \(maxLength) characters"
        } else {
            errorMessage = nil
        }
    }
}
