//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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

import Foundation
import UIKit
import MaterialComponents

extension ListComponentViewController: NodeActionsViewModelDelegate,
                                       CreateNodeViewModelDelegate {

    func handleCreatedNode(node: ListNode?, error: Error?, isUpdate: Bool) {
        if node == nil && error == nil {
            return
        } else if let error = error {
            self.display(error: error)
        } else {
            if isUpdate {
                displaySnackbar(with: String(format: LocalizationConstants.Approved.updated,
                                             node?.truncateTailTitle() ?? ""),
                                type: .approve)
            } else {
                displaySnackbar(with: String(format: LocalizationConstants.Approved.created,
                                             node?.truncateTailTitle() ?? ""),
                                type: .approve)
                self.openFolderAfterCreate(for: node)
            }
        }
    }

    func handleFinishedAction(with action: ActionMenu?,
                              node: ListNode?,
                              error: Error?,
                              multipleNodes: [ListNode]) {
        if let error = error {
            self.display(error: error)
        } else {
            guard let action = action else { return }
            if action.type.isFavoriteActions {
                handleFavorite(action: action)
            } else if action.type.isMoveActions {
                handleMove(action: action, node: node, multipleNodes: multipleNodes)
            } else if action.type.isCreateActions {
                handleSheetCreate(action: action, node: node)
            } else if action.type.isDownloadActions {
                handleDownload(action: action, node: node, multipleNodes: multipleNodes)
            } else if action.type.isWorkflowActions {
                let nodes = multipleNodes
                if nodes.isEmpty {
                    handleStartWorkflow(action: action, node: [node!])
                } else {
                    handleStartWorkflow(action: action, node: nodes)
                }
            }
            logEvent(with: action, node: node)
        }
        resetMultipleSelectionView()
    }

    func handleFavorite(action: ActionMenu) {
        var snackBarMessage: String?
        switch action.type {
        case .addFavorite:
            snackBarMessage = LocalizationConstants.Approved.removedFavorites
        case .removeFavorite:
            snackBarMessage = LocalizationConstants.Approved.addedFavorites
        default: break
        }
        displaySnackbar(with: snackBarMessage, type: .approve)
    }

    func handleMove(action: ActionMenu, node: ListNode?, multipleNodes: [ListNode]) {
        var snackBarMessage: String?
        guard let node = node else { return }
        switch action.type {
        case .moveTrash:
            snackBarMessage = String(format: LocalizationConstants.Approved.movedTrash,
                                     node.truncateTailTitle())
        case .restore:
            snackBarMessage = String(format: LocalizationConstants.Approved.restored,
                                     node.truncateTailTitle())
        case .permanentlyDelete:
            snackBarMessage = String(format: LocalizationConstants.Approved.deleted,
                                     node.truncateTailTitle())
        case .moveToFolder:
            if multipleNodes.count > 1 {
                snackBarMessage = String(format: LocalizationConstants.Approved.movedMultipleFileFolderSuccess,
                                         multipleNodes.count)
            } else {
                snackBarMessage = String(format: LocalizationConstants.Approved.movedFileFolderSuccess,
                                         node.truncateTailTitle())
            }
            self.perform(#selector(triggerMoveNotifyService), with: nil, afterDelay: 1.0)
        default: break
        }
        displaySnackbar(with: snackBarMessage, type: .approve)
    }
    
    @objc func triggerMoveNotifyService() {
        let notificationName = Notification.Name(rawValue: KeyConstants.Notification.moveFileFolderFinished)
        let notification = Notification(name: notificationName)
        NotificationCenter.default.post(notification)
    }

    func handleSheetCreate(action: ActionMenu, node: ListNode?) {
        switch action.type {
        case .createMSWord, .createMSExcel, .createMSPowerPoint,
             .createFolder:
            listItemActionDelegate?.showNodeCreationDialog(with: action,
                                                           delegate: self)
        case .createMedia:
            listItemActionDelegate?.showCamera()
        case .uploadMedia:
            listItemActionDelegate?.showPhotoLibrary()
        case .uploadFiles:
            listItemActionDelegate?.showFiles()
        case .renameNode:
            listItemActionDelegate?.renameNodeForListItem(for: node, actionMenu: action, delegate: self)
        case .scanDocuments:
            listItemActionDelegate?.scanDocumentsAction()
        default: break
        }
    }

    func handleDownload(action: ActionMenu, node: ListNode?, multipleNodes: [ListNode]) {
        var snackBarMessage: String?
        guard let node = node else { return }
        switch action.type {
        case .markOffline:
            if multipleNodes.count > 1 {
                snackBarMessage = String(format: LocalizationConstants.Approved.removeOfflineMultipleNodes,
                                         multipleNodes.count)
            } else {
                snackBarMessage = String(format: LocalizationConstants.Approved.removeOffline,
                                         node.truncateTailTitle())
            }
            
        case .removeOffline:
            if multipleNodes.count > 1 {
                snackBarMessage = String(format: LocalizationConstants.Approved.markOfflineMultipleNodes,
                                         multipleNodes.count)
            } else {
                snackBarMessage = String(format: LocalizationConstants.Approved.markOffline,
                                         node.truncateTailTitle())
            }
            
        default: break
        }
        displaySnackbar(with: snackBarMessage, type: .approve)
    }

    func display(error: Error) {
        var snackBarMessage = ""
        switch error.code {
        case ErrorCodes.Swagger.timeout:
            snackBarMessage = LocalizationConstants.Errors.errorTimeout
        case ErrorCodes.Swagger.nodeName:
            snackBarMessage = LocalizationConstants.Errors.errorFolderSameName
        default:
            snackBarMessage = LocalizationConstants.Errors.errorUnknown
        }
        displaySnackbar(with: snackBarMessage, type: .error)
    }

    func displaySnackbar(with message: String?, type: SnackBarType?) {
        if let message = message, let type = type {
            let snackBar = Snackbar(with: message, type: type)
            snackBar.snackBar.presentationHostViewOverride = view
            snackBar.show(completion: nil)
        }
    }
}

// MARK: - Analytics
extension ListComponentViewController {
    
    func logEvent(with action: ActionMenu?, node: ListNode?) {
        guard let action = action else { return }
        AnalyticsManager.shared.fileActionEvent(for: node, action: action)
    }
}

// MARK: - Workflow
extension ListComponentViewController {
    
    func handleStartWorkflow(action: ActionMenu, node: [ListNode]) {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.startableWorkflowList) as? StartableWorkflowsViewController {
            let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
            viewController.coordinatorServices = coordinatorServices
            self.present(bottomSheet, animated: true)
            viewController.didSelectAction = { [weak self] (appDefinition) in
                guard let sSelf = self else { return }
                sSelf.startWorkflowAction(appDefinition: appDefinition, node: node)
            }
        }
    }
    
    private func startWorkflowAction(appDefinition: WFlowAppDefinitions?, node: [ListNode]) {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.startWorkflowPage) as? StartWorkflowViewController {
            viewController.coordinatorServices = coordinatorServices
            viewController.viewModel.appDefinition = appDefinition
            viewController.viewModel.isEditMode = true
            viewController.viewModel.selectedAttachments = node
            viewController.viewModel.tempWorkflowId = UIFunction.currentTimeInMilliSeconds()
            self.navigationViewController?.pushViewController(viewController, animated: true)
        }
    }
}
