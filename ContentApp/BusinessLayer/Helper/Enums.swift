//
// Copyright (C) 2005-2022 Alfresco Software Limited.
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

// MARK: - Task Priority
enum TaskPriority: String {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

// MARK: - Enum Attachment Type
enum AttachmentType: String, Codable {
    case task = "task"
    case workflow = "workflow"
    case content = "content"
}

// MARK: - Complex Form Fields
enum ComplexFormFieldType: String {
    case multiLineText = "multi-line-text"
    case singleLineText = "text"
    case numberField = "integer"
    case amountField = "amount"
    case displayValue = "readonly"
    case displayText = "readonly-text"
    case dateTime = "datetime"
    case date = "date"
    case people = "people"
    case group = "functional-group"
    case dropDown = "dropdown"
    case radioButton = "radio-buttons"
    case hyperlink = "hyperlink"
    case checkbox = "boolean"
}
