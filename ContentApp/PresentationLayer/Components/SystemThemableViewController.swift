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

import UIKit

struct ControllerRotation {
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            if UIDevice.current.userInterfaceIdiom != .pad {
                delegate.orientationLock = orientation
            }
        }
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
    private var offlineModeView: UIView?
    private var offlineModeIcon: UIImageView?

    private var kvoConnectivity: NSKeyValueObservation?

    private let offlineModeViewRatio: CGFloat = 14.0
    private let offlineModeIconRatio: CGFloat = 10.0
    private let offlineModeShadowRadius: Float = 5.0
    private let offlineModeShadowOpacity: Float = 0.25

    override func viewDidLoad() {
        super.viewDidLoad()
        observeConnectivity()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyComponentsThemes()
        ControllerRotation.lockOrientation(.portrait)

        handleConnectivity()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.addAccessibilityIdentifersToTitle()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinatorServices?.themingService?.activateUserSelectedTheme()
        applyComponentsThemes()
        UIApplication.shared.windows[0].backgroundColor = coordinatorServices?.themingService?.activeTheme?.surfaceColor
    }

    func applyComponentsThemes() {
        // Override in subclass
        let activeTheme = coordinatorServices?.themingService?.activeTheme
        offlineModeView?.backgroundColor = activeTheme?.onSurface5Color
        offlineModeIcon?.tintColor = activeTheme?.onSurfaceColor
    }

    // MARK: Private Interface

    private func addOfflineModeIcon() {
        offlineModeView?.removeFromSuperview()

        let centerPoint = settingsButton.imageView?.center ?? .zero
        let offlineView = UIView(frame: CGRect(origin: centerPoint,
                                                   size: CGSize(width: offlineModeViewRatio,
                                                                height: offlineModeViewRatio)))
        offlineView.layer.cornerRadius = offlineModeViewRatio/2
        offlineView.isUserInteractionEnabled = false

        let distanceXY = (offlineModeViewRatio - offlineModeIconRatio) / 2
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: distanceXY,
                                                                  y: distanceXY),
                                                  size: CGSize(width: offlineModeIconRatio,
                                                               height: offlineModeIconRatio)))
        imageView.image = UIImage(named: "ic-offline-mode")
        imageView.isUserInteractionEnabled = false

        offlineView.addSubview(imageView)
        settingsButton.addSubview(offlineView)

        self.offlineModeView = offlineView
        self.offlineModeIcon = imageView

        let activeTheme = coordinatorServices?.themingService?.activeTheme
        offlineModeView?.backgroundColor = activeTheme?.onSurface5Color
        offlineModeIcon?.tintColor = activeTheme?.onSurfaceColor

        offlineModeView?.dropShadow(opacity: offlineModeShadowOpacity,
                                    radius: offlineModeShadowRadius)
    }

    // MARK: Connectivity Helpers

    private func observeConnectivity() {
        let connectivityService = coordinatorServices?.connectivityService
        kvoConnectivity = connectivityService?.observe(\.status,
                                                       options: [.new],
                                                       changeHandler: { [weak self] (_, _) in
                                                        guard let sSelf = self else { return }
                                                        sSelf.handleConnectivity()
                                                       })
    }

    private func handleConnectivity() {
        let connectivityService = coordinatorServices?.connectivityService
        if connectivityService?.hasInternetConnection() == false {
            addOfflineModeIcon()
        } else {
            offlineModeView?.removeFromSuperview()
        }
    }
}
