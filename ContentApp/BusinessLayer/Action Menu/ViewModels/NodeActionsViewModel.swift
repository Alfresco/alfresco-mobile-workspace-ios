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
    func nodeActionFinished(with action: ActionMenu?,
                            node: ListNode,
                            error: Error?)
}

class NodeActionsViewModel {
    private var action: ActionMenu?
    private var node: ListNode
    private var actionFinishedHandler: ActionFinishedCompletionHandler?
    private weak var delegate: NodeActionsViewModelDelegate?
    private var accountService: AccountService?
    private var eventBusService: EventBusService?

    // MARK: Init

    init(node: ListNode,
         accountService: AccountService?,
         eventBusService: EventBusService?,
         delegate: NodeActionsViewModelDelegate?) {
        self.node = node
        self.accountService = accountService
        self.delegate = delegate
        self.eventBusService = eventBusService
    }

    // MARK: - Public Helpers

    func tapped(on action: ActionMenu,
                finished: @escaping ActionFinishedCompletionHandler) {
        self.actionFinishedHandler = finished
        self.action = action
        requestAction()
    }

    // MARK: - Private Helpers

    private func requestAction() {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self, let action = sSelf.action else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            switch action.type {
            case .addFavorite:
                sSelf.requestAddToFavorites()
            case .removeFavorite:
                sSelf.requestRemoveFromFavorites()
            case .delete:
                sSelf.requestDelete()
            default:
                    DispatchQueue.main.async {
                        sSelf.delegate?.nodeActionFinished(with: sSelf.action,
                                                           node: sSelf.node,
                                                           error: nil)
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
            if error == nil {
                sSelf.node.favorite = true
                sSelf.action?.type = .removeFavorite
                sSelf.action?.title = LocalizationConstants.ActionMenu.removeFavorite
                let favouriteEvent = FavouriteEvent(node: sSelf.node, eventType: .addToFavourite)
                sSelf.eventBusService?.publish(event: favouriteEvent, on: .mainQueue)
            }
            sSelf.handleResponse(error: error)
        }
    }

    private func requestRemoveFromFavorites() {
        FavoritesAPI.deleteFavorite(personId: kAPIPathMe,
                                    favoriteId: node.guid) { [weak self] (_, error) in
            guard let sSelf = self else { return }
            if error == nil {
                sSelf.node.favorite = false
                sSelf.action?.type = .addFavorite
                sSelf.action?.title = LocalizationConstants.ActionMenu.addFavorite
                let favouriteEvent = FavouriteEvent(node: sSelf.node, eventType: .removeFromFavourites)
                sSelf.eventBusService?.publish(event: favouriteEvent, on: .mainQueue)
            }
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
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.delegate?.nodeActionFinished(with: sSelf.action, node: sSelf.node, error: error)
        }
        if let handler = actionFinishedHandler {
            handler()
        }
    }
}
