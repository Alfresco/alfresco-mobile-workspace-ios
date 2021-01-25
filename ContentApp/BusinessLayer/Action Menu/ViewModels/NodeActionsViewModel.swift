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
let kSheetDismissDelay = 0.5
let kSaveToCameraRollAction = "com.apple.UIKit.activity.SaveToCameraRoll"

protocol NodeActionsViewModelDelegate: class {
    func handleFinishedAction(with action: ActionMenu?,
                              node: ListNode?,
                              error: Error?)
}

class NodeActionsViewModel {
    private var action: ActionMenu?
    private var node: ListNode?
    private var actionFinishedHandler: ActionFinishedCompletionHandler?
    private var coordinatorServices: CoordinatorServices?
    private let nodeOperations: NodeOperations
    private let listNodeDataAccessor = ListNodeDataAccessor()
    weak var delegate: NodeActionsViewModelDelegate?

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
        self.action = action
        requestAction()
    }

    // MARK: - Actions Request Helpers

    private func requestAction() {
        let accountService = coordinatorServices?.accountService
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self, let action = sSelf.action else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            if let handler = sSelf.actionFinishedHandler {
                DispatchQueue.main.async {
                    handler()
                }
            }

            sSelf.handle(action: action)
        })
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
                sSelf.delegate?.handleFinishedAction(with: sSelf.action,
                                                   node: sSelf.node,
                                                   error: nil)
            })
        }
    }

    private func handleFavorite(action: ActionMenu) {
        switch action.type {
        case .addFavorite:
            requestAddToFavorites()
        case .removeFavorite:
            requestRemoveFromFavorites()
        default: break
        }
    }

    private func handleMove(action: ActionMenu) {
        switch action.type {
        case .moveTrash:
            requestMoveToTrash()
        case .restore:
            requestRestoreFromTrash()
        case .permanentlyDelete:
            requestPermanentlyDelete()
        default: break
        }
    }

    private func handleDownload(action: ActionMenu) {
        switch action.type {
        case .download:
            requestDownload()
        case .markOffline:
            requestMarkOffline()
        case .removeOffline:
            requestRemoveOffline()
        default: break
        }
    }

    private func requestMarkOffline() {
        handleResponse(error: nil)

        if let node = self.node {
            node.syncStatus = .pending
            node.markedAsOffline = true
            listNodeDataAccessor.store(node: node)

            action?.type = .removeOffline
            action?.title = LocalizationConstants.ActionMenu.removeOffline

            let offlineEvent = OfflineEvent(node: node, eventType: .marked)
            let eventBusService = coordinatorServices?.eventBusService
            eventBusService?.publish(event: offlineEvent, on: .mainQueue)
        }
    }

    private func requestRemoveOffline() {
        handleResponse(error: nil)

        if let node = self.node {
            if let queriedNode = listNodeDataAccessor.query(node: node) {
                queriedNode.markedAsOffline = false
                queriedNode.markedForStatus = .delete
                listNodeDataAccessor.store(node: queriedNode)
            }

            action?.type = .markOffline
            action?.title = LocalizationConstants.ActionMenu.markOffline

            let offlineEvent = OfflineEvent(node: node, eventType: .removed)
            let eventBusService = coordinatorServices?.eventBusService
            eventBusService?.publish(event: offlineEvent, on: .mainQueue)
        }
    }

    private func requestAddToFavorites() {
        guard let node = self.node else { return }
        let jsonGuid = JSONValue(dictionaryLiteral: ("guid", JSONValue(stringLiteral: node.guid)))
        let jsonFolder = JSONValue(dictionaryLiteral: (node.nodeType.plainType(), jsonGuid))
        let jsonBody = FavoriteBodyCreate(target: jsonFolder)

        FavoritesAPI.createFavorite(personId: kAPIPathMe,
                                    favoriteBodyCreate: jsonBody) { [weak self] (_, error) in
            guard let sSelf = self else { return }
            if error == nil {
                sSelf.node?.favorite = true
                sSelf.action?.type = .removeFavorite
                sSelf.action?.title = LocalizationConstants.ActionMenu.removeFavorite

                let favouriteEvent = FavouriteEvent(node: node, eventType: .addToFavourite)
                let eventBusService = sSelf.coordinatorServices?.eventBusService
                eventBusService?.publish(event: favouriteEvent, on: .mainQueue)
            }
            sSelf.handleResponse(error: error)
        }
    }

    private func requestRemoveFromFavorites() {
        guard let node = self.node else { return }
        FavoritesAPI.deleteFavorite(personId: kAPIPathMe,
                                    favoriteId: node.guid) { [weak self] (_, error) in
            guard let sSelf = self else { return }
            if error == nil {
                sSelf.node?.favorite = false
                sSelf.action?.type = .addFavorite
                sSelf.action?.title = LocalizationConstants.ActionMenu.addFavorite

                let favouriteEvent = FavouriteEvent(node: node, eventType: .removeFromFavourites)
                let eventBusService = sSelf.coordinatorServices?.eventBusService
                eventBusService?.publish(event: favouriteEvent, on: .mainQueue)
            }
            sSelf.handleResponse(error: error)
        }
    }

    private func requestMoveToTrash() {
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
                sSelf.handleResponse(error: error)
            }
        } else {
            NodesAPI.deleteNode(nodeId: node.guid) { [weak self] (_, error) in
                guard let sSelf = self else { return }
                if error == nil {
                    sSelf.node?.trashed = true

                    if let queriedNode = sSelf.listNodeDataAccessor.query(node: node) {
                        queriedNode.markedForStatus = .delete
                        sSelf.listNodeDataAccessor.store(node: queriedNode)
                    }

                    let moveEvent = MoveEvent(node: node, eventType: .moveToTrash)
                    let eventBusService = sSelf.coordinatorServices?.eventBusService
                    eventBusService?.publish(event: moveEvent, on: .mainQueue)
                }
                sSelf.handleResponse(error: error)
            }
        }
    }

    private func requestRestoreFromTrash() {
        guard let node = self.node else { return }
        TrashcanAPI.restoreDeletedNode(nodeId: node.guid) { [weak self] (_, error) in
            guard let sSelf = self else { return }
            if error == nil {
                sSelf.node?.trashed = false

                if let queriedNode = sSelf.listNodeDataAccessor.query(node: node) {
                    queriedNode.markedForStatus = .undefined
                    sSelf.listNodeDataAccessor.store(node: queriedNode)
                }

                let moveEvent = MoveEvent(node: node, eventType: .restore)
                let eventBusService = sSelf.coordinatorServices?.eventBusService
                eventBusService?.publish(event: moveEvent, on: .mainQueue)
            }
            self?.handleResponse(error: error)
        }
    }

    private func requestPermanentlyDelete() {
        guard let node = self.node else { return }
        let title = LocalizationConstants.Dialog.deleteTitle
        let message = String(format: LocalizationConstants.Dialog.deleteMessage,
                             node.title)

        let cancelAction = MDCAlertAction(title: LocalizationConstants.Buttons.cancel)
        let deleteAction = MDCAlertAction(title: LocalizationConstants.Buttons.delete) { _ in
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
                sSelf.handleResponse(error: error)
            }
        }

        DispatchQueue.main.async {
            if let presentationContext = UIViewController.applicationTopMostPresented {
                _ = presentationContext.showDialog(title: title,
                                                   message: message,
                                                   actions: [cancelAction, deleteAction],
                                                   completionHandler: {})
            }
        }
    }

    private func requestDownload() {
        var downloadDialog: MDCAlertController?
        var downloadRequest: DownloadRequest?

        guard let accountIdentifier = coordinatorServices?.accountService?.activeAccount?.identifier else { return }
        guard let node = self.node else { return }

        let mainQueue = DispatchQueue.main
        let workerQueue = OperationQueueService.worker

        if node.markedAsOffline ?? false == true {
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

                    downloadRequest = sSelf.nodeOperations.downloadContent(for: node,
                                                                           to: downloadURL,
                                                                           completionHandler: { destinationURL, error in
                        mainQueue.asyncAfter(deadline: .now() + kSheetDismissDelay, execute: {
                            downloadDialog?.dismiss(animated: true,
                                                    completion: {
                                                        sSelf.handleResponse(error: error)
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

    // MARK: - Helpers

    private func handleResponse(error: Error?) {
        if let error = error {
            AlfrescoLog.error(error)
        }
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.delegate?.handleFinishedAction(with: sSelf.action, node: sSelf.node, error: error)
        }
    }

    // MARK: - Download node content

    private func showDownloadDialog(actionHandler: @escaping (MDCAlertAction) -> Void) -> MDCAlertController? {
        if let downloadDialogView: DownloadDialog = DownloadDialog.fromNib() {
            let themingService = coordinatorServices?.themingService
            downloadDialogView.messageLabel.text =
                String(format: LocalizationConstants.Dialog.downloadMessage,
                       node?.title ?? "")
            downloadDialogView.activityIndicator.startAnimating()
            downloadDialogView.applyTheme(themingService?.activeTheme)

            let cancelAction =
                MDCAlertAction(title: LocalizationConstants.Buttons.cancel) { action in
                    actionHandler(action)
            }

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
                if activity?.rawValue == kSaveToCameraRollAction && !success {
                    let privacyVC = PrivacyNoticeViewController.instantiateViewController()
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
