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
import AlfrescoCore
import Alamofire

typealias ActionFinishedCompletionHandler = (() -> Void)

protocol NodeActionsViewModelDelegate: AnyObject {
    func handleFinishedAction(with action: ActionMenu?,
                              node: ListNode?,
                              error: Error?)
}

class NodeActionsViewModel {
    private var node: ListNode?
    private var actionFinishedHandler: ActionFinishedCompletionHandler?
    private var coordinatorServices: CoordinatorServices?
    private let nodeOperations: NodeOperations
    private let listNodeDataAccessor = ListNodeDataAccessor()
    weak var delegate: NodeActionsViewModelDelegate?

    private let sheetDismissDelay = 0.5

    // MARK: Init

    init(node: ListNode? = nil,
         delegate: NodeActionsViewModelDelegate?,
         coordinatorServices: CoordinatorServices?) {
        self.node = node
        self.delegate = delegate
        self.coordinatorServices = coordinatorServices
        self.nodeOperations = NodeOperations(accountService: coordinatorServices?.accountService)
    }

    // MARK: - Public Helpers

    func tapped(on action: ActionMenu,
                finished: @escaping ActionFinishedCompletionHandler) {
        self.actionFinishedHandler = finished
        request(action: action)
    }

    // MARK: - Actions Request Helpers

    private func request(action: ActionMenu) {
        if let handler = actionFinishedHandler {
            DispatchQueue.main.async {
                handler()
            }
        }
        handle(action: action)
    }

