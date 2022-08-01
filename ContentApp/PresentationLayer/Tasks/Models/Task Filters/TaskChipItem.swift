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

import Foundation

// MARK: Component Types for Tasks
enum TaskComponentType: String, Codable {
    case dateRange = "date-range"
    case radio = "radio"
    case text = "text"
    case none = "none"
}

class TaskChipItem: Equatable {
    var chipId: Int?
    var name: String?
    var selected = false
    var selectedValue: String?
    var componentType: TaskComponentType?
    var query: String?
    var options: [TaskOptions] = []
    var accessibilityIdentifier: String?

    init(chipId: Int?,
         name: String?,
         selected: Bool = false,
         selectedValue: String?,
         componentType: TaskComponentType?,
         query: String?,
         options: [TaskOptions],
         accessibilityIdentifier: String?) {
        
        self.chipId = chipId
        self.name = name
        self.selected = selected
        self.selectedValue = selectedValue
        self.componentType = componentType
        self.query = query
        self.options = options
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    static func == (lhs: TaskChipItem, rhs: TaskChipItem) -> Bool {
        return lhs.name == rhs.name && lhs.chipId == rhs.chipId
    }
}
