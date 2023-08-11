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

import UIKit
import AlfrescoContent

class MultipleSelectionActionMenuViewModel {
    private var nodes: [ListNode]
    private var menuActions: [[ActionMenu]]
    private let excludedActions: [ActionMenuType]
    private var coordinatorServices: CoordinatorServices?
    weak var delegate: ActionMenuViewModelDelegate?

    // MARK: - Init

    init(menuActions: [[ActionMenu]] = [[ActionMenu]](),
         nodes: [ListNode],
         excludedActions: [ActionMenuType] = [],
         coordinatorServices: CoordinatorServices?) {

        self.nodes = nodes
        self.menuActions = menuActions
        self.excludedActions = excludedActions
        self.coordinatorServices = coordinatorServices
        self.createMenuActions()
    }

    // MARK: - Public Helpers
    func actions() -> [[ActionMenu]] {
        return menuActions
    }

    func numberOfActions() -> CGFloat {
        var numberOfActions = 0
        for section in menuActions {
            numberOfActions += section.count
        }
        return CGFloat(numberOfActions)
    }

    func shouldShowSectionSeparator(for indexPath: IndexPath) -> Bool {
        if menuActions[indexPath.section][indexPath.row].type == .node {
            return false
        }
        if indexPath.section != menuActions.count - 1 &&
            indexPath.row == menuActions[indexPath.section].count - 1 {
            return true
        }
        return false
    }

    // MARK: - Private Helpers

    private func createMenuActions() {
        guard let node = nodes.first else { return }
        if node.trashed == true {
            menuActions = MultipleFileActionsMenuTrashMoreButton.actions(for: nodes)
        } else {
            menuActions = MultipleFilesActionMenuGeneric.actions(for: nodes)
        }
        
        if !excludedActions.isEmpty {
            for (index, var actionMenuGroup) in menuActions.enumerated() {
                actionMenuGroup.removeAll { actionMenu -> Bool in
                    return excludedActions.contains(actionMenu.type)
                }
                menuActions[index] = actionMenuGroup
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.delegate?.finishedLoadingActions()
        }
    }

    private func divideForToolbarActions() {
        var toolActions = [ActionMenu]()
        for index in 0...menuActions.count - 1 {
            for action in menuActions[index] where
                action.type == .removeFavorite ||
                action.type == .addFavorite {
                toolActions.append(action)
            }
            for action in menuActions[index] where
                action.type == .download {
                toolActions.append(action)
            }
        }
    }
}
