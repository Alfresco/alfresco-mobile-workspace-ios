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

import Foundation
import UIKit
import MaterialComponents.MaterialSnackbar

enum SnackBarType {
    case error
    case approve
    case warning
}

class Snackbar {
    private var type: SnackBarType
    private var snackBar = MDCSnackbarMessage()
    private var buttonTitle: String
    private var hideButton: Bool = false

    init(with message: String, type: SnackBarType, automaticallyDismisses: Bool = true, buttonTitle: String = LocalizationConstants.Buttons.okConfirmation) {
        self.type = type
        self.buttonTitle = buttonTitle
        self.hideButton = (buttonTitle == "")
        self.snackBar.text = message
        self.snackBar.automaticallyDismisses = automaticallyDismisses
        self.addButton()
    }

    // MARK: - Public methods

    func applyThemingService(_ themingService: MaterialDesignThemingService) {
        switch type {
        case .error:
            MDCSnackbarManager.snackbarMessageViewBackgroundColor = themingService.activeTheme?.snackbarErrorColor
        case .approve:
            MDCSnackbarManager.snackbarMessageViewBackgroundColor = themingService.activeTheme?.snackbarApproved
        case .warning:
            MDCSnackbarManager.snackbarMessageViewBackgroundColor = themingService.activeTheme?.snackbarWarning
        }
    }

    func show(completion: ((Bool) -> Void)?) {
        snackBar.completionHandler = completion
        MDCSnackbarManager.show(snackBar)
    }

    func hideButton(_ hidden: Bool) {
        hideButton = false
        snackBar.action = nil
    }

    func dismiss() {
        MDCSnackbarManager.dismissAndCallCompletionBlocks(withCategory: nil)
    }

    // MARK: - Private methods

    private func addButton() {
        guard hideButton  else {
            return
        }
        let action = MDCSnackbarMessageAction()
        action.title = buttonTitle
        snackBar.action = action
    }
}
