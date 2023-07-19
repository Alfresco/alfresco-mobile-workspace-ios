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

struct MultipleFilesActionMenuGeneric {
    static func actions(for nodes: [ListNode]) -> [[ActionMenu]] {
        var actions = [[ActionMenu]]()

        let infoAction = ActionMenu(title: String(format: LocalizationConstants.MultipleFilesSelection.multipleItemsCount, nodes.count),
                                    type: .node,
                                    icon: nil)

        var multipleActions: [ActionMenu] = []

        if let action = favoriteAction(for: nodes) {
            multipleActions.append(action)
        }
        
        if let action = startWorkflowAction(for: nodes) {
            multipleActions.append(action)
        }
        
        if let action = moveToFolderAction(for: nodes) {
            multipleActions.append(action)
        }
        
        if let action = offlineAction(for: nodes) {
            multipleActions.append(action)
        }
        
        if let action = deleteAction(for: nodes) {
            multipleActions.append(action)
        }
        
        actions.append([infoAction])
        actions.append(multipleActions)

        return actions
    }

    // MARK: Private Helpers
    
    static func getFilteredNodes(for nodes: [ListNode]) -> [ListNode] {
        let filteredNodes = nodes.filter { ($0.markedFor != .upload || $0.markedFor == .undefined) && ($0.syncStatus == .synced || $0.syncStatus == .undefined)}
        return filteredNodes
    }

    static func moveToFolderAction(for nodes: [ListNode]) -> ActionMenu? {
        
        let filteredNodes = MultipleFilesActionMenuGeneric.getFilteredNodes(for: nodes)
        if !filteredNodes.isEmpty {
            var isMoveAllowed = false
            for node in filteredNodes where node.hasPersmission(to: .delete) {
                isMoveAllowed = true
                break
            }
            if isMoveAllowed {
                let moveAction = ActionMenu(title: LocalizationConstants.ActionMenu.moveToFolder,
                                              type: .moveToFolder)
                return moveAction
            }
        }
        return nil
    }
    
    static func favoriteAction(for nodes: [ListNode]) -> ActionMenu? {
        
        let filteredNodes = MultipleFilesActionMenuGeneric.getFilteredNodes(for: nodes)
        if !filteredNodes.isEmpty {
            var isAddFavAllowed = false
            for node in filteredNodes where node.favorite == false || node.favorite == nil {
                isAddFavAllowed = true
                break
            }
            let addFavAction = ActionMenu(title: LocalizationConstants.ActionMenu.addFavorite,
                                          type: .addFavorite)
            let removeFavAction = ActionMenu(title: LocalizationConstants.ActionMenu.removeFavorite,
                                             type: .removeFavorite)
            return (isAddFavAllowed == true) ? addFavAction : removeFavAction
        }
        
        return nil
    }

    static func offlineAction(for nodes: [ListNode]) -> ActionMenu? {

        let filteredNodes = nodes.filter { ($0.markedFor != .upload || $0.markedFor == .undefined) && (($0.syncStatus == .synced || $0.syncStatus == .undefined || $0.syncStatus == .pending) || ($0.isAFolderType() && $0.isMarkedOffline())) && ($0.isAFileType() || $0.isAFolderType())}
        if !filteredNodes.isEmpty {
            var isMarkOfflineAllowed = false
            for node in filteredNodes where !node.isMarkedOffline() {
                isMarkOfflineAllowed = true
                break
            }
            
            let markOffAction = ActionMenu(title: LocalizationConstants.ActionMenu.markOffline,
                                           type: .markOffline)
            let removeOffAction = ActionMenu(title: LocalizationConstants.ActionMenu.removeOffline,
                                           type: .removeOffline)
            return isMarkOfflineAllowed ? markOffAction : removeOffAction
        }

        return nil
    }

    static func deleteAction(for nodes: [ListNode]) -> ActionMenu? {
        
        let filteredNodes = MultipleFilesActionMenuGeneric.getFilteredNodes(for: nodes)
        if !filteredNodes.isEmpty {
            var isAllowedToDelete = false
            
            for node in filteredNodes {
                if node.nodeType == .site && node.hasRole(to: .manager) {
                    isAllowedToDelete = true
                    break
                } else if node.hasPersmission(to: .delete) {
                    isAllowedToDelete = true
                    break
                }
            }
            
            if isAllowedToDelete {
                let deleteAction = ActionMenu(title: LocalizationConstants.ActionMenu.moveTrash,
                                              type: .moveTrash)
                return deleteAction
            }
        }
        
        return nil
    }
    
    static func startWorkflowAction(for nodes: [ListNode]) -> ActionMenu? {
        let isAPSEnable = APSService.isAPSServiceEnable ?? false
        if isAPSEnable {
            let filteredNodes = nodes.filter { ($0.markedFor != .upload || $0.markedFor == .undefined) && ($0.syncStatus == .synced || $0.syncStatus == .undefined) && $0.isAFileType()}
            if !filteredNodes.isEmpty {
                let workflowAction = ActionMenu(title: LocalizationConstants.Accessibility.startWorkflow,
                                              type: .startWorkflow)
                return workflowAction
            }
        }
        return nil
    }
}
