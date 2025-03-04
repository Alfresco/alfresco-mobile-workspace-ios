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
import UIKit
import AlfrescoContent

struct MultipleFilesActionMenuGeneric {
    
    static func actions(for nodes: [ListNode], configData: MobileConfigData?) -> [[ActionMenu]] {
        var actions = [[ActionMenu]]()

        let infoAction = ActionMenu(title: String(format: LocalizationConstants.MultipleFilesSelection.multipleItemsCount, nodes.count),
                                    type: .node,
                                    icon: nil)

        var multipleActions: [ActionMenu] = []

        // Append available actions
        [favoriteAction(for: nodes, configData: configData),
         startWorkflowAction(for: nodes, configData: configData),
         moveToFolderAction(for: nodes, configData: configData),
         offlineAction(for: nodes, configData: configData),
         deleteAction(for: nodes, configData: configData)].forEach {
            if let action = $0 { multipleActions.append(action) }
        }

        actions.append([infoAction])
        actions.append(multipleActions)

        return actions
    }

    // MARK: - Helper Methods

    static private func isMenuItemEnabled(configData: MobileConfigData?, id: MenuId) -> Bool {
        // If configData is nil, assume all actions are allowed (skip config check)
        guard let configData = configData else { return true }
        return configData.featuresMobile.menu.contains { $0.id == id && $0.enabled }
    }

    static func getFilteredNodes(for nodes: [ListNode]) -> [ListNode] {
        return nodes.filter { (($0.markedFor != .upload || $0.markedFor == .undefined) && ($0.syncStatus == .synced || $0.syncStatus == .undefined)) || ($0.markedFor == .upload && $0.syncStatus == .synced) }
    }

    // MARK: - Action Methods

    static func favoriteAction(for nodes: [ListNode], configData: MobileConfigData?) -> ActionMenu? {
        // Check if either addFavorite or removeFavorite is enabled
        let addFavoriteEnabled = isMenuItemEnabled(configData: configData, id: .addFavorite)
        let removeFavoriteEnabled = isMenuItemEnabled(configData: configData, id: .removeFavorite)

        // Return nil if both are disabled
        guard addFavoriteEnabled || removeFavoriteEnabled else {
            return nil
        }

        // Get filtered nodes
        let filteredNodes = getFilteredNodes(for: nodes)
        if filteredNodes.isEmpty { return nil }

        // Determine if add or remove favorite action is needed
        let hasNonFavoriteNode = filteredNodes.contains { $0.favorite == false || $0.favorite == nil }
        let hasFavoriteNode = filteredNodes.contains { $0.favorite == true }

        if addFavoriteEnabled && removeFavoriteEnabled {
            // When both add and remove favorite are enabled, return based on node's current favorite status
            return hasNonFavoriteNode
                ? ActionMenu(title: LocalizationConstants.ActionMenu.addFavorite, type: .addFavorite)
                : ActionMenu(title: LocalizationConstants.ActionMenu.removeFavorite, type: .removeFavorite)
        }

        if addFavoriteEnabled {
            // Only return add favorite if there's any non-favorite node
            return hasNonFavoriteNode
                ? ActionMenu(title: LocalizationConstants.ActionMenu.addFavorite, type: .addFavorite)
                : nil
        }

        if removeFavoriteEnabled {
            // Only return remove favorite if there's any favorite node
            return hasFavoriteNode
                ? ActionMenu(title: LocalizationConstants.ActionMenu.removeFavorite, type: .removeFavorite)
                : nil
        }

        // Return nil if neither add nor remove favorite is enabled
        return nil

    }

    static func offlineAction(for nodes: [ListNode], configData: MobileConfigData?) -> ActionMenu? {
        // Check if either addOffline or removeOffline is enabled
        let addOfflineEnabled = isMenuItemEnabled(configData: configData, id: .addOffline)
        let removeOfflineEnabled = isMenuItemEnabled(configData: configData, id: .removeOffline)
        
        // Return nil if both are disabled
        guard addOfflineEnabled || removeOfflineEnabled else {
            return nil
        }

        // Filter nodes based on their status and type
        let filteredNodes = nodes.filter {
            ($0.syncStatus == .synced || $0.syncStatus == .undefined || $0.syncStatus == .pending || ($0.isAFolderType() && $0.isMarkedOffline())) &&
            ($0.isAFileType() || $0.isAFolderType())
        }
        if filteredNodes.isEmpty { return nil }

        // Determine if the mark or remove offline action is needed
        let hasOfflineNode = filteredNodes.contains { $0.isMarkedOffline() }
        
        if addOfflineEnabled && removeOfflineEnabled {
            return hasOfflineNode
                ? ActionMenu(title: LocalizationConstants.ActionMenu.removeOffline, type: .removeOffline)
                : ActionMenu(title: LocalizationConstants.ActionMenu.markOffline, type: .markOffline)
        }
        
        if addOfflineEnabled && !hasOfflineNode {
            return ActionMenu(title: LocalizationConstants.ActionMenu.markOffline, type: .markOffline)
        }
        
        if removeOfflineEnabled && hasOfflineNode {
            return ActionMenu(title: LocalizationConstants.ActionMenu.removeOffline, type: .removeOffline)
        }
        
        return nil
    }

    static func moveToFolderAction(for nodes: [ListNode], configData: MobileConfigData?) -> ActionMenu? {
        guard isMenuItemEnabled(configData: configData, id: .move) else {
            return nil
        }

        let filteredNodes = getFilteredNodes(for: nodes)
        if filteredNodes.isEmpty { return nil }

        let isMoveAllowed = filteredNodes.contains { $0.hasPersmission(to: .delete) }
        return isMoveAllowed ? ActionMenu(title: LocalizationConstants.ActionMenu.moveToFolder, type: .moveToFolder) : nil
    }

    static func deleteAction(for nodes: [ListNode], configData: MobileConfigData?) -> ActionMenu? {
        guard isMenuItemEnabled(configData: configData, id: .trash) else {
            return nil
        }

        let filteredNodes = getFilteredNodes(for: nodes)
        if filteredNodes.isEmpty { return nil }

        let isAllowedToDelete = filteredNodes.contains {
            ($0.nodeType == .site && $0.hasRole(to: .manager)) || $0.hasPersmission(to: .delete)
        }

        return isAllowedToDelete ? ActionMenu(title: LocalizationConstants.ActionMenu.moveTrash, type: .moveTrash) : nil
    }

    static func startWorkflowAction(for nodes: [ListNode], configData: MobileConfigData?) -> ActionMenu? {
        let filteredNodes = nodes.filter {$0.isAFolderType()}
        if !filteredNodes.isEmpty {
            return nil
        } else {
            guard isMenuItemEnabled(configData: configData, id: .startProcess),
                  APSService.isAPSServiceEnable == true else {
                return nil
            }
            
            let tempNodes = getFilteredNodes(for: nodes).filter { !$0.isAFolderType() }
            
            // If there are no filtered nodes (meaning all are folders), return nil
            guard !tempNodes.isEmpty else { return nil }
            
            return ActionMenu(title: LocalizationConstants.Accessibility.startWorkflow, type: .startWorkflow)
        }
    }
}
