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

class CheckBoxTableViewCellViewModel: RowViewModel {
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
    var isSelected = false
    var comments: [TaskCommentModel] = []
    var appDefinition: WFlowAppDefinitions?
    var didChangeValue: ((Bool?) -> Void)?

    var image: UIImage? {
        if isSelected {
            return UIImage(named: "ic-checkbox-checked")
        } else {
            return UIImage(named: "ic-checkbox-unchecked")
        }
    }
    
    var name: String? {
        if fieldRequired {
            return String(format: "%@*", title ?? "")
        } else {
            return title
        }
    }
    
    func cellIdentifier() -> String {
        return "CheckBoxTableViewCell"
    }
    
    init(field: Field, type: ComplexFormFieldType) {
        let isSelected = ValueUnion.bool(field.value?.getBoolValue() ?? Bool()).getBoolValue()
        self.isSelected = isSelected ?? Bool()
        self.componentID = field.id
        self.title = field.name
        self.placeholder = field.placeholder
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
        self.comments.append(TaskCommentModel(created: nil, createdBy: nil, commentID: nil, message: field.name ?? ""))
        self.appDefinition = WFlowAppDefinitions(addDefinitionID: 123, defaultAppId: "", name: "", description: field.name, modelId: 0, theme: "", icon: "", deploymentId: "", tenantId: 0)
    }
}
