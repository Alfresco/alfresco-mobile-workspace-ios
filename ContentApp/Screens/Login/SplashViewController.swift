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
    func showBackPadButton(enable: Bool)
}

class SplashViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!

    @IBOutlet weak var whiteAlphaView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var blurEfectView: UIVisualEffectView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var copyrightLabel: UILabel!

    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!

    weak var coordinatorDelegate: SplashScreenCoordinatorDelegate?
    weak var navigationControllerFromContainer: UINavigationController?

    var applyAnimations: Bool = true
    var shadowLayer: CALayer?
    let shadowLayerRadius: Float = 50
    let shadowLayerOpacity: Float = 0.4

    var observation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()

        logoImageView.isHidden = false
        whiteAlphaView.applyCornerRadius(with: 10)
        containerView.applyCornerRadius(with: 10)
        blurEfectView.applyCornerRadius(with: 10)

        coordinatorDelegate?.showLoginContainerView()

        addMaterialComponentsTheme()
        addLocalization()

        containerViews(alpha: 0.0, hidden: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.backButton.isHidden = true
        if applyAnimations {
            applyAnimations = false
            animateLogo()
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

    func animateLogo() {
        self.logoWidthConstraint.constant += 30.0
        UIView.animate(withDuration: kAnimationSplashScreenLogo, animations: { [weak self] in
            guard let sSelf = self else { return }
            sSelf.view.layoutIfNeeded()
        }) { [weak self] _ in
            guard let sSelf = self else { return }
            sSelf.logoImageView.isHidden = true
            sSelf.animateContainerViews()
        }
    }

    func animateContainerViews() {
        self.containerViews(alpha: 0.0, hidden: false)
        self.shadowLayer = self.shadowView.dropContourShadow(opacity: self.shadowLayerOpacity, radius: self.shadowLayerRadius)
        self.shadowLayer?.fadeAnimation(with: .fadeIn, duration: Float(kAnimationSplashScreenContainerViews), completionHandler: nil)
        UIView.animate(withDuration: kAnimationSplashScreenContainerViews) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.containerViews(alpha: 1.0, hidden: false)
        }
    }

    func containerViews(alpha: CGFloat, hidden: Bool) {
        containerView.alpha = alpha
        blurEfectView.alpha = alpha
        shadowView.alpha = alpha
        copyrightLabel.alpha = alpha
        whiteAlphaView.isHidden = hidden
        containerView.isHidden = hidden
        blurEfectView.isHidden = hidden
        shadowView.isHidden = hidden
        copyrightLabel.isHidden = hidden
    }

    // MARK: - IBActions

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.coordinatorDelegate?.popViewControllerFromContainer()
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

        backButton.tintColor = theme.activeTheme?.loginButtonColor
    }
}

extension SplashViewController: SplashScreenDelegate {

    func showBackPadButton(enable: Bool) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            backButton.isHidden = !enable
        } else {
            backButton.isHidden = true
        }
    }

    func showAdvancedSettingsScreen() {
        coordinatorDelegate?.showAdvancedSettingsScreen()
    }
}

extension SplashViewController: StoryboardInstantiable { }
