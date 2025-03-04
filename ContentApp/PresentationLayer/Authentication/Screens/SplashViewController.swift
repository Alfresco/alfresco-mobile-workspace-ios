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

protocol SplashScreenDelegate: AnyObject {
    func showAdvancedSettingsScreen()
    func backPadButtonNeedsTo(hide: Bool)
    func backPadButton(userInteraction: Bool)
}

class SplashViewController: SystemThemableViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!

    @IBOutlet weak var whiteAlphaView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var blurEfectView: UIVisualEffectView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var copyrightLabel: UILabel!

    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!

    weak var coordinatorDelegate: SplashScreenCoordinatorDelegate?

    var applyAnimations = true
    var isAnimationInProgress = false
    var wasRotatedInAnimationProgress = false
    var shadowLayer: CALayer?

    let animationLogo = 0.0
    let animationContainerViews = 0.5
    let increaseLogoWidth: CGFloat = 30.0
    let containerShadowLayerRadius: Float = 50.0
    let containerShadowLayerOpacity: Float = 0.4
    let containerShadowFadeAnimation = 0.5
    let containerCornerRadius: Float = 10.0

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        logoImageView.isHidden = false
        whiteAlphaView.applyCornerRadius(with: containerCornerRadius)
        containerView.applyCornerRadius(with: containerCornerRadius)
        blurEfectView.applyCornerRadius(with: containerCornerRadius)

        addLocalization()

        containerViews(alpha: 0.0, hidden: true)
        self.backButton.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if applyAnimations {
            applyAnimations = false
            isAnimationInProgress = true
            animateLogo()
        }
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        shadowLayer?.removeFromSuperlayer()
        if isAnimationInProgress {
            wasRotatedInAnimationProgress = true
            return
        }
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let sSelf = self else { return }
            sSelf.view.frame.size = size
            sSelf.view.layoutIfNeeded()
            sSelf.shadowLayer = sSelf.shadowView.dropContourShadow(opacity: sSelf.containerShadowLayerOpacity,
                                                                   radius: sSelf.containerShadowLayerRadius)
            sSelf.shadowLayer?.fadeAnimation(with: .fadeIn, duration: sSelf.containerShadowFadeAnimation, completionHandler: nil)
        }
    }

    // MARK: - IBActions

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.coordinatorDelegate?.popViewControllerFromContainer()
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    // MARK: - Helpers

    func addLocalization() {
        copyrightLabel.text = String(format: LocalizationConstants.copyright,
                                     Calendar.current.component(.year, from: Date()))
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        copyrightLabel.applyStyleCaptionOnSurface60(theme: currentTheme)
        copyrightLabel.textAlignment = .center
        backButton.tintColor = currentTheme.onSurface70Color
        view.backgroundColor = currentTheme.surfaceColor
        whiteAlphaView.backgroundColor = currentTheme.surfaceColor
        containerView.backgroundColor =
            (UIDevice.current.userInterfaceIdiom == .pad) ? .clear : currentTheme.surfaceColor
    }

    func animateLogo() {
        self.logoWidthConstraint.constant += increaseLogoWidth

        UIView.animate(withDuration: animationLogo, animations: {
            [weak self] in
            guard let sSelf = self else { return }
            sSelf.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            guard let sSelf = self else { return }
            sSelf.logoImageView.isHidden = true
            sSelf.coordinatorDelegate?.showLoginContainerView()
            sSelf.animateContainerViews()
        })
    }

    func animateContainerViews() {
        self.containerViews(alpha: 0.0, hidden: false)
        self.wasRotatedInAnimationProgress = false
        self.shadowLayer = self.shadowView.dropContourShadow(opacity: self.containerShadowLayerOpacity,
                                                             radius: self.containerShadowLayerRadius)
        self.shadowLayer?.fadeAnimation(with: .fadeIn,
                                        duration: TimeInterval(animationContainerViews),
                                        completionHandler: { [weak self] in
                                                guard let sSelf = self,
                                                      sSelf.wasRotatedInAnimationProgress == true else {
                                                    return
                                                }

                                                sSelf.shadowLayer?.removeFromSuperlayer()
                                                sSelf.shadowLayer =
                                                    sSelf.shadowView.dropContourShadow(opacity: sSelf.containerShadowLayerOpacity,
                                                                                       radius: sSelf.containerShadowLayerRadius)
                                                sSelf.shadowLayer?.fadeAnimation(with: .fadeIn,
                                                                                 duration: 0.0,
                                                                                 completionHandler: nil)
                                            })

        UIView.animate(withDuration: animationContainerViews, animations: { [weak self] in
            guard let sSelf = self else { return }
            sSelf.containerViews(alpha: 1.0, hidden: false)
        }, completion: { [weak self] _ in
            guard let sSelf = self else { return }
            sSelf.isAnimationInProgress = false
        })
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
}

// MARK: - SplashScreen Delegate

extension SplashViewController: SplashScreenDelegate {
    
    func showAdvancedSettingsScreen() {
        self.view.endEditing(true)
        coordinatorDelegate?.showAdvancedSettingsScreen()
    }
    
    func backPadButtonNeedsTo(hide: Bool) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            backButton.isHidden = hide
        } else {
            backButton.isHidden = true
        }
    }

    func backPadButton(userInteraction: Bool) {
        backButton.isUserInteractionEnabled = userInteraction
    }
}

// MARK: - Storyboard Instantiable

extension SplashViewController: StoryboardInstantiable { }
