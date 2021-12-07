//
// Copyright (C) 2005-2020 Alfresco Software Limited.
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

enum CMType: String {
    case file = "'cm:content'"
    case folder = "'cm:folder'"
    case library = "'st:site'"
    case node = "'cm:node'"
    case none = "none"
}

// MARK: Component Types for Advance Search
enum ComponentType: String {
    case text = "text"
    case checkList = "check-list"
    case contentSize = "slider"
    case contentSizeRange = "number-range"
    case createdDateRange = "date-range"
    case radio = "radio"
    case facetField = "search-facet-field"
    case facetQuery = "search-facet-query"
    case facetInterval = "search-facet-interval"
    case none = "none"
}

class SearchChipItem: Equatable {
    var name: String
    var type: CMType
    var selected: Bool
    var searchInNodeID: String
    var selectedValue: String
    var componentType: ComponentType?
    var query: String?
    
    init(name: String, type: CMType = .none, selected: Bool = true, nodeID: String = "", selectedValue: String = "", componentType: ComponentType? = nil, query: String? = nil) {
        self.name = name
        self.type = type
        self.selected = selected
        self.searchInNodeID = nodeID
        self.selectedValue = selectedValue
        self.componentType = componentType
        self.query = query
    }

    static func == (lhs: SearchChipItem, rhs: SearchChipItem) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type
    }
}
