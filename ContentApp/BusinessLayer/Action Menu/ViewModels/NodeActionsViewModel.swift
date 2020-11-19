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
import Alamofire
import AlfrescoCore

typealias ActionFinishedCompletionHandler = (() -> Void)
let kSheetDismissDelay = 0.5
let kSaveToCameraRollAction = "SaveToCameraRoll"

protocol NodeActionsViewModelDelegate: class {
    func nodeActionFinished(with action: ActionMenu?,
                            node: ListNode,
                            error: Error?)
}

class NodeActionsViewModel {
    private var action: ActionMenu?
    private var node: ListNode
    private var actionFinishedHandler: ActionFinishedCompletionHandler?
    private var coordinatorServices: CoordinatorServices?
    weak var delegate: NodeActionsViewModelDelegate?

    // MARK: Init

    init(node: ListNode,
         delegate: NodeActionsViewModelDelegate?,
         coordinatorServices: CoordinatorServices?) {
        self.node = node
        self.delegate = delegate
        self.coordinatorServices = coordinatorServices
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

                let eventBusService = sSelf.coordinatorServices?.eventBusService
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

                let eventBusService = sSelf.coordinatorServices?.eventBusService
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

                    let eventBusService = sSelf.coordinatorServices?.eventBusService
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

                    let eventBusService = sSelf.coordinatorServices?.eventBusService
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

                let eventBusService = sSelf.coordinatorServices?.eventBusService
                eventBusService?.publish(event: moveEvent, on: .mainQueue)
            }
            self?.handleResponse(error: error)
        }
    }

    private func requestPermanentlyDelete() {
        let title = LocalizationConstants.NodeActionsDialog.deleteTitle
        let message = String(format: LocalizationConstants.NodeActionsDialog.deleteMessage,
                             node.title)

        let cancelAction = MDCAlertAction(title: LocalizationConstants.Buttons.cancel)
        let deleteAction = MDCAlertAction(title: LocalizationConstants.Buttons.delete) { [weak self] _ in
            guard let sSelf = self else { return }

            TrashcanAPI.deleteDeletedNode(nodeId: sSelf.node.guid) { (_, error) in
                if error == nil {
                    let moveEvent = MoveEvent(node: sSelf.node, eventType: .permanentlyDelete)

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

        let mainQueue = coordinatorServices?.operationQueueService?.main
        let workerQueue = coordinatorServices?.operationQueueService?.worker

        mainQueue?.async { [weak self] in
            guard let sSelf = self else { return }
            downloadDialog = sSelf.showDownloadDialog(actionHandler: { _ in
                downloadRequest?.cancel()
            })

            workerQueue?.async {
                downloadRequest = sSelf.downloadNodeContent { destinationURL, error in
                    mainQueue?.asyncAfter(deadline: .now() + kSheetDismissDelay, execute: {
                        downloadDialog?.dismiss(animated: true,
                                                completion: {
                                                    sSelf.handleResponse(error: error)
                                                    if let url = destinationURL {
                                                        sSelf.displayActivityViewController(for: url)
                                                    }
                                                })
                    })
                }
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
            sSelf.delegate?.nodeActionFinished(with: sSelf.action, node: sSelf.node, error: error)
        }
    }

    // MARK: - Download node content

    private func showDownloadDialog(actionHandler: @escaping (MDCAlertAction) -> Void) -> MDCAlertController? {
        if let downloadDialogView: DownloadDialog = DownloadDialog.fromNib() {
            let themingService = coordinatorServices?.themingService
            downloadDialogView.messageLabel.text =
                String(format: LocalizationConstants.NodeActionsDialog.downloadMessage,
                       node.title)
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

    private func downloadNodeContent(completionHandler: @escaping (URL?, APIError?) -> Void) -> DownloadRequest? {
        let requestBuilder = NodesAPI.getNodeContentWithRequestBuilder(nodeId: self.node.guid)
        let downloadURL = URL(string: requestBuilder.URLString)

        var documentsURL = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask)[0]
        documentsURL.appendPathComponent(node.title)

        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (documentsURL, [.removePreviousFile])
        }

        if let url = downloadURL {
            return Alamofire.download(url,
                                      parameters: requestBuilder.parameters,
                                      headers: AlfrescoContentAPI.customHeaders,
                                      to: destination).response { response in
                                        if let destinationUrl = response.destinationURL,
                                           let httpURLResponse = response.response {
                                            if (200...299).contains(httpURLResponse.statusCode) {
                                                completionHandler(destinationUrl, nil)
                                            } else {
                                                let error = APIError(domain: "",
                                                                     code: httpURLResponse.statusCode)
                                                completionHandler(nil, error)
                                            }
                                        }
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

        activityViewController.completionWithItemsHandler = { [weak self] (activity, success, items, error) in
            guard let sSelf = self else { return }

            clearController.dismiss(animated: false) {
                // Will not base check on error code as used constants have been deprecated
                if (activity?.rawValue.contains(kSaveToCameraRollAction)) != nil && !success {
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
