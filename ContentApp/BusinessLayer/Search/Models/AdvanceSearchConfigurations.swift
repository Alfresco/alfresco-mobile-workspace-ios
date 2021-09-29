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
class SearchConfigModel: Decodable {
    var search = [AdvanceSearchConfigurations]()
}

// MARK: Advance Search Model
class AdvanceSearchConfigurations: Decodable {
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
class SearchCategories: Decodable {
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
class SearchComponents: Decodable {
    var selector: String?
    var settings: SearchComponentSettings?
}

// MARK: Search Component Settings
class SearchComponentSettings: Decodable {
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
    var options = [SearchComponentOptions]()
    
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
    
    required init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            pattern = try? container.decode(String.self, forKey: .pattern)
            field = try? container.decode(String.self, forKey: .field)
            placeholder = try? container.decode(String.self, forKey: .placeholder)
            pageSize = try? container.decode(Int.self, forKey: .pageSize)
            searchOperator = try? container.decode(String.self, forKey: .searchOperator)
            min = try? container.decode(Int.self, forKey: .min)
            max = try? container.decode(Int.self, forKey: .max)
            step = try? container.decode(Int.self, forKey: .step)
            thumbLabel = try? container.decode(Bool.self, forKey: .thumbLabel)
            format = try? container.decode(String.self, forKey: .format)
            dateFormat = try? container.decode(String.self, forKey: .dateFormat)
            maxDate = try? container.decode(String.self, forKey: .maxDate)
            if let options = try? container.decode([SearchComponentOptions].self, forKey: .options) {
                self.options = options
            }
        }
    }
}

// MARK: Search Component Options
class SearchComponentOptions: Decodable {
    var name: String?
    var value: String?
    var isDefault: Bool? = false
    
    enum CodingKeys: String, CodingKey {
        case name
        case value
        case isDefault = "default"
    }
}
