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
import MaterialComponents.MaterialDialogs

typealias ActionFinishedCompletionHandler = (() -> Void)

protocol NodeActionsViewModelDelegate: class {
    func nodeActionFinished(with action: ActionMenu?,
                            node: ListNode,
                            error: Error?)
    func presentationContext() -> UIViewController?
}

class NodeActionsViewModel {
    private var action: ActionMenu?
    private var node: ListNode
    private var actionFinishedHandler: ActionFinishedCompletionHandler?
    private var nodeActionServices: CoordinatorServices?
    weak var delegate: NodeActionsViewModelDelegate?

    // MARK: Init

    init(node: ListNode,
         delegate: NodeActionsViewModelDelegate?,
         nodeActionServices: CoordinatorServices?) {
        self.node = node
        self.delegate = delegate
        self.nodeActionServices = nodeActionServices
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
        let accountService = nodeActionServices?.accountService
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self, let action = sSelf.action else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            switch action.type {
            case .addFavorite:
                sSelf.requestAddToFavorites()
            case .removeFavorite:
                sSelf.requestRemoveFromFavorites()
            case .moveTrash:
                sSelf.requestMoveToTrash()
            case .restore :
                sSelf.requestRestoreFromTrash()
            case .permanentlyDelete:
                sSelf.requestPermanentlyDelete()
            case .download :
                sSelf.requestDownload()
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

                let eventBusService = sSelf.nodeActionServices?.eventBusService
                eventBusService?.publish(event: favouriteEvent, on: .mainQueue)
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
                let favouriteEvent = FavouriteEvent(node: sSelf.node,
                                                    eventType: .removeFromFavourites)

                let eventBusService = sSelf.nodeActionServices?.eventBusService
                eventBusService?.publish(event: favouriteEvent, on: .mainQueue)
            }
            sSelf.handleResponse(error: error)
        }
    }

    private func requestMoveToTrash() {
        if node.kind == .site {
            SitesAPI.deleteSite(siteId: node.siteID) { [weak self] (_, error) in
                guard let sSelf = self else { return }
                if error == nil {
                    sSelf.node.trashed = true
                    let moveEvent = MoveEvent(node: sSelf.node, eventType: .moveToTrash)

                    let eventBusService = sSelf.nodeActionServices?.eventBusService
                    eventBusService?.publish(event: moveEvent, on: .mainQueue)
                }
                sSelf.handleResponse(error: error)
            }
        } else {
            NodesAPI.deleteNode(nodeId: node.guid) { [weak self] (_, error) in
                guard let sSelf = self else { return }
                if error == nil {
                    sSelf.node.trashed = true
                    let moveEvent = MoveEvent(node: sSelf.node, eventType: .moveToTrash)

                    let eventBusService = sSelf.nodeActionServices?.eventBusService
                    eventBusService?.publish(event: moveEvent, on: .mainQueue)
                }
                sSelf.handleResponse(error: error)
            }
        }
    }

    private func requestRestoreFromTrash() {
        TrashcanAPI.restoreDeletedNode(nodeId: node.guid) { [weak self] (_, error) in
            guard let sSelf = self else { return }
            if error == nil {
                sSelf.node.trashed = false
                let moveEvent = MoveEvent(node: sSelf.node, eventType: .restore)

                let eventBusService = sSelf.nodeActionServices?.eventBusService
                eventBusService?.publish(event: moveEvent, on: .mainQueue)
            }
            self?.handleResponse(error: error)
        }
    }

    private func requestPermanentlyDelete() {
        if let presentationContext = delegate?.presentationContext() {
            let title =
                String(format: LocalizationConstants.NodeActionsDialog.deleteTitle, node.title)
            let message =
                String(format: LocalizationConstants.NodeActionsDialog.deleteMessage, node.title)

            let cancelAction = MDCAlertAction(title: LocalizationConstants.Buttons.cancel)
            let deleteAction = MDCAlertAction(title: LocalizationConstants.Buttons.delete) { [weak self] _ in
                guard let sSelf = self else { return }

                TrashcanAPI.deleteDeletedNode(nodeId: sSelf.node.guid) { (_, error) in
                    if error == nil {
                        let moveEvent = MoveEvent(node: sSelf.node, eventType: .permanentlyDelete)

                        let eventBusService = sSelf.nodeActionServices?.eventBusService
                        eventBusService?.publish(event: moveEvent, on: .mainQueue)
                    }
                    sSelf.handleResponse(error: error)
                }
            }

            DispatchQueue.main.async {
                _ = presentationContext.showDialog(title: title,
                                                   message: message,
                                                   actions: [cancelAction, deleteAction],
                                                   completionHandler: {})
            }
        }
    }

    private func requestDownload() {
        if let presentationContext = delegate?.presentationContext() {
            let cancelAction = MDCAlertAction(title: LocalizationConstants.Buttons.cancel)

            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }

                if let downloadDialogView: DownloadDialog = DownloadDialog.fromNib() {
                    let themingService =  sSelf.nodeActionServices?.themingService
                    let activityIndicator = ActivityIndicatorView(currentTheme: themingService?.activeTheme)
                    activityIndicator.state = .isLoading
                    downloadDialogView.activityIndicator = activityIndicator

                    downloadDialogView.messageLabel.text =
                        String(format: LocalizationConstants.NodeActionsDialog.downloadMessage,
                                                                  sSelf.node.title)
                    _ = presentationContext.showDialog(title: nil,
                                                       message: nil,
                                                       actions: [cancelAction],
                                                       accesoryView: downloadDialogView,
                                                       completionHandler: {})
                }
            }
        }
    }

    private func handleResponse(error: Error?) {
        if let error = error {
            AlfrescoLog.error(error)
        }
        delegate?.nodeActionFinished(with: action, node: node, error: error)
        if let handler = actionFinishedHandler {
            handler()
        }
    }
}
