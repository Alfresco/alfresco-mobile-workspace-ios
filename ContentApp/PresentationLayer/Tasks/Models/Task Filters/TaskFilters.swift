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

// MARK: Task Filters
class Filter: Codable {
    var filters = [TasksFilters]()
}
class TasksFilters: Codable {
    var filterID: Int?
    var name: String?
    var selector: TaskComponentType?
    var options: [TaskOptions]?
    var query: String?
    var value: String?
    var isSelected = false
    var accessibilityIdentifier: String?
    
    enum CodingKeys: String, CodingKey {
        case filterID = "id"
        case name
        case selector
        case options
        case query
        case value
        case accessibilityIdentifier
    }
}

class TaskOptions: Codable {
    var label: String?
    var query: String?
    var value: String?
    var isSelected = false
    var accessibilityIdentifier: String?
    
    enum CodingKeys: String, CodingKey {
        case label
        case query
        case value
        case accessibilityIdentifier
    }
}

