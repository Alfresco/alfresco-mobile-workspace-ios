//
// Copyright (C) 2005-2023 Alfresco Software Limited.
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

struct MultipleFileActionsMenuTrashMoreButton {
    
    static func actions(for nodes: [ListNode], configData: MobileConfigData?) -> [[ActionMenu]] {
        var actions = [[ActionMenu]]()

        let infoAction = ActionMenu(title: String(format: LocalizationConstants.MultipleFilesSelection.multipleItemsCount, nodes.count),
                                    type: .node,
                                    icon: nil)

        var actions2: [ActionMenu] = []

        // Append available actions
        [permanentlyDeleteAction(configData: configData),
         restoreAction(configData: configData)].forEach {
            if let action = $0 { actions2.append(action) }
        }

        actions.append([infoAction])
        actions.append(actions2)
        return actions
    }

    // MARK: - Helper Methods

    static private func isMenuItemEnabled(configData: MobileConfigData?, id: MenuId) -> Bool {
        // If configData is nil, assume all actions are allowed (skip config check)
        guard let configData = configData else { return true }
        return configData.featuresMobile.menu.contains { $0.id == id && $0.enabled }
    }

    // MARK: - Action Methods

    static private func permanentlyDeleteAction(configData: MobileConfigData?) -> ActionMenu? {
        guard isMenuItemEnabled(configData: configData, id: .permanentlyDelete) else {
            return nil
        }
        return ActionMenu(title: LocalizationConstants.ActionMenu.permanentlyDelete, type: .permanentlyDelete)
    }

    static private func restoreAction(configData: MobileConfigData?) -> ActionMenu? {
        guard isMenuItemEnabled(configData: configData, id: .restore) else {
            return nil
        }
        return ActionMenu(title: LocalizationConstants.ActionMenu.restore, type: .restore)
    }
}
