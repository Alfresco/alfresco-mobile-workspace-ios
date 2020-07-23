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

enum NavigationURLPathComponentType {
    case stringValue(String)
    case placeholderValue(type: String?, value: String)
}

struct NavigationURLPathComponent {
    let type: NavigationURLPathComponentType

    init(with value: String) {
        if value.hasPrefix("<") && value.hasSuffix(">") {
            let start = value.index(after: value.startIndex)
            let end = value.index(before: value.endIndex)
            let placeholder = value[start..<end]
            let placeholderComponents = placeholder.components(separatedBy: ":")
            switch placeholderComponents.count {
            case 1:
                type = .placeholderValue(type: nil, value: placeholderComponents[0])
            case 2:
                type = .placeholderValue(type: placeholderComponents[0], value: placeholderComponents[1])
            default:
                type = .stringValue(value)
            }
        } else {
            type = .stringValue(value)
        }
    }
}
