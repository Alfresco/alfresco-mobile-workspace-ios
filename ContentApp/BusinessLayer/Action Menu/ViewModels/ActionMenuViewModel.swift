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

class ActionMenuViewModel {
    private var menu: ActionsMenuProtocol?
    private var toolbarActions: [ActionMenu]?

    // MARK: - Init

    init(with menu: ActionsMenuProtocol?, toolbarDivide: Bool = false) {
        self.menu = menu
        if toolbarDivide {
            divideForToolbarActions()
        }
    }

    // MARK: - Public Helpers

    func actions() -> [[ActionMenu]]? {
        return menu?.actions
    }

    func actionsForToolbar() -> [ActionMenu]? {
        return toolbarActions
    }

    func indexInToolbar(for actionType: ActionMenuType) -> Int? {
        guard let actions = toolbarActions else { return nil }
        for index in 0...actions.count - 1 where actions[index].type == actionType {
            return index
        }
        return nil
    }

    func numberOfActions() -> CGFloat {
        guard let actions = self.menu?.actions else { return 0 }
        var numberOfActions = 0
        for section in actions {
            numberOfActions += section.count
        }
        return CGFloat(numberOfActions)
    }

    func shouldShowSectionSeparator(for indexPath: IndexPath) -> Bool {
        guard let actions = menu?.actions else { return false }
        if actions[indexPath.section][indexPath.row].type == .node {
            return false
        }
        if indexPath.section != actions.count - 1 &&
            indexPath.row == actions[indexPath.section].count - 1 {
            return true
        }
        return false
    }

    // MARK: - Private Helpers

    private func divideForToolbarActions() {
        var toolActions = [ActionMenu]()
        if let menu = menu {
            for index in 0...menu.actions.count - 1 {
                for action in menu.actions[index] where action.type != .node {

                    toolActions.append(action)
                    self.menu?.actions[index].removeFirst()
                    if self.menu?.actions[index].count == 0 {
                        self.menu?.actions.remove(at: index)
                    }
                    if toolActions.count == kToolbarFilePreviewNumberOfAction - 1 {
                        addActionToOpenMenu(in: toolActions)
                        return
                    }
                }
            }
        }
        addActionToOpenMenu(in: toolActions)
    }

    private func addActionToOpenMenu(in array: [ActionMenu]?) {
        guard var array = array else { return }
        array.append(ActionMenu(title: "", type: .more))
        toolbarActions = array

        if menu?.actions.count == 1 &&
            menu?.actions[0].count == 1 &&
            menu?.actions[0][0].type == .node {
            toolbarActions?.removeLast()
        }
    }
}
