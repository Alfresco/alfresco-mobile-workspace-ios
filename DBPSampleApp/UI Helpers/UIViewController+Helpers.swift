//
//  UIViewController+Helpers.swift
//  DBPSampleApp
//
//  Created by Emanuel Lupu on 09/10/2019.
//  Copyright © 2019 Alfresco. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialSnackbar_ColorThemer
import MaterialComponents.MaterialSnackbar

extension UIViewController {
    func showToastWithMessage(message: String) {
        showToastWithString(string: message, isError: false)
    }
    
    func showToastWithErrorMessage(message: String) {
        showToastWithString(string: message, isError: true)
    }
    
    func showToastWithString(string: String, isError: Bool) {
        let snackBarMessage = MDCSnackbarMessage()
        MDCSnackbarColorThemer.applySemanticColorScheme(isError ? ApplicationScheme.shared.errorColorScheme : ApplicationScheme.shared.colorScheme)
        snackBarMessage.text = string
        MDCSnackbarManager.show(snackBarMessage)
    }
}
