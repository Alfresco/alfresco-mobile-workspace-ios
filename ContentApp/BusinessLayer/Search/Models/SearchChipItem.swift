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
    case library = "'cm:library'"
    case node = "'cm:node'"
    case personalFiles = "personalFiles"
    case trash = "deleted-nodes"
}

class SearchChipItem: Equatable {
    var name: String
    var type: CMType
    var selected: Bool
    var nodeSearch: String

    init(name: String, type: CMType, selected: Bool = true, nodeSearch: String = "") {
        self.name = name
        self.type = type
        self.selected = selected
        self.nodeSearch = nodeSearch
    }

    static func == (lhs: SearchChipItem, rhs: SearchChipItem) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type
    }
}
