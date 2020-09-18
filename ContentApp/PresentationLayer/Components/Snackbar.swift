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
    private var snackBar: MDCSnackbarMessage
    private var buttonTitle: String
    private var hideButton: Bool = false

    init(with message: String, type: SnackBarType, automaticallyDismisses: Bool = true, buttonTitle: String = LocalizationConstants.Buttons.snackbarConfirmation) {
        self.type = type
        self.buttonTitle = buttonTitle
        self.hideButton = (buttonTitle == "")
        self.snackBar = MDCSnackbarMessage(text: message)
        self.snackBar.automaticallyDismisses = automaticallyDismisses
        self.addButton()
        self.applyTheme()
    }

    // MARK: - Public methods

    func applyTheme() {
        let serviceRepository = ApplicationBootstrap.shared().serviceRepository
        let themingService = serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        let currentTheme = themingService?.activeTheme
        switch type {
        case .error:
            MDCSnackbarManager.default.snackbarMessageViewBackgroundColor = currentTheme?.errorColor
        case .approve:
            MDCSnackbarManager.default.snackbarMessageViewBackgroundColor = currentTheme?.primaryColor
        case .warning:
            MDCSnackbarManager.default.snackbarMessageViewBackgroundColor = currentTheme?.errorOnColor
        }
    }

    func show(completion: (() -> Void)?) {
        snackBar.completionHandler = { (userInitiated) in
            if userInitiated {
                if let completion = completion {
                    completion()
                }
            }
        }
        MDCSnackbarManager.default.show(snackBar)
    }

    func hideButton(_ hidden: Bool) {
        hideButton = false
        snackBar.action = nil
    }

    func dismiss() {
        MDCSnackbarManager.default.dismissAndCallCompletionBlocks(withCategory: self.snackBar.category)
    }

    class func dimissAll() {
        MDCSnackbarManager.default.dismissAndCallCompletionBlocks(withCategory: nil)
    }

    // MARK: - Private methods

    private func addButton() {
        guard !hideButton  else { return }
        let action = MDCSnackbarMessageAction()
        action.title = buttonTitle
        snackBar.action = action
    }
}
