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

extension ListComponentViewController: NodeActionsViewModelDelegate,
                                       CreateNodeViewModelDelegate {

    func handleCreatedNode(node: ListNode?, error: Error?) {
        if node == nil && error == nil {
            return
        } else if let error = error {
            self.display(error: error)
        } else {
            displaySnackbar(with: String(format: LocalizationConstants.Approved.created,
                                         node?.truncateTailTitle() ?? ""),
                            type: .approve)
        }
    }

    func handleFinishedAction(with action: ActionMenu?,
                              node: ListNode?,
                              error: Error?) {
        if let error = error {
            self.display(error: error)
        } else {
            guard let action = action else { return }

            if action.type.isFavoriteActions {
                handleFavorite(action: action)
            } else if action.type.isMoveActions {
                handleMove(action: action, node: node)
            } else if action.type.isCreateActions {
                handleSheetCreate(action: action)
            } else if action.type.isDownloadActions {
                handleDownload(action: action, node: node)
            }
        }
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

    func handleMove(action: ActionMenu, node: ListNode?) {
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
            snackBarMessage = String(format: LocalizationConstants.Approved.movedFileFolderSuccess,
                                     node.truncateTailTitle())
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

    func handleSheetCreate(action: ActionMenu) {
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
        default: break
        }
    }

    func handleDownload(action: ActionMenu, node: ListNode?) {
        var snackBarMessage: String?
        guard let node = node else { return }
        switch action.type {
        case .markOffline:
            snackBarMessage = String(format: LocalizationConstants.Approved.removeOffline,
                                     node.truncateTailTitle())
        case .removeOffline:
            snackBarMessage = String(format: LocalizationConstants.Approved.markOffline,
                                     node.truncateTailTitle())
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