    private func handle(action: ActionMenu) {
        if action.type.isFavoriteActions {
            handleFavorite(action: action)
        } else if action.type.isMoveActions {
            handleMove(action: action)
        } else if action.type.isDownloadActions {
            handleDownload(action: action)
        } else {
            let delay = action.type.isMoreAction ? 0.0 : 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { [weak self] in
                guard let sSelf = self else { return }
                sSelf.delegate?.handleFinishedAction(with: action,
                                                     node: sSelf.node,
                                                     error: nil)
            })
        }
    }

    private func handleFavorite(action: ActionMenu) {
        sessionForCurrentAccount { [weak self] (_) in
            guard let sSelf = self else { return }
            switch action.type {
            case .addFavorite:
                sSelf.requestAddToFavorites(action: action)
            case .removeFavorite:
                sSelf.requestRemoveFromFavorites(action: action)
            default: break
            }
        }
    }

    private func handleMove(action: ActionMenu) {
        sessionForCurrentAccount { [weak self] (_) in
            guard let sSelf = self else { return }
            switch action.type {
            case .moveTrash:
                sSelf.requestMoveToTrash(action: action)
            case .restore:
                sSelf.requestRestoreFromTrash(action: action)
            case .permanentlyDelete:
                sSelf.requestPermanentlyDelete(action: action)
            default: break
            }
        }
    }

    private func handleDownload(action: ActionMenu) {
        switch action.type {
        case .download:
            requestDownload(action: action)
        case .markOffline:
            requestMarkOffline(action: action)
        case .removeOffline:
            requestRemoveOffline(action: action)
        default: break
        }
    }

    private func requestMarkOffline(action: ActionMenu) {
        if let node = self.node {
            node.syncStatus = .pending
            node.markedAsOffline = true
            listNodeDataAccessor.store(node: node)

            action.type = .removeOffline
            action.title = LocalizationConstants.ActionMenu.removeOffline

            let offlineEvent = OfflineEvent(node: node, eventType: .marked)
            let eventBusService = coordinatorServices?.eventBusService
            eventBusService?.publish(event: offlineEvent, on: .mainQueue)

            coordinatorServices?.syncTriggersService?.triggerSync(for: .nodeMarkedOffline)
        }
        handleResponse(error: nil, action: action)
    }

    private func requestRemoveOffline(action: ActionMenu) {
        if let node = self.node {
            if let queriedNode = listNodeDataAccessor.query(node: node) {
                queriedNode.markedAsOffline = false
                queriedNode.markedFor = .removal
                queriedNode.syncStatus = .undefined
                listNodeDataAccessor.store(node: queriedNode)
            }

            action.type = .markOffline
            action.title = LocalizationConstants.ActionMenu.markOffline

            let offlineEvent = OfflineEvent(node: node, eventType: .removed)
            let eventBusService = coordinatorServices?.eventBusService
            eventBusService?.publish(event: offlineEvent, on: .mainQueue)

            coordinatorServices?.syncTriggersService?.triggerSync(for: .nodeRemovedFromOffline)
        }
        handleResponse(error: nil, action: action)
    }

    private func requestAddToFavorites(action: ActionMenu) {
        guard let node = self.node else { return }
        let jsonGuid = JSONValue(dictionaryLiteral: ("guid", JSONValue(stringLiteral: node.guid)))
        var jsonFolder: JSONValue
        if node.nodeType == .unknown {
            jsonFolder = JSONValue(dictionaryLiteral: (node.isFile ? "file" : "folder", jsonGuid))
        } else {
            jsonFolder = JSONValue(dictionaryLiteral: (node.nodeType.plainType(), jsonGuid))
        }
        let jsonBody = FavoriteBodyCreate(target: jsonFolder)

        FavoritesAPI.createFavorite(personId: APIConstants.me,
                                    favoriteBodyCreate: jsonBody) { [weak self] (_, error) in
            guard let sSelf = self else { return }
            if error == nil {
                sSelf.node?.favorite = true
                action.type = .removeFavorite
                action.title = LocalizationConstants.ActionMenu.removeFavorite

                let favouriteEvent = FavouriteEvent(node: node, eventType: .addToFavourite)
                let eventBusService = sSelf.coordinatorServices?.eventBusService
                eventBusService?.publish(event: favouriteEvent, on: .mainQueue)
            }
            sSelf.handleResponse(error: error, action: action)
        }
    }

    private func requestRemoveFromFavorites(action: ActionMenu) {
        guard let node = self.node else { return }
        FavoritesAPI.deleteFavorite(personId: APIConstants.me,
                                    favoriteId: node.guid) { [weak self] (_, error) in
            guard let sSelf = self else { return }
            if error == nil {
                sSelf.node?.favorite = false
                action.type = .addFavorite
                action.title = LocalizationConstants.ActionMenu.addFavorite

                let favouriteEvent = FavouriteEvent(node: node, eventType: .removeFromFavourites)
                let eventBusService = sSelf.coordinatorServices?.eventBusService
                eventBusService?.publish(event: favouriteEvent, on: .mainQueue)
            }
            sSelf.handleResponse(error: error, action: action)
        }
    }

    private func requestMoveToTrash(action: ActionMenu) {
        guard let node = self.node else { return }
        if node.nodeType == .site {
            SitesAPI.deleteSite(siteId: node.siteID) { [weak self] (_, error) in
                guard let sSelf = self else { return }
                if error == nil {
                    sSelf.node?.trashed = true

                    let moveEvent = MoveEvent(node: node, eventType: .moveToTrash)
                    let eventBusService = sSelf.coordinatorServices?.eventBusService
                    eventBusService?.publish(event: moveEvent, on: .mainQueue)
                }
                sSelf.handleResponse(error: error, action: action)
            }
        } else {
            NodesAPI.deleteNode(nodeId: node.guid) { [weak self] (_, error) in
                guard let sSelf = self else { return }
                if error == nil {
                    sSelf.node?.trashed = true

                    if let queriedNode = sSelf.listNodeDataAccessor.query(node: node) {
                        queriedNode.markedFor = .removal
                        sSelf.listNodeDataAccessor.store(node: queriedNode)
                    }

                    let moveEvent = MoveEvent(node: node, eventType: .moveToTrash)
                    let eventBusService = sSelf.coordinatorServices?.eventBusService
                    eventBusService?.publish(event: moveEvent, on: .mainQueue)
                }
                sSelf.handleResponse(error: error, action: action)
            }
        }
    }

    private func requestRestoreFromTrash(action: ActionMenu) {
        guard let node = self.node else { return }
        TrashcanAPI.restoreDeletedNode(nodeId: node.guid) { [weak self] (_, error) in
            guard let sSelf = self else { return }
            if error == nil {
                sSelf.node?.trashed = false

                if let queriedNode = sSelf.listNodeDataAccessor.query(node: node) {
                    queriedNode.markedFor = .undefined
                    sSelf.listNodeDataAccessor.store(node: queriedNode)
                }

                let moveEvent = MoveEvent(node: node, eventType: .restore)
                let eventBusService = sSelf.coordinatorServices?.eventBusService
                eventBusService?.publish(event: moveEvent, on: .mainQueue)
            }
            self?.handleResponse(error: error, action: action)
        }
    }

    private func requestPermanentlyDelete(action: ActionMenu) {
        guard let node = self.node else { return }
        let title = LocalizationConstants.Dialog.deleteTitle
        let message = String(format: LocalizationConstants.Dialog.deleteMessage,
                             node.title)

        let cancelAction = MDCAlertAction(title: LocalizationConstants.General.cancel)
        cancelAction.accessibilityIdentifier = "cancelActionButton"

        let deleteAction = MDCAlertAction(title: LocalizationConstants.General.delete) { _ in
            TrashcanAPI.deleteDeletedNode(nodeId: node.guid) { [weak self] (_, error) in
                guard let sSelf = self else { return }
                if error == nil {
                    if let queriedNode = sSelf.listNodeDataAccessor.query(node: node) {
                        sSelf.listNodeDataAccessor.remove(node: queriedNode)
                    }

                    let moveEvent = MoveEvent(node: node, eventType: .permanentlyDelete)
                    let eventBusService = sSelf.coordinatorServices?.eventBusService
                    eventBusService?.publish(event: moveEvent, on: .mainQueue)
                }
                sSelf.handleResponse(error: error, action: action)
            }
        }
        deleteAction.accessibilityIdentifier = "deleteActionButton"

        DispatchQueue.main.async {
            if let presentationContext = UIViewController.applicationTopMostPresented {
                _ = presentationContext.showDialog(title: title,
                                                   message: message,
                                                   actions: [cancelAction, deleteAction],
                                                   completionHandler: {})
            }
        }
    }

    private func requestDownload(action: ActionMenu) {
        var downloadDialog: MDCAlertController?
        var downloadRequest: DownloadRequest?

        guard let accountIdentifier = coordinatorServices?.accountService?.activeAccount?.identifier else { return }
        guard let node = self.node else { return }

        let mainQueue = DispatchQueue.main
        let workerQueue = OperationQueueService.worker

        if node.syncStatus == .synced &&
            listNodeDataAccessor.isContentDownloaded(for: node) {
            if let localURL = listNodeDataAccessor.fileLocalPath(for: node) {
                mainQueue.async { [weak self] in
                    guard let sSelf = self else { return }
                    sSelf.displayActivityViewController(for: localURL)
                }
            }
        } else {
            mainQueue.async { [weak self] in
                guard let sSelf = self else { return }
                downloadDialog = sSelf.showDownloadDialog(actionHandler: { _ in
                    downloadRequest?.cancel()
                })

                workerQueue.async {
                    let downloadPath = DiskService.documentsDirectoryPath(for: accountIdentifier)
                    var downloadURL = URL(fileURLWithPath: downloadPath)
                    downloadURL.appendPathComponent(node.title)
                    sSelf.sessionForCurrentAccount { (_) in
                    downloadRequest = sSelf.nodeOperations.downloadContent(for: node,
                                                                           to: downloadURL,
                                                                           completionHandler: { destinationURL, error in
                        mainQueue.asyncAfter(deadline: .now() + sSelf.sheetDismissDelay, execute: {
                            downloadDialog?.dismiss(animated: true,
                                                    completion: {
                                                        sSelf.handleResponse(error: error,
                                                                             action: action)
                                                        if let url = destinationURL {
                                                            sSelf.displayActivityViewController(for: url)
                                                        }
                                                    })
                        })
                    }
                )}
            }
            }
        }
    }

    // MARK: - Helpers

    func sessionForCurrentAccount(completionHandler: @escaping ((AuthenticationProviderProtocol) -> Void)) {
        let accountService = coordinatorServices?.accountService
        accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            completionHandler(authenticationProvider)
        })
    }

    private func handleResponse(error: Error?, action: ActionMenu) {
        if let error = error {
            AlfrescoLog.error(error)
        }
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.delegate?.handleFinishedAction(with: action,
                                                 node: sSelf.node,
                                                 error: error)
        }
    }

    // MARK: - Download node content

    private func showDownloadDialog(actionHandler: @escaping (MDCAlertAction) -> Void) -> MDCAlertController? {
        if let downloadDialogView: DownloadDialog = .fromNib() {
            let themingService = coordinatorServices?.themingService
            downloadDialogView.messageLabel.text =
                String(format: LocalizationConstants.Dialog.downloadMessage,
                       node?.title ?? "")
            downloadDialogView.activityIndicator.startAnimating()
            downloadDialogView.applyTheme(themingService?.activeTheme)

            let cancelAction =
                MDCAlertAction(title: LocalizationConstants.General.cancel) { action in
                    actionHandler(action)
            }
            cancelAction.accessibilityIdentifier = "cancelActionButton"

            if let presentationContext = UIViewController.applicationTopMostPresented {
                let downloadDialog = presentationContext.showDialog(title: nil,
                                                                    message: nil,
                                                                    actions: [cancelAction],
                                                                    accesoryView: downloadDialogView,
                                                                    completionHandler: {})

                return downloadDialog
            }
        }

        return nil
    }

    private func displayActivityViewController(for url: URL) {
        guard let presentationContext = UIViewController.applicationTopMostPresented else { return }

        let activityViewController =
            UIActivityViewController(activityItems: [url],
                                     applicationActivities: nil)
        activityViewController.modalPresentationStyle = .popover

        let clearController = UIViewController()
        clearController.view.backgroundColor = .clear
        clearController.modalPresentationStyle = .overCurrentContext

        activityViewController.completionWithItemsHandler = { [weak self] (activity, success, _, _) in
            guard let sSelf = self else { return }

            activityViewController.dismiss(animated: true)
            clearController.dismiss(animated: false) {
                // Will not base check on error code as used constants have been deprecated
                if activity?.rawValue == KeyConstants.Save.toCameraRoll && !success {
                    let privacyVC = PrivacyNoticeViewController.instantiateViewController()
                    privacyVC.viewModel = PrivacyNotivePhotosModel()
                    privacyVC.coordinatorServices = sSelf.coordinatorServices
                    presentationContext.present(privacyVC,
                                                animated: true,
                                                completion: nil)
                }
            }
        }

        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = presentationContext.view.bounds
            popoverController.sourceView = presentationContext.view

            popoverController.permittedArrowDirections = []
        }

        presentationContext.present(clearController,
                                    animated: false) {
            clearController.present(activityViewController,
                                    animated: true,
                                    completion: nil)
        }
    }
}
