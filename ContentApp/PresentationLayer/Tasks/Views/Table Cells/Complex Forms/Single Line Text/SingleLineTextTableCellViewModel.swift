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
    var keyboardType: UIKeyboardType {
        if type == .singleLineText {
            return .default
        } else if type == .numberField {
            return .numberPad
        } else if type == .amountField {
            return .decimalPad
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
         type: ComplexFormFieldType) {
        self.componentID = componentID
        self.title = title
        self.placeholder = placeholder
        self.text = text
        self.readOnly = readOnly
        self.type = type
    }
}
