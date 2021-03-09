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

struct SharedLinkMapper {
    static func map(_ entries: [SharedLinkEntry]) -> [ListNode] {
        var nodes: [ListNode] = []
        for entry in entries {
            nodes.append(self.create(from: entry.entry))
        }
        return nodes
    }

    private static func create(from node: SharedLink) -> ListNode {
        let path = node.path?.elements?.compactMap({ $0.name })
            .joined(separator: " \u{203A} ") ?? ""

        return ListNode(guid: node.nodeId ?? "",
                        mimeType: node.content?.mimeType,
                        title: node.name ?? "",
                        path: path,
                        modifiedAt: node.modifiedAt,
                        nodeType: .file,
                        favorite: node.isFavorite,
                        allowableOperations: node.allowableOperations ?? [])
    }
}
