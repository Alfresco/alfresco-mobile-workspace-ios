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

struct ActionsMenuGeneric {
    static func actions(for node: ListNode) -> [[ActionMenu]] {
        var actions = [[ActionMenu]]()

        let infoAction = ActionMenu(title: node.title,
                                    type: .node,
                                    icon: FileIcon.icon(for: node))
        let markOffAction = ActionMenu(title: LocalizationConstants.ActionMenu.markOffline,
                                       type: .markOffline)
        let removeOffAction = ActionMenu(title: LocalizationConstants.ActionMenu.removeOffline,
                                       type: .removeOffline)
        let addFavAction = ActionMenu(title: LocalizationConstants.ActionMenu.addFavorite,
                                      type: .addFavorite)
        let removeFavAction = ActionMenu(title: LocalizationConstants.ActionMenu.removeFavorite,
                                         type: .removeFavorite)
        let deleteAction = ActionMenu(title: LocalizationConstants.ActionMenu.moveTrash,
                                      type: .moveTrash)
        let downloadAction = ActionMenu(title: LocalizationConstants.ActionMenu.download,
                                      type: .download)

        var actions2: [ActionMenu] = []

        if node.isMarkedOffline() {
            actions2.append(removeOffAction)
        } else {
            actions2.append(markOffAction)
        }

        if node.favorite == true {
            actions2.append(removeFavAction)
        } else {
            actions2.append(addFavAction)
        }

        if node.nodeType == .site {
            if node.hasRole(to: .manager) {
                actions2.append(deleteAction)
            }
        } else {
            if node.nodeType == .file ||
                node.nodeType == .fileLink {
                actions2.append(downloadAction)
            }
            if node.hasPersmission(to: .delete) {
                actions2.append(deleteAction)
            }
        }
        let actions1 = [infoAction]

        actions.append(actions1)
        actions.append(actions2)

        return actions
    }
}
