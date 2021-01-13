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
    private var listNode: ListNode?
    private var toolbarActions: [ActionMenu]?
    private var menuActions: [[ActionMenu]]
    private var coordinatorServices: CoordinatorServices?

    var toolbarDisplayed: Bool
    var offlineTabDisplayed: Bool
    weak var delegate: ActionMenuViewModelDelegate?

    // MARK: - Init

    init(menuActions: [[ActionMenu]] = [[ActionMenu]](),
         node: ListNode? = nil,
         toolbarDisplayed: Bool = false,
         offlineTabDisplayed: Bool = false,
         coordinatorServices: CoordinatorServices?) {

        self.listNode = node
        self.toolbarDisplayed = toolbarDisplayed
        self.offlineTabDisplayed = offlineTabDisplayed
        self.menuActions = menuActions
        self.coordinatorServices = coordinatorServices

        if let listNode = listNode {
            self.menuActions = [[ActionMenu(title: listNode.title,
                                            type: .node,
                                            icon: FileIcon.icon(for: listNode))],
                                [ActionMenu(title: "", type: .placeholder),
                                 ActionMenu(title: "", type: .placeholder)]]
            if toolbarDisplayed {
                self.createMenuActions()
                self.divideForToolbarActions()
            }
        }
    }

    // MARK: - Public Helpers

    func fetchNodeInformation() {
        guard let listNode = self.listNode else {
            delegate?.finishProvideActions()
            return
        }
        if toolbarDisplayed {
            delegate?.finishProvideActions()
            return
        }
        if listNode.shouldUpdate() == false {
            createMenuActions()
            return
        }
        coordinatorServices?.accountService?.activeAccount?.getSession(completionHandler: { [weak self] authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            guard let sSelf = self else { return }
            if listNode.nodeType == .site {
                FavoritesAPI.getFavorite(personId: kAPIPathMe,
                                         favoriteId: listNode.guid) { (_, error) in
                    if error == nil {
                        sSelf.listNode?.favorite = true
                    }
                    sSelf.createMenuActions()
                }
            } else {
                NodesAPI.getNode(nodeId: listNode.guid,
                                 include: [kAPIIncludePathNode,
                                           kAPIIncludeAllowableOperationsNode,
                                           kAPIIncludeIsFavoriteNode,
                                           kAPIIncludeProperties],
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
        guard let listNode = listNode else { return }
        if listNode.trashed == true {
            menuActions = ActionsMenuTrashMoreButton.actions(for: listNode)
        } else {
            menuActions = ActionsMenuGeneric.actions(for: listNode,
                                                     offlineTabDisplayed: offlineTabDisplayed)
        }
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.delegate?.finishProvideActions()
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
        addActionToOpenMenu(in: toolActions)
    }

    private func addActionToOpenMenu(in array: [ActionMenu]?) {
        guard var array = array else { return }
        array.append(ActionMenu(title: "", type: .more))
        toolbarActions = array
    }
}
