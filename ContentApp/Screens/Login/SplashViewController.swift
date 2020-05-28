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

protocol SplashScreenDelegate: class {
    func showAdvancedSettingsScreen()
}

class SplashViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var whiteAlphaView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var blurEfectView: UIVisualEffectView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var copyrightLabel: UILabel!

    weak var coordinatorDelegate: SplashScreenCoordinatorDelegate?
    weak var navigationControllerFromContainer: UINavigationController?

    var applyShadow: Bool = true
    var shadowLayer: CALayer?
    let shadowLayerRadius: Float = 50
    let shadowLayerOpacity: Float = 0.4

    var observation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()

        whiteAlphaView.applyCornerRadius(with: 10)
        containerView.applyCornerRadius(with: 10)
        blurEfectView.applyCornerRadius(with: 10)

        coordinatorDelegate?.showLoginContainerView()

        addMaterialComponentsTheme()
        addLocalization()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.backButton.isHidden = true
        if applyShadow {
            self.shadowLayer = shadowView.dropContourShadow(opacity: shadowLayerOpacity, radius: shadowLayerRadius)
            applyShadow = false
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        shadowLayer?.removeFromSuperlayer()

        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let sSelf = self else { return }

            sSelf.shadowLayer = sSelf.shadowView.dropContourShadow(opacity: sSelf.shadowLayerOpacity, radius: sSelf.shadowLayerRadius)
            sSelf.shadowLayer?.fadeAnimation(with: .fadeIn, duration: 0.5, completionHandler: nil)
        }
    }

    // MARK: - IBActions

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationControllerFromContainer?.popViewController(animated: true)
        backButton.isHidden = (navigationControllerFromContainer?.viewControllers.count ?? 0 < 2)
    }

    // MARK: - Helpers

    func addLocalization() {
        copyrightLabel.text = String(format: LocalizationConstants.copyright, Calendar.current.component(.year, from: Date()))
    }

    func addMaterialComponentsTheme() {
        let theme = MaterialDesignThemingService()
        theme.activeTheme = DefaultTheme()
        copyrightLabel.textColor = theme.activeTheme?.loginCopyrightLabelColor
        copyrightLabel.font = theme.activeTheme?.loginCopyrightLabelFont
    }
}

extension SplashViewController: SplashScreenDelegate {
    func showAdvancedSettingsScreen() {
        coordinatorDelegate?.showAdvancedSettingsScreen()
    }
}

extension SplashViewController: StoryboardInstantiable { }
