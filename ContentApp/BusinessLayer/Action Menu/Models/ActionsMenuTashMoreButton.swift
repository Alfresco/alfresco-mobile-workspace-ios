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

struct ActionsMenuTrashMoreButton {
    static func actions(for node: ListNode) -> [[ActionMenu]] {
        var actions = [[ActionMenu]]()
        let infoAction = ActionMenu(title: node.title,
                                    type: .node,
                                    icon: FileIcon.icon(for: node.mimeType))
        let permanentlyDeleteAction = ActionMenu(title: LocalizationConstants.ActionMenu.permanentlyDelete,
                                      type: .permanentlyDelete)
        let restoreAction = ActionMenu(title: LocalizationConstants.ActionMenu.restore,
                                         type: .restore)

        let actions1 = [infoAction]
        let actions2: [ActionMenu] = [permanentlyDeleteAction, restoreAction]

        actions.append(actions1)
        actions.append(actions2)
        return actions
    }
}
