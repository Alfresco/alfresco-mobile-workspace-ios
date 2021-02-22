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

struct NodeChildMapper {
    static func map(_ entries: [NodeChildAssociationEntry]) -> [ListNode] {
        var nodes: [ListNode] = []
        for entry in entries {
            nodes.append(self.create(from: entry.entry))
        }
        return nodes
    }

    static func create(from node: Node) -> ListNode {
        let path = node.path?.elements?.compactMap({ $0.name })
            .joined(separator: " \u{203A} ") ?? ""
        var mimeType = node.content?.mimeType
        if node.isFolder {
            mimeType = node.nodeType
        }

        return ListNode(guid: node._id,
                        mimeType: mimeType,
                        title: node.name,
                        path: path,
                        modifiedAt: node.modifiedAt,
                        nodeType: NodeType(rawValue: node.nodeType) ?? .unknown,
                        favorite: node.isFavorite,
                        allowableOperations: node.allowableOperations,
                        isFile: node.isFile,
                        isFolder: node.isFolder)
    }

    private static func create(from node: NodeChildAssociation) -> ListNode {
        let path = node.path?.elements?.compactMap({ $0.name })
            .joined(separator: " \u{203A} ") ?? ""
        var mimeType = node.content?.mimeType
        if node.isFolder {
            mimeType = node.nodeType
        }
        var destination: String?
        if case .object(let object) = node.properties,
           case .string(let value) = object["cm:destination"] {
            destination = value
        }

        return ListNode(guid: node._id,
                        parentGuid: node.parentId,
                        mimeType: mimeType,
                        title: node.name,
                        path: path,
                        modifiedAt: node.modifiedAt,
                        nodeType: NodeType(rawValue: node.nodeType) ?? .unknown,
                        favorite: node.isFavorite,
                        allowableOperations: node.allowableOperations,
                        destination: destination,
                        isFile: node.isFile,
                        isFolder: node.isFolder)
    }
}
