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

struct ActionsMenuGeneric {
    
    static func actions(for node: ListNode, configData: MobileConfigData?) -> [[ActionMenu]] {
        var actions = [[ActionMenu]]()

        let infoAction = ActionMenu(title: node.title,
                                    type: .node,
                                    icon: FileIcon.icon(for: node))

        var actions2: [ActionMenu] = []

        // Append available actions to actions2
        [openWithAction(for: node, configData: configData),
         favoriteAction(for: node, configData: configData),
         startWorkflowAction(for: node, configData: configData),
         renameNodeAction(for: node, configData: configData),
         moveToFolderAction(for: node, configData: configData),
         offlineAction(for: node, configData: configData),
         deleteAction(for: node, configData: configData)].forEach {
            if let action = $0 { actions2.append(action) }
        }

        actions.append([infoAction])
        if actions2.isEmpty {
            let emptyAction = ActionMenu(title: LocalizationConstants.Workflows.workflowsUnavailableTitle, type: .empty)
            actions2.append(emptyAction)
        }
           
        actions.append(actions2)

        return actions
    }

    // MARK: - Common Helper Method

    static private func isMenuItemEnabled(configData: MobileConfigData?, id: MenuId) -> Bool {
        // Return true if configData is nil to avoid skipping actions when configData is missing
        guard let configData = configData else { return true }
        return configData.featuresMobile.menu.contains { $0.id == id && $0.enabled }
    }

    // MARK: - Action Methods

    static private func favoriteAction(for node: ListNode, configData: MobileConfigData?) -> ActionMenu? {
        let addFavoriteEnabled = isMenuItemEnabled(configData: configData, id: .addFavorite)
        let removeFavoriteEnabled = isMenuItemEnabled(configData: configData, id: .removeFavorite)
        
        // Return nil if both actions are disabled
        guard addFavoriteEnabled || removeFavoriteEnabled else {
            return nil
        }

        let isFavorite = node.favorite ?? false
        
        // Return the appropriate action based on enabled status and favorite state
        if addFavoriteEnabled && removeFavoriteEnabled {
            return isFavorite
                ? ActionMenu(title: LocalizationConstants.ActionMenu.removeFavorite, type: .removeFavorite)
                : ActionMenu(title: LocalizationConstants.ActionMenu.addFavorite, type: .addFavorite)
        }

        if addFavoriteEnabled && !isFavorite {
            return ActionMenu(title: LocalizationConstants.ActionMenu.addFavorite, type: .addFavorite)
        }

        if removeFavoriteEnabled && isFavorite {
            return ActionMenu(title: LocalizationConstants.ActionMenu.removeFavorite, type: .removeFavorite)
        }
        
        return nil
    }

    static private func offlineAction(for node: ListNode, configData: MobileConfigData?) -> ActionMenu? {
        guard !(node.markedFor == .upload && node.syncStatus != .synced),
              (node.isAFileType() || node.isAFolderType()),
              isMenuItemEnabled(configData: configData, id: .addOffline) || isMenuItemEnabled(configData: configData, id: .removeOffline) else {
            return nil
        }

        return node.isMarkedOffline() ?
            ActionMenu(title: LocalizationConstants.ActionMenu.removeOffline, type: .removeOffline) :
            ActionMenu(title: LocalizationConstants.ActionMenu.markOffline, type: .markOffline)
    }

    static private func openWithAction(for node: ListNode, configData: MobileConfigData?) -> ActionMenu? {
        guard node.isAFileType(),
              !node.allowableOperations.isEmpty,
              isMenuItemEnabled(configData: configData, id: .openWith) else {
            return nil
        }

        return ActionMenu(title: LocalizationConstants.ActionMenu.download, type: .download)
    }

    static private func deleteAction(for node: ListNode, configData: MobileConfigData?) -> ActionMenu? {
        guard !(node.markedFor == .upload && node.syncStatus != .synced),
              isMenuItemEnabled(configData: configData, id: .trash) else {
            return nil
        }

        let deleteAction = ActionMenu(title: LocalizationConstants.ActionMenu.moveTrash, type: .moveTrash)

        switch node.nodeType {
        case .site:
            return node.hasRole(to: .manager) ? deleteAction : nil
        default:
            return node.hasPersmission(to: .delete) ? deleteAction : nil
        }
    }

    static private func moveToFolderAction(for node: ListNode, configData: MobileConfigData?) -> ActionMenu? {
        guard (node.isAFileType() || node.isAFolderType()),
              !(node.markedFor == .upload && node.syncStatus != .synced),
              isMenuItemEnabled(configData: configData, id: .move) else {
            return nil
        }

        let moveAction = ActionMenu(title: LocalizationConstants.ActionMenu.moveToFolder, type: .moveToFolder)

        switch node.nodeType {
        case .site:
            return node.hasRole(to: .manager) ? moveAction : nil
        default:
            return node.hasPersmission(to: .delete) ? moveAction : nil
        }
    }

    static private func renameNodeAction(for node: ListNode, configData: MobileConfigData?) -> ActionMenu? {
        guard (node.isAFileType() || node.isAFolderType()),
              !(node.markedFor == .upload && node.syncStatus != .synced),
              isMenuItemEnabled(configData: configData, id: .rename) else {
            return nil
        }

        let renameAction = ActionMenu(title: LocalizationConstants.ActionMenu.renameNode, type: .renameNode)

        switch node.nodeType {
        case .site:
            return node.hasRole(to: .manager) ? renameAction : nil
        default:
            return node.hasPersmission(to: .delete) ? renameAction : nil
        }
    }

    static private func startWorkflowAction(for node: ListNode, configData: MobileConfigData?) -> ActionMenu? {
        guard APSService.isAPSServiceEnable ?? false,
              node.isAFileType(),
              isMenuItemEnabled(configData: configData, id: .startProcess) else {
            return nil
        }

        return ActionMenu(title: LocalizationConstants.Accessibility.startWorkflow, type: .startWorkflow)
    }
}
