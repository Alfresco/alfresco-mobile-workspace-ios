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

struct ActionsMenuTrashMoreButton {
    static func actions(for node: ListNode, configData: MobileConfigData?) -> [[ActionMenu]] {
        var actions = [[ActionMenu]]()
        
        // First action: node information
        let infoAction = ActionMenu(title: node.title,
                                    type: .node,
                                    icon: FileIcon.icon(for: node))
        actions.append([infoAction])
        
        var actions2: [ActionMenu] = []
        
        // Check and add the permanently delete action if available
        if isMenuItemEnabled(configData: configData, id: .permanentlyDelete) {
            let permanentlyDeleteAction = ActionMenu(title: LocalizationConstants.ActionMenu.permanentlyDelete,
                                                     type: .permanentlyDelete)
            actions2.append(permanentlyDeleteAction)
        }
        
        // Check and add the restore action if available
        if isMenuItemEnabled(configData: configData, id: .restore) {
            let restoreAction = ActionMenu(title: LocalizationConstants.ActionMenu.restore,
                                           type: .restore)
            actions2.append(restoreAction)
        }
        
        // Append available actions
        if !actions2.isEmpty {
            actions.append(actions2)
        }
        
        return actions
    }

    // Helper function to check if a specific menu item is enabled
    static private func isMenuItemEnabled(configData: MobileConfigData?, id: MenuId) -> Bool {
        guard let configData = configData else { return true }
        return configData.featuresMobile.menu.contains { $0.id == id && $0.enabled }
    }
}
