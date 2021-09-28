//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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

// MARK: Advance Search Model
class SearchConfigModel: Codable {
    var search = [AdvanceSearchConfigurations]()
}

// MARK: Advance Search Model
class AdvanceSearchConfigurations: Codable {
    var filterWithContains: Bool?
    var resetButton: Bool?
    var name: String?
    var isDefault: Bool? = false
    var categories = [SearchCategories]()
    
    enum CodingKeys: String, CodingKey {
        case filterWithContains
        case resetButton
        case name
        case isDefault = "default"
        case categories
    }
}

// MARK: Search Categories
class SearchCategories: Codable {
    var searchID: String?
    var name: String?
    var enabled: Bool?
    var expanded: Bool?
    var component: SearchComponents?
    
    enum CodingKeys: String, CodingKey {
        case searchID = "id"
        case name
        case enabled
        case expanded
        case component
    }
}

// MARK: Search Components
class SearchComponents: Codable {
    var selector: String?
    var settings: SearchComponentSettings?
}

// MARK: Search Component Settings
class SearchComponentSettings: Codable {
    var pattern: String?
    var field: String?
    var placeholder: String?
    var pageSize: Int?
    var searchOperator: String?
    var min: Int?
    var max: Int?
    var step: Int?
    var thumbLabel: Bool?
    var format: String?
    var dateFormat: String?
    var maxDate: String?
    var options: [SearchComponentOptions]?
    
    enum CodingKeys: String, CodingKey {
        case pattern
        case field
        case placeholder
        case pageSize
        case searchOperator = "operator"
        case min
        case max
        case step
        case thumbLabel
        case format
        case dateFormat
        case maxDate
        case options
    }
}

// MARK: Search Component Options
class SearchComponentOptions: Codable {
    var name: String?
    var value: String?
    var isDefault: Bool? = false
    
    enum CodingKeys: String, CodingKey {
        case name
        case value
        case isDefault = "default"
    }
}
