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
                              error: Error?,
                              multipleNodes: [ListNode])
}

protocol NodeActionMoveDelegate: AnyObject {
    func didSelectMoveFile(node: [ListNode], action: ActionMenu)
}

class NodeActionsViewModel {
    private var node: ListNode?
    private var actionFinishedHandler: ActionFinishedCompletionHandler?
    private var coordinatorServices: CoordinatorServices?
    private let nodeOperations: NodeOperations
    private let listNodeDataAccessor = ListNodeDataAccessor()
    weak var delegate: NodeActionsViewModelDelegate?
    weak var moveDelegate: NodeActionMoveDelegate?
    private var multipleNodes = [ListNode]()
    private let sheetDismissDelay = 0.5
    let refreshGroup = DispatchGroup()

    // MARK: Init

    init(node: ListNode? = nil,
         delegate: NodeActionsViewModelDelegate?,
         coordinatorServices: CoordinatorServices?,
         multipleNodes: [ListNode]) {
        self.node = node
        self.multipleNodes = multipleNodes
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
            if hasInternetConnection() {
                handleFavorite(action: action)
            } else {
                showToastForInternetConnectivity()
            }
        } else if action.type.isMoveActions {
            if hasInternetConnection() {
                handleMove(action: action)
            } else {
                showToastForInternetConnectivity()
            }
        } else if action.type.isDownloadActions {
            handleDownload(action: action)
        } else if action.type.isWorkflowActions {
            if hasInternetConnection() {
                linkContentToAPS(action: action)
            } else {
                showToastForInternetConnectivity()
            }
        } else {
            let delay = action.type.isMoreAction ? 0.0 : 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { [weak self] in
                guard let sSelf = self else { return }
                sSelf.delegate?.handleFinishedAction(with: action,
                                                     node: sSelf.node,
                                                     error: nil,
                                                     multipleNodes: sSelf.multipleNodes)
            })
        }
    }
    
    private func hasInternetConnection() -> Bool {
        return coordinatorServices?.connectivityService?.hasInternetConnection() ?? false
    }
    
    private func showToastForInternetConnectivity() {
        Snackbar.display(with: LocalizationConstants.Dialog.internetUnavailableMessage,
                         type: .approve,
                         presentationHostViewOverride: appDelegate()?.window,
                         finish: nil)
    }

    // MARK: - Move
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
            case .moveToFolder:
                sSelf.requestMoveToFolder(action: action)
            default: break
            }
            sSelf.logEvent(with: action, node: sSelf.node)
        }
    }

    // MARK: - Download
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

    // MARK: - Add Offline
    private func requestMarkOffline(action: ActionMenu) {
        
        if !multipleNodes.isEmpty {
            for multipleNode in multipleNodes {
                refreshGroup.enter()
                updateNodeForAddOffline(node: multipleNode, action: action)
                refreshGroup.leave()
            }
        } else if let node = self.node {
            updateNodeForAddOffline(node: node, action: action)
        }
        
        refreshGroup.notify(queue: CameraKit.cameraWorkerQueue) {[weak self] in
            guard let sSelf = self else { return }
            sSelf.handleResponse(error: nil, action: action)
        }
    }
    
    private func updateNodeForAddOffline(node: ListNode, action: ActionMenu) {
        node.id = 0
        node.syncStatus = .pending
        node.markedAsOffline = true
        listNodeDataAccessor.store(node: node)

        action.type = .removeOffline
        action.title = LocalizationConstants.ActionMenu.removeOffline
        action.analyticEventName = "\(ActionMenuType.markOffline)"

        let offlineEvent = OfflineEvent(node: node, eventType: .marked)
        let eventBusService = coordinatorServices?.eventBusService
        eventBusService?.publish(event: offlineEvent, on: .mainQueue)
        coordinatorServices?.syncTriggersService?.triggerSync(for: .nodeMarkedOffline)
    }

    // MARK: - Remove Offline
    private func requestRemoveOffline(action: ActionMenu) {
        if !multipleNodes.isEmpty {
            for multipleNode in multipleNodes {
                refreshGroup.enter()
                updateNodeForRemoveOffline(node: multipleNode, action: action)
                refreshGroup.leave()
            }
        } else if let node = self.node {
            updateNodeForRemoveOffline(node: node, action: action)
        }
        
        refreshGroup.notify(queue: CameraKit.cameraWorkerQueue) {[weak self] in
            guard let sSelf = self else { return }
            sSelf.handleResponse(error: nil, action: action)
        }
    }
    
    private func updateNodeForRemoveOffline(node: ListNode, action: ActionMenu) {
       
        if let queriedNode = listNodeDataAccessor.query(node: node) {
            queriedNode.markedAsOffline = false
            queriedNode.markedFor = .removal
            queriedNode.syncStatus = .undefined
            listNodeDataAccessor.store(node: queriedNode)
        }
        
        action.type = .markOffline
        action.title = LocalizationConstants.ActionMenu.markOffline
        action.analyticEventName = "\(ActionMenuType.removeOffline)"

        let offlineEvent = OfflineEvent(node: node, eventType: .removed)
        let eventBusService = coordinatorServices?.eventBusService
        eventBusService?.publish(event: offlineEvent, on: .mainQueue)

        coordinatorServices?.syncTriggersService?.triggerSync(for: .nodeRemovedFromOffline)
    }
    
    // MARK: - Favorite
    private func handleFavorite(action: ActionMenu) {
        sessionForCurrentAccount { [weak self] (_) in
            guard let sSelf = self else { return }
            switch action.type {
            case .addFavorite:
                sSelf.addFavoritesMultipleNodes(action: action)
            case .removeFavorite:
                sSelf.removeFavoritesMultipleNodes(action: action)
            default: break
            }
        }
    }
    
    private func addFavoritesMultipleNodes(action: ActionMenu) {
        if !multipleNodes.isEmpty {
            for multipleNode in multipleNodes {
                refreshGroup.enter()
                requestAddToFavorites(node: multipleNode, action: action)
                refreshGroup.leave()
            }
        } else if let node = self.node {
            refreshGroup.enter()
            requestAddToFavorites(node: node, action: action)
            refreshGroup.leave()
        }
        
        refreshGroup.notify(queue: CameraKit.cameraWorkerQueue) {[weak self] in
            guard let sSelf = self else { return }
            sSelf.handleResponse(error: nil, action: action)
        }
    }
    
    private func removeFavoritesMultipleNodes(action: ActionMenu) {
        if !multipleNodes.isEmpty {
            for multipleNode in multipleNodes {
                refreshGroup.enter()
                requestRemoveFromFavorites(node: multipleNode, action: action)
                refreshGroup.leave()
            }
        } else if let node = self.node {
            refreshGroup.enter()
            requestRemoveFromFavorites(node: node, action: action)
            refreshGroup.leave()
        }
        
        refreshGroup.notify(queue: CameraKit.cameraWorkerQueue) {[weak self] in
            guard let sSelf = self else { return }
            sSelf.handleResponse(error: nil, action: action)
        }
    }

    // MARK: - Add to Favorite
    private func requestAddToFavorites(node: ListNode, action: ActionMenu) {
   
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
            guard let sSelf = self else { 
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: KeyConstants.Notification.refreshRecentList),
                                                object: nil,
                                                userInfo: nil)
                return }
            if error == nil {
                node.favorite = true
                action.type = .removeFavorite
                action.title = LocalizationConstants.ActionMenu.removeFavorite
                action.analyticEventName = "\(ActionMenuType.addFavorite)"
                
                let favouriteEvent = FavouriteEvent(node: node, eventType: .addToFavourite)
                let eventBusService = sSelf.coordinatorServices?.eventBusService
                eventBusService?.publish(event: favouriteEvent, on: .mainQueue)
            }
        }
    }

    // MARK: - Remove from Favorite
    private func requestRemoveFromFavorites(node: ListNode, action: ActionMenu) {

        FavoritesAPI.deleteFavorite(personId: APIConstants.me,
                                    favoriteId: node.guid) { [weak self] (_, error) in
            guard let sSelf = self else { 
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: KeyConstants.Notification.refreshRecentList),
                                                object: nil,
                                                userInfo: nil)
                return }
            if error == nil {
                node.favorite = false
                action.type = .addFavorite
                action.title = LocalizationConstants.ActionMenu.addFavorite
                action.analyticEventName = "\(ActionMenuType.removeFavorite)"

                let favouriteEvent = FavouriteEvent(node: node, eventType: .removeFromFavourites)
                let eventBusService = sSelf.coordinatorServices?.eventBusService
                eventBusService?.publish(event: favouriteEvent, on: .mainQueue)
            }
        }
    }

    // MARK: - Move to Trash / Delete
    private func requestMoveToTrash(action: ActionMenu) {
       
        if !multipleNodes.isEmpty {
            for multipleNode in multipleNodes {
                if multipleNode.nodeType == .site {
                    refreshGroup.enter()
                    deleteSite(node: multipleNode, action: action)
                    refreshGroup.leave()
                } else {
                    refreshGroup.enter()
                    deleteNode(node: multipleNode, action: action)
                    refreshGroup.leave()
                }
            }
        } else if let node = self.node {
            if node.nodeType == .site {
                refreshGroup.enter()
                deleteSite(node: node, action: action)
                refreshGroup.leave()
            } else {
                refreshGroup.enter()
                deleteNode(node: node, action: action)
                refreshGroup.leave()
            }
        }
        
        refreshGroup.notify(queue: CameraKit.cameraWorkerQueue) {[weak self] in
            guard let sSelf = self else { return }
            sSelf.handleResponse(error: nil, action: action)
        }
    }
    
    private func deleteSite(node: ListNode, action: ActionMenu) {
        SitesAPI.deleteSite(siteId: node.siteID) { [weak self] (_, error) in
            guard let sSelf = self else { return }
            if error == nil {
                node.trashed = true

                let moveEvent = MoveEvent(node: node, eventType: .moveToTrash)
                let eventBusService = sSelf.coordinatorServices?.eventBusService
                eventBusService?.publish(event: moveEvent, on: .mainQueue)
            }
        }
    }
    
    private func deleteNode(node: ListNode, action: ActionMenu) {
        NodesAPI.deleteNode(nodeId: node.guid) { [weak self] (_, error) in
            guard let sSelf = self else { return }
            if error == nil {
                node.trashed = true

                if let queriedNode = sSelf.listNodeDataAccessor.query(node: node) {
                    queriedNode.markedFor = .removal
                    sSelf.listNodeDataAccessor.store(node: queriedNode)
                }

                let moveEvent = MoveEvent(node: node, eventType: .moveToTrash)
                let eventBusService = sSelf.coordinatorServices?.eventBusService
                eventBusService?.publish(event: moveEvent, on: .mainQueue)
            }
        }
    }
    
    // MARK: - Move to Folder
    private func requestMoveToFolder(action: ActionMenu) {
        if !multipleNodes.isEmpty {
            DispatchQueue.main.async {
                self.moveDelegate?.didSelectMoveFile(node: self.multipleNodes, action: action)
            }
        } else {
            guard let node = self.node else { return }
            DispatchQueue.main.async {
                self.moveDelegate?.didSelectMoveFile(node: [node], action: action)
            }
        }
    }
    
    func moveFilesAndFolder(with sourceNode: ListNode, and destinationNode: ListNode, action: ActionMenu) {
        
        if !multipleNodes.isEmpty {
            for multipleNode in multipleNodes {
                refreshGroup.enter()
                moveNode(sourceNode: multipleNode, destinationNode: destinationNode, action: action)
                refreshGroup.leave()
            }
        } else {
            refreshGroup.enter()
            moveNode(sourceNode: sourceNode, destinationNode: destinationNode, action: action)
            refreshGroup.leave()
        }
        
        refreshGroup.notify(queue: CameraKit.cameraWorkerQueue) {[weak self] in
            guard let sSelf = self else { return }
            sSelf.handleResponse(error: nil, action: action)
        }
    }
    
    private func moveNode(sourceNode: ListNode, destinationNode: ListNode, action: ActionMenu) {
        sessionForCurrentAccount { [weak self] (_) in
            guard let sSelf = self else { return }
            let nodeBodyMove = NodeBodyMove(targetParentId: destinationNode.guid, name: nil)
            NodesAPI.moveNode(nodeId: sourceNode.guid, nodeBodyMove: nodeBodyMove) { [weak self] (data, error) in
                guard let sSelf = self else { return }
                if error == nil {
                    let moveEvent = MoveEvent(node: sourceNode, eventType: .moveToFolder)
                    let eventBusService = sSelf.coordinatorServices?.eventBusService
                    eventBusService?.publish(event: moveEvent, on: .mainQueue)
                }
            }
        }
    }

    // MARK: - Restore from Trash
    private func requestRestoreFromTrash(action: ActionMenu) {
        
        if !multipleNodes.isEmpty {
            for multipleNode in multipleNodes {
                refreshGroup.enter()
                restore(node: multipleNode, action: action)
                refreshGroup.leave()
            }
        } else if let node = self.node {
            refreshGroup.enter()
            restore(node: node, action: action)
            refreshGroup.leave()
        }
        
        refreshGroup.notify(queue: CameraKit.cameraWorkerQueue) {[weak self] in
            guard let sSelf = self else { return }
            sSelf.handleResponse(error: nil, action: action)
        }
    }
    
    private func restore(node: ListNode, action: ActionMenu) {
        TrashcanAPI.restoreDeletedNode(nodeId: node.guid) { [weak self] (_, error) in
            guard let sSelf = self else { return }
            if error == nil {
                node.trashed = false

                if let queriedNode = sSelf.listNodeDataAccessor.query(node: node) {
                    queriedNode.markedFor = .undefined
                    sSelf.listNodeDataAccessor.store(node: queriedNode)
                }

                let moveEvent = MoveEvent(node: node, eventType: .restore)
                let eventBusService = sSelf.coordinatorServices?.eventBusService
                eventBusService?.publish(event: moveEvent, on: .mainQueue)
            }
        }
    }

    // MARK: - Permanently delete
    private func requestPermanentlyDelete(action: ActionMenu) {
        
        let title = LocalizationConstants.Dialog.deleteTitle
        var message: String?
        if multipleNodes.count > 1 {
            message = String(format: LocalizationConstants.Dialog.multiDeleteMessage,
                             multipleNodes.count)
        } else if let node = self.node {
            message = String(format: LocalizationConstants.Dialog.deleteMessage,
                                 node.title)
        }

        let cancelAction = MDCAlertAction(title: LocalizationConstants.General.cancel)
        cancelAction.accessibilityIdentifier = "cancelActionButton"
        
        let deleteAction = MDCAlertAction(title: LocalizationConstants.General.delete) {_ in
            self.permanentlyDeleteAction(action: action)
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
    
    func permanentlyDeleteAction(action: ActionMenu) {
        if !multipleNodes.isEmpty {
            for multipleNode in multipleNodes {
                refreshGroup.enter()
                permanentDelete(node: multipleNode, action: action)
                refreshGroup.leave()
            }
        } else if let node = self.node {
            refreshGroup.enter()
            permanentDelete(node: node, action: action)
            refreshGroup.leave()
        }
        
        refreshGroup.notify(queue: CameraKit.cameraWorkerQueue) {[weak self] in
            guard let sSelf = self else { return }
            sSelf.handleResponse(error: nil, action: action)
        }
    }
    
    func permanentDelete(node: ListNode, action: ActionMenu) {
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
        }
    }

    // MARK: - Download
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
                                                 error: error,
                                                 multipleNodes: sSelf.multipleNodes)
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
                    privacyVC.viewModel = PrivacyNoticePhotosModel()
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

// MARK: - Workflow
extension NodeActionsViewModel {
    private func linkContentToAPS(action: ActionMenu) {
        guard self.node != nil else { return }
        self.handleResponse(error: nil, action: action)
    }
}

// MARK: - Analytics
extension NodeActionsViewModel {
    
    func logEvent(with action: ActionMenu?, node: ListNode?) {
        guard let action = action else { return }
        AnalyticsManager.shared.fileActionEvent(for: node, action: action)
    }
}
