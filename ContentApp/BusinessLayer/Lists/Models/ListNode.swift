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

enum ElementKindType {
    case file
    case folder
    case site
}

struct ListNode {
    var title: String
    var icon: String
    var path: String
    var modifiedAt: Date?
    var kind: ElementKindType

    init(with node: ResultNode) {
        self.title = node.name
        self.icon = node.content?.mimeType ?? "ic-other"
        if node.isFolder {
            self.icon = node.nodeType
            self.kind = .folder
        } else {
            self.kind = .file
        }
        self.path = node.path?.elements?.compactMap({ $0.name }).joined(separator: " \u{203A} ") ?? ""
        self.modifiedAt = node.modifiedAt
    }

    init(with node: FavoriteTargetNode) {
        self.title = node.name
        self.icon = node.content?.mimeType ?? "ic-other"
        self.path = node.path?.elements?.compactMap({ $0.name }).joined(separator: " \u{203A} ") ?? ""
        self.modifiedAt = node.modifiedAt
        if node.isFolder {
            self.icon = "cm:folder"
            self.kind = .folder
        } else {
            self.kind = .file
        }
    }

    init(with node: Site) {
        self.title = node.title
        self.icon = "cm:site"
        self.path = ""
        self.kind = .site
    }

    static func nodes(_ entries: [SiteEntry]) -> [ListNode] {
        var nodes: [ListNode] = []
        for entry in entries {
            nodes.append(ListNode(with: entry.entry))
        }
        return nodes
    }

    static func nodes(_ entries: [ResultSetRowEntry]) -> [ListNode] {
        var nodes: [ListNode] = []
        for entry in entries {
            nodes.append(ListNode(with: entry.entry))
        }
        return nodes
    }

    static func nodes(_ entries: [FavoriteEntry]) -> [ListNode] {
        var nodes: [ListNode] = []
        for entry in entries {
            if let nodeFile = entry.entry.target.file {
                nodes.append(ListNode(with: nodeFile))
            } else if let nodeFolder = entry.entry.target.folder {
                nodes.append(ListNode(with: nodeFolder))
            } else if let nodeSite = entry.entry.target.site {
                nodes.append(ListNode(with: nodeSite))
            }
        }
        return nodes
    }
}
