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

typealias ActionFinishedCompletionHandler = (() -> Void)

protocol NodeActionsViewModelDelegate: class {
    func nodeActionFinished(with actionType: ActionMenuType,
                            node: ListNode,
                            error: Error?)
}

class NodeActionsViewModel {
    private var actionType: ActionMenuType?
    private var node: ListNode
    private var actionFinishedHandler: ActionFinishedCompletionHandler?
    private weak var delegate: NodeActionsViewModelDelegate?
    private var accountService: AccountService?

    // MARK: Init

    init(node: ListNode,
         accountService: AccountService?,
         delegate: NodeActionsViewModelDelegate?) {
        self.node = node
        self.accountService = accountService
        self.delegate = delegate
    }

    // MARK: - Public Helpers

    func tapped(on actionType: ActionMenuType,
                finished: @escaping ActionFinishedCompletionHandler) {
        self.actionFinishedHandler = finished
        self.actionType = actionType
        requestAction()
    }

    // MARK: - Private Helpers

    private func requestAction() {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            switch sSelf.actionType {
            case .addFavorite:
                sSelf.requestAddToFavorites()
            case .removeFavorite:
                sSelf.requestRemoveFromFavorites()
            case .delete:
                sSelf.requestDelete()
            default:
                if let actionType = sSelf.actionType {
                    DispatchQueue.main.async {
                        sSelf.delegate?.nodeActionFinished(with: actionType, node: sSelf.node, error: nil)
                    }
                    if let handler = sSelf.actionFinishedHandler {
                        handler()
                    }
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
            sSelf.node.favorite = true
            sSelf.handleResponse(error: error)
        }
    }

    private func requestRemoveFromFavorites() {
        FavoritesAPI.deleteFavorite(personId: kAPIPathMe,
                                    favoriteId: node.guid) { [weak self] (_, error) in
            guard let sSelf = self else { return }
            sSelf.node.favorite = false
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
        guard let actionType = actionType else { return }
        if let error = error {
            AlfrescoLog.error(error)
        }
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.delegate?.nodeActionFinished(with: actionType, node: sSelf.node, error: error)
        }
        if let handler = actionFinishedHandler {
            handler()
        }
    }
}
