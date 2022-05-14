//
// Copyright (C) 2005-2022 Alfresco Software Limited.
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

extension SystemSearchViewController: NodeActionsViewModelDelegate,
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
                self.openNodeDelegate?.openNode(with: node)
            }
        }
    }

    func handleFinishedAction(with action: ActionMenu?,
                              node: ListNode?,
                              error: Error?) {
        if let error = error {
            self.display(error: error)
        } else {
            guard let action = action else { return }
            if action.type.isCreateActions {
                handleSheetCreate(action: action)
            }
        }
    }

    func handleSheetCreate(action: ActionMenu) {
        switch action.type {
        case .createMSWord, .createMSExcel, .createMSPowerPoint,
             .createFolder:
            listItemActionDelegate?.showNodeCreationDialog(with: action,
                                                           delegate: self)
        case .createMedia: break
            
        case .uploadMedia: break
            
        case .uploadFiles: break
            
        default: break
        }
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
