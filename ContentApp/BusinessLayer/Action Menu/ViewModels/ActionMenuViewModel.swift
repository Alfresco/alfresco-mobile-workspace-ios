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

    init(with menu: ActionsMenuProtocol?) {
        self.menu = menu
    }

    // MARK: - Public Helpers

    func divideForToolbarActions() {
        var toolActions = [ActionMenu]()
        let section = (isFirstActionInfo()) ? 1 : 0
        if let menu = menu {
            for index in section...menu.actions.count {
                for action in menu.actions[index] {

                    toolActions.append(action)

                    self.menu?.actions[section].removeFirst()
                    if self.menu?.actions[section].count == 0 {
                        self.menu?.actions.remove(at: section)
                    }
                    if toolActions.count == kToolbarFilePreviewNumberOfAction {
                        toolbarActions = toolActions
                        return
                    }
                }
            }
        }
        toolbarActions = toolActions
    }

    func actions() -> [[ActionMenu]]? {
        return menu?.actions
    }

    func actionsForToolbar() -> [ActionMenu]? {
        return toolbarActions
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

    private func isFirstActionInfo() -> Bool {
        return menu?.actions[0][0].type == .node
    }
}
