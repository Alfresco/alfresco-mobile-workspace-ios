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
    func actionFinished(on action: ActionMenu?,
                        node: ListNode,
                        error: Error?)
}

typealias ActionFinishedCompletionHandler = (() -> Void)

class ActionMenuViewModel {
    weak var delegate: ActionMenuViewModelDelegate?
    var menu: ActionsMenuProtocol?
    private var node: ListNode
    private var accountService: AccountService?
    private var action: ActionMenu?
    private var actionFinishedHandler: ActionFinishedCompletionHandler?

    // MARK: - Init

    init(with menu: ActionsMenuProtocol?,
         node: ListNode,
         accountService: AccountService?,
         delegate: ActionMenuViewModelDelegate?) {

        self.menu = menu
        self.delegate = delegate
        self.node = node
        self.accountService = accountService
    }

    // MARK: - Public Helpers

    func tapped(on action: ActionMenu, finished: @escaping ActionFinishedCompletionHandler) {
        self.actionFinishedHandler = finished
        self.action = action
        requestAction()
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

    private func requestAction() {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            switch sSelf.action?.type {
            case .addFavorite:
                sSelf.requestAddToFavorites()
            case .removeFavorite:
                sSelf.requestRemoveFromFavorites()
            case .delete:
                sSelf.requestDelete()
            default:
                if let handler = sSelf.actionFinishedHandler {
                    handler()
                }
            }
        })
    }

    private func requestAddToFavorites() {
        let jsonGuid = JSONValue(dictionaryLiteral: ("guid", JSONValue(stringLiteral: node.guid)))
        let jsonFolder = JSONValue(dictionaryLiteral: (node.kind.rawValue, jsonGuid))
        let jsonBody = FavoriteBodyCreate(target: jsonFolder)

        FavoritesAPI.createFavorite(personId: kAPIPathMe,
                                    favoriteBodyCreate: jsonBody) { [weak self] (_, error) in
            guard let sSelf = self else { return }
            sSelf.handleResponse(error: error)
        }
    }

    private func requestRemoveFromFavorites() {
        FavoritesAPI.deleteFavorite(personId: kAPIPathMe,
                                    favoriteId: node.guid) { [weak self] (_, error) in
            guard let sSelf = self else { return }
            sSelf.handleResponse(error: error)
        }
    }

    private func requestDelete() {
        NodesAPI.deleteNode(nodeId: node.guid) { [weak self] (_, error) in
            guard let sSelf = self else { return }
            sSelf.handleResponse(error: error)
        }
    }

    private func handleResponse(error: Error?) {
        if let error = error {
            AlfrescoLog.error(error)
        }

        delegate?.actionFinished(on: action,
                                 node: node,
                                 error: error)

        if let handler = actionFinishedHandler {
            handler()
        }
    }
}
