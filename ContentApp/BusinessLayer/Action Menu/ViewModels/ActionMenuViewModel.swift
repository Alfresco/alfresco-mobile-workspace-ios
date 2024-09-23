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

protocol ActionMenuViewModelDelegate: AnyObject {
    func finishedLoadingActions()
}

class ActionMenuViewModel {
    private var listNode: ListNode?
    private var toolbarActions: [ActionMenu]
    private var menuActions: [[ActionMenu]]
    var excludedActions: [ActionMenuType]
    private var coordinatorServices: CoordinatorServices?
    private let nodeOperations: NodeOperations

    var toolbarDisplayed: Bool
    weak var delegate: ActionMenuViewModelDelegate?
    var configData: MobileConfigData?

    // MARK: - Init

    init(menuActions: [[ActionMenu]] = [[ActionMenu]](),
         node: ListNode? = nil,
         toolbarDisplayed: Bool = false,
         coordinatorServices: CoordinatorServices?,
         excludedActionTypes: [ActionMenuType] = []) {

        self.listNode = node
        self.menuActions = menuActions
        self.toolbarDisplayed = toolbarDisplayed
        self.toolbarActions = []
        self.coordinatorServices = coordinatorServices
        self.nodeOperations = NodeOperations(accountService: coordinatorServices?.accountService)
        self.excludedActions = excludedActionTypes
        self.configData = loadMobileConfigData()

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
            delegate?.finishedLoadingActions()
            return
        }
        if toolbarDisplayed {
            delegate?.finishedLoadingActions()
            return
        }

        if listNode.shouldUpdate() == false {
            createMenuActions()
            return
        }
        if listNode.nodeType == .site {
            nodeOperations.fetchNodeIsFavorite(for: listNode.guid) { [weak self] (_, error) in
                guard let sSelf = self else { return }
                if error == nil {
                    sSelf.listNode?.favorite = true
                }
                sSelf.createMenuActions()
            }
        } else {
            nodeOperations.fetchNodeDetails(for: listNode.guid) { [weak self] (result, _) in
                guard let sSelf = self else { return }
                if let entry = result?.entry {
                    sSelf.listNode?.update(with: NodeChildMapper.create(from: entry))
                    sSelf.listNode?.removeAllowableOperationUnknown()
                }
                sSelf.createMenuActions()
            }
        }
    }

    func actions() -> [[ActionMenu]] {
        return menuActions
    }

    func actionsForToolbar() -> [ActionMenu] {
        return toolbarActions
    }

    func indexInToolbar(for actionType: ActionMenuType) -> Int? {
        guard !toolbarActions.isEmpty else { return nil }
        for index in 0...toolbarActions.count - 1 where toolbarActions[index].type == actionType {
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
        guard let listNode = listNode else {
            finishLoadingActions()
            return
        }
        
        if listNode.trashed {
            self.menuActions = ActionsMenuTrashMoreButton.actions(for: listNode, configData: configData)
        } else {
            self.menuActions = ActionsMenuGeneric.actions(for: listNode, configData: configData)
            // Filter the menuActions to exclude specific actions
            self.menuActions = self.menuActions.map { $0.filter { !self.excludedActions.contains($0.type) } }
        }
        finishLoadingActions()
    }

    private func loadMobileConfigData() -> MobileConfigData? {
        guard let data = UserDefaultsModel.value(for: KeyConstants.Save.kConfigData) as? Data else {
            return nil
        }

        let decoder = JSONDecoder()
        do {
            return try decoder.decode(MobileConfigData.self, from: data)
        } catch {
            return nil
        }
    }

    private func finishLoadingActions() {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.finishedLoadingActions()
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

    private func addActionToOpenMenu(in array: [ActionMenu]) {
        toolbarActions.append(contentsOf: array)
        guard let listNode = listNode else { return }
        let enabledMenus = self.configData?.featuresMobile.menu.filter { $0.enabled }
        let fileMenuIds: [MenuId] = [.openWith, .addFavorite, .removeFavorite, .startProcess, .rename, .move, .addOffline, .removeOffline, .trash]
        if enabledMenus?.contains(where: { fileMenuIds.contains($0.id) }) ?? Bool() {
            toolbarActions.append(ActionMenu(title: "", type: .more))
        }
    }
}
