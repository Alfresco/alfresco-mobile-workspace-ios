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
    case file
    case folder
    case site
}

class ListNode: Hashable {
    var guid: String
    var mimeType: String?
    var title: String
    var path: String
    var modifiedAt: Date?
    var kind: ElementKindType
    var favorite: Bool

    func hash(into hasher: inout Hasher) {
        hasher.combine(guid)
    }

    init(guid: String,
         mimeType: String? = nil,
         title: String, path: String,
         modifiedAt: Date? = nil,
         kind: ElementKindType,
         favorite: Bool) {

        self.guid = guid
        self.mimeType = mimeType
        self.title = title
        self.path = path
        self.modifiedAt = modifiedAt
        self.kind = kind
        self.favorite = favorite
    }

    static func == (lhs: ListNode, rhs: ListNode) -> Bool {
        return lhs.guid == rhs.guid
    }
}
