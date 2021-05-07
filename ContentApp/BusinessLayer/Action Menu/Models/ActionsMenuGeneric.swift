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

        let infoAction = ActionMenu(title: node.name,
                                    type: .node,
                                    icon: FileIcon.icon(for: node))

        var actions2: [ActionMenu] = []

        if let action = offlineAction(for: node) {
            actions2.append(action)
        }
        actions2.append(favoriteAction(for: node))

        if let action = downloadAction(for: node) {
            actions2.append(action)
        }

        if let action = deleteAction(for: node) {
            actions2.append(action)
        }

        actions.append([infoAction])
        actions.append(actions2)

        return actions
    }

    // MARK: Private Helpers

    static private func favoriteAction(for node: ListNode) -> ActionMenu {
        let addFavAction = ActionMenu(title: LocalizationConstants.ActionMenu.addFavorite,
                                      type: .addFavorite)
        let removeFavAction = ActionMenu(title: LocalizationConstants.ActionMenu.removeFavorite,
                                         type: .removeFavorite)
        return (node.favorite == true) ? removeFavAction : addFavAction
    }

    static private func offlineAction(for node: ListNode) -> ActionMenu? {
        let markOffAction = ActionMenu(title: LocalizationConstants.ActionMenu.markOffline,
                                       type: .markOffline)
        let removeOffAction = ActionMenu(title: LocalizationConstants.ActionMenu.removeOffline,
                                       type: .removeOffline)
        let enableAction = node.isAFileType() || node.isAFolderType()

        if enableAction {
            return node.isMarkedOffline() ? removeOffAction : markOffAction
        }

        return nil
    }

    static private func downloadAction(for node: ListNode) -> ActionMenu? {
        let downloadAction = ActionMenu(title: LocalizationConstants.ActionMenu.download,
                                      type: .download)
        if node.isAFileType() {
            return downloadAction
        }

        return nil
    }

    static private func deleteAction(for node: ListNode) -> ActionMenu? {
        let deleteAction = ActionMenu(title: LocalizationConstants.ActionMenu.moveTrash,
                                      type: .moveTrash)
        switch node.nodeType {
        case .site:
            return node.hasRole(to: .manager) ? deleteAction : nil
        default:
            return node.hasPersmission(to: .delete) ? deleteAction : nil
        }
    }
}
