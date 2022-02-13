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
    var coordinatorServices: CoordinatorServices?
    var repository: ServiceRepository {
        return ApplicationBootstrap.shared().repository
    }
    var accountService: AccountService? {
        let identifier = AccountService.identifier
        return repository.service(of: identifier) as? AccountService
    }
    var themingService: MaterialDesignThemingService? {
        let identifier = MaterialDesignThemingService.identifier
        return repository.service(of: identifier) as? MaterialDesignThemingService
    }
    var activeAccount: AccountProtocol? {
        didSet {
            if let activeAccountIdentifier = activeAccount?.identifier {
                UserDefaultsModel.set(value: activeAccountIdentifier, for: KeyConstants.Save.activeAccountIdentifier)
            } else {
                UserDefaultsModel.remove(forKey: KeyConstants.Save.activeAccountIdentifier)
            }
        }
    }
    var nodeOperations: NodeOperations {
        return NodeOperations(accountService: accountService)
    }
    let connectivityService = ApplicationBootstrap.shared().repository.service(of: ConnectivityService.identifier) as? ConnectivityService

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
        themingService?.activateUserSelectedTheme()
        applyComponentsThemes()
    }

    func applyComponentsThemes() {
        // Override in subclass
        let activeTheme = themingService?.activeTheme
        offlineModeView?.backgroundColor = activeTheme?.onSurface5Color
        offlineModeIcon?.tintColor = activeTheme?.onSurfaceColor
    }
}
