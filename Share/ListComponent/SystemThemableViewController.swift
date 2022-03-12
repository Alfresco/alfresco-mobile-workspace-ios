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
import MaterialComponents.MaterialDialogs

struct ControllerRotation {
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
    }

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask,
                                andRotateTo rotateOrientation: UIInterfaceOrientation) {
        self.lockOrientation(orientation)

        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
}

class SystemThemableViewController: UIViewController {
    var coordinatorServices = CoordinatorServices()
    private var offlineModeView: UIView?
    private var offlineModeIcon: UIImageView?

    private var kvoConnectivity: NSKeyValueObservation?

    private let offlineModeViewRatio: CGFloat = 14.0
    private let offlineModeIconRatio: CGFloat = 10.0
    private let offlineModeShadowRadius: Float = 5.0
    private let offlineModeShadowOpacity: Float = 0.25

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyComponentsThemes()
        ControllerRotation.lockOrientation(.portrait)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.addAccessibilityIdentifersToTitle()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinatorServices.themingService?.activateUserSelectedTheme()
        applyComponentsThemes()
    }

    func applyComponentsThemes() {
        // Override in subclass
        let activeTheme = coordinatorServices.themingService?.activeTheme
        offlineModeView?.backgroundColor = activeTheme?.onSurface5Color
        offlineModeIcon?.tintColor = activeTheme?.onSurfaceColor
    }
    
    func showAlertInternetUnavailable() {
        let title = LocalizationConstants.Dialog.internetUnavailableTitle
        let message = LocalizationConstants.Dialog.internetUnavailableMessage
        let confirmAction = MDCAlertAction(title: LocalizationConstants.General.ok) { [weak self] _ in
            guard let sSelf = self else { return }
            sSelf.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
        confirmAction.accessibilityIdentifier = "confirmActionButton"
        _ = self.showDialog(title: title,
                            message: message,
                            actions: [confirmAction],
                            completionHandler: {})
    }
    
    func clearLocalDatabaseIfNecessary() {
        let uploadedNodes = SyncSharedNodes.getSavedUploadedNodes()
        for node in uploadedNodes {
            let uploadDataAccessor = UploadTransferDataAccessor()
            uploadDataAccessor.remove(transfer: node)
        }
        UserDefaultsModel.remove(forKey: KeyConstants.AppGroup.uploadedNodes)
    }
    
    func clearDatabaseOnLogout() {
        let isLogout = UserDefaultsModel.value(for: KeyConstants.AppGroup.userDidInitiateLogout) as? Bool ?? false
        if isLogout {
            let uploadTransfer = UploadTransferDataAccessor()
            let nodes = uploadTransfer.queryAllForPendingUploadNodes()
            for node in nodes {
                uploadTransfer.remove(transfer: node)
            }
            UserDefaultsModel.set(value: false, for: KeyConstants.AppGroup.userDidInitiateLogout)
        }
    }
}
