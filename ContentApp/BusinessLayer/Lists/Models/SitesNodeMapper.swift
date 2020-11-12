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

struct SitesNodeMapper {
    static func map(_ entries: [SiteEntry]) -> [ListNode] {
        var nodes: [ListNode] = []
        for entry in entries {
            nodes.append(self.create(from: entry.entry))
        }
        return nodes
    }

    static func map(_ entries: [SiteRoleEntry]) -> [ListNode] {
        var nodes: [ListNode] = []
        for entry in entries {
            nodes.append(self.create(from: entry.entry.site))
        }
        return nodes
    }

    private static func create(from node: Site) -> ListNode {
        return ListNode(guid: node.guid,
                        siteID: node._id,
                        mimeType: "st:site",
                        title: node.title,
                        path: "",
                        modifiedAt: nil,
                        kind: .site,
                        siteRole: node.role?.rawValue)
    }
}
