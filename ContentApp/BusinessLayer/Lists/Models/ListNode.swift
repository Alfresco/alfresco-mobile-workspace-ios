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
import AlfrescoContent

enum ElementKindType: String {
    case file = "file"
    case folder = "folder"
    case site = "library"
}

struct ListNode: Hashable {
    var guid: String
    var title: String
    var icon: String?
    var path: String
    var modifiedAt: Date?
    var kind: ElementKindType

    static func == (lhs: ListNode, rhs: ListNode) -> Bool {
        return lhs.guid == rhs.guid &&
            lhs.title == rhs.title &&
            lhs.icon == rhs.icon &&
            lhs.path == rhs.path &&
            lhs.modifiedAt == rhs.modifiedAt &&
            lhs.kind == rhs.kind
    }
}
