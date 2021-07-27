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
import MaterialComponents.MaterialDialogs

public typealias CameraKitDismissHandler = (_ option: Bool) -> Void

class CameraKit {
    static var theme: CameraKitTheme?
    static var localization: CameraKitLocalization?
    static var location: GPSLocation?

    static let cameraWorkerQueue = DispatchQueue(label: "CameraWorkerQueue")

    static func applyTheme(theme: CameraKitTheme) {
        self.theme = theme
    }

    static func applyLocalization(localization: CameraKitLocalization) {
        self.localization = localization
    }

    static func shouldDiscard(numberOfCapturedAssets: Int,
                              in viewController: UIViewController,
                              handler: @escaping CameraKitDismissHandler) {
        
        let title = (numberOfCapturedAssets == 1) ? LocalizationConstants.Dialog.discardPhotoTitle
            : LocalizationConstants.Dialog.discardPhotosTitle
        let message = (numberOfCapturedAssets == 1) ? LocalizationConstants.Dialog.discardPhotoMessage
            : String(format: LocalizationConstants.Dialog.discardPhotosMessage, numberOfCapturedAssets)

        let cancelAction = MDCAlertAction(title: LocalizationConstants.General.cancel) { _ in
            handler(false)
        }
        cancelAction.accessibilityIdentifier = "cancelActionButton"

        let discardAction = MDCAlertAction(title: LocalizationConstants.General.discard) { _ in
            handler(true)
        }
        discardAction.accessibilityIdentifier = "discardActionButton"
        
        DispatchQueue.main.async {
            _ = viewController.showDialog(title: title,
                                          message: message,
                                          actions: [cancelAction, discardAction],
                                          completionHandler: {})
        }
    }
}
