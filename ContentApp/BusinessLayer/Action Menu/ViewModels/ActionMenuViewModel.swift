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

protocol ActionMenuViewModelDelegate: class {
    func finishProvideActions()
}

class ActionMenuViewModel {
    private var accountService: AccountService?
    private var listNode: ListNode
    private var toolbarActions: [ActionMenu]?
    private var menuActions: [[ActionMenu]]
    var toolbarDivide: Bool
    weak var delegate: ActionMenuViewModelDelegate?

    // MARK: - Init

    init(with accountService: AccountService?,
         listNode: ListNode,
         toolbarDivide: Bool = false) {
        self.accountService = accountService
        self.listNode = listNode
        self.toolbarDivide = toolbarDivide
        self.menuActions = [[ActionMenu(title: listNode.title,
                                        type: .node,
                                        icon: FileIcon.icon(for: listNode.mimeType))],
                            [ActionMenu(title: "", type: .placeholder),
                             ActionMenu(title: "", type: .placeholder)]]
        if toolbarDivide {
            self.createMenuActions()
            self.divideForToolbarActions()
        }
    }

    // MARK: - Public Helpers

    func fetchNodeInformation() {
        if toolbarDivide {
            delegate?.finishProvideActions()
            return
        }
        if listNode.shouldUpdateNode() == false {
            createMenuActions()
            return
        }
        accountService?.activeAccount?.getSession(completionHandler: { [weak self] authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            guard let sSelf = self else { return }
            if sSelf.listNode.kind == .site {
                FavoritesAPI.getFavorite(personId: kAPIPathMe,
                                         favoriteId: sSelf.listNode.guid) { (_, error) in
                    if error == nil {
                        sSelf.listNode.favorite = true
                    }
                    sSelf.createMenuActions()
                }
            } else {
                NodesAPI.getNode(nodeId: sSelf.listNode.guid,
                                 include: [kAPIIncludePathNode,
                                           kAPIIncludeAllowableOperationsNode,
                                           kAPIIncludeIsFavoriteNode],
                                 relativePath: nil,
                                 fields: nil) { (result, _) in
                    if let entry = result?.entry {
                        sSelf.listNode = NodeChildMapper.create(from: entry)
                    }
                    sSelf.createMenuActions()
                }
            }
        })
    }

    func actions() -> [[ActionMenu]] {
        return menuActions
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
        if listNode.trashed == true {
            menuActions = ActionsMenuTrashMoreButton.actions(for: listNode)
        } else {
            menuActions = ActionsMenuGeneric.actions(for: listNode)
        }
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.delegate?.finishProvideActions()
        }
    }

    private func divideForToolbarActions() {
        var toolActions = [ActionMenu]()
        for index in 0...menuActions.count - 1 {
            for action in menuActions[index] where action.type != .node {
                toolActions.append(action)
                menuActions[index].removeFirst()
                if menuActions[index].count == 0 {
                    menuActions.remove(at: index)
                }
                if toolActions.count == kToolbarFilePreviewNumberOfAction - 1 {
                    addActionToOpenMenu(in: toolActions)
                    return
                }
            }
        }
        addActionToOpenMenu(in: toolActions)
    }

    private func addActionToOpenMenu(in array: [ActionMenu]?) {
        guard var array = array else { return }
        array.append(ActionMenu(title: "", type: .more))
        toolbarActions = array

        if menuActions.count == 1 &&
            menuActions[0].count == 1 &&
            menuActions[0][0].type == .node {
            toolbarActions?.removeLast()
        }

        if menuActions.count == 2 &&
            menuActions[0].count == 1 &&
            menuActions[0][0].type == .node &&
            menuActions[1].count == 1 {
            let action = menuActions[1][0]
            toolbarActions?.removeLast()
            toolbarActions?.append(action)
        }
    }
}
