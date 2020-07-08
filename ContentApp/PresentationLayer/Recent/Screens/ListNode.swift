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
import AlfrescoContentServices

struct ListNode {
    var node: ResultNode
    var title: String
    var path: String?
    var mimeType: String?

    init(node: ResultNode) {
        self.node = node
        self.title = node.name
        self.mimeType = node.content?.mimeType
        if node.isFolder {
            self.mimeType = node.nodeType
        }
        self.path = node.path?.elements?.compactMap({ $0.name }).joined(separator: " \u{203A} ") ?? ""
    }

    static func nodes(_ entries: [ResultSetRowEntry]) -> [ListNode] {
        var nodes: [ListNode] = []
        for entry in entries {
            nodes.append(ListNode(node: entry.entry))
        }
        return nodes
    }
}
