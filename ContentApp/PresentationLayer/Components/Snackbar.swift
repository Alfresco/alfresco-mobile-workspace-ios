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

    init(with message: String, type: SnackBarType, automaticallyDismisses: Bool = true) {
        self.type = type
        self.snackBar = MDCSnackbarMessage(text: message)
        self.snackBar.automaticallyDismisses = automaticallyDismisses
        self.applyTheme()
    }

    // MARK: - Public methods

    func applyTheme() {
        let serviceRepository = ApplicationBootstrap.shared().serviceRepository
        let themingService = serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        guard let currentTheme = themingService?.activeTheme else { return }
        MDCSnackbarManager.default.snackbarMessageViewBackgroundColor = currentTheme.onSurfaceColor
        MDCSnackbarManager.default.messageFont = currentTheme.body2TextStyle.font
        MDCSnackbarManager.default.messageTextColor = currentTheme.onPrimaryColor
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

    func dismiss() {
        MDCSnackbarManager.default.dismissAndCallCompletionBlocks(withCategory: self.snackBar.category)
    }

    class func dimissAll() {
        MDCSnackbarManager.default.dismissAndCallCompletionBlocks(withCategory: nil)
    }
}
