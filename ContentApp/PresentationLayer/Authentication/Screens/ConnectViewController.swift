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
import AlfrescoAuth

import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class ConnectViewController: SystemThemableViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var connectTextField: MDCOutlinedTextField!
    @IBOutlet weak var connectButton: MDCButton!
    @IBOutlet weak var advancedSettingsButton: MDCButton!
    @IBOutlet weak var needHelpButton: MDCButton!
    @IBOutlet weak var copyrightLabel: UILabel!

    weak var splashScreenDelegate: SplashScreenDelegate?
    weak var connectScreenCoordinatorDelegate: ConnectScreenCoordinatorDelegate?
    var viewModel: ConnectViewModel?

    var keyboardHandling: KeyboardHandling? = KeyboardHandling()
    var openKeyboard = true
    var errorShowInProgress = false
    var activityIndicator: ActivityIndicatorView?

    var enableConnectButton = false {
        didSet {
            connectButton.isEnabled = enableConnectButton
        }
    }

    let animationOpenKeyboard = 0.5

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = UIDevice.current.userInterfaceIdiom == .pad
        viewModel?.delegate = self
        viewModel?.aimsViewModel?.delegate = self

        addLocalization()
        addAccessibility()
        enableConnectButton = !connectTextField.isEmpty()
        activityIndicator = ActivityIndicatorView(currentTheme: coordinatorServices?.themingService?.activeTheme)
        activityIndicator?.label(text: LocalizationConstants.Labels.conneting)
        if let activityIndicator = activityIndicator {
            UIApplication.shared.windows[0].addSubview(activityIndicator)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar(hide: true)
        splashScreenDelegate?.backPadButtonNeedsTo(hide: true)
        activityIndicator?.applyTheme(coordinatorServices?.themingService?.activeTheme)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if openKeyboard {
            openKeyboard = false
            DispatchQueue.main.asyncAfter(deadline: .now() + animationOpenKeyboard,
                execute: { [weak self] in
                guard let sSelf = self else { return }
                sSelf.connectTextField.becomeFirstResponder()
            })
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationBar(hide: false)
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        activityIndicator?.applyTheme(coordinatorServices?.themingService?.activeTheme)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        activityIndicator?.recalculateSize(size)
    }

    // MARK: - IBActions

    @IBAction func connectButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let connectURL = connectTextField.text else {
            return
        }
        activityIndicator?.state = .isLoading
        viewModel?.availableAuthType(for: connectURL, in: self)
    }

    @IBAction func advancedSettingsButtonTapped(_ sender: UIButton) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            splashScreenDelegate?.showAdvancedSettingsScreen()
        } else {
            connectScreenCoordinatorDelegate?.showAdvancedSettingsScreen()
        }
        Snackbar.dimissAll()
    }

    @IBAction func needHelpButtonTapped(_ sender: UIButton) {
        connectScreenCoordinatorDelegate?.showNeedHelpSheet()
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    // MARK: - Helpers

    func addLocalization() {
        productLabel.text = LocalizationConstants.productName
        connectTextField.label.text = LocalizationConstants.TextFieldPlaceholders.connect
        connectButton.setTitle(LocalizationConstants.Buttons.connect, for: .normal)
        connectButton.setTitle(LocalizationConstants.Buttons.connect, for: .disabled)
        advancedSettingsButton.setTitle(LocalizationConstants.Buttons.advancedSetting, for: .normal)
        needHelpButton.setTitle(LocalizationConstants.Buttons.needHelpAlfresco, for: .normal)
        copyrightLabel.text = String(format: LocalizationConstants.copyright,
                                     Calendar.current.component(.year, from: Date()))
    }
    
    private func addAccessibility() {
        productLabel.accessibilityIdentifier = "title"
        productLabel.accessibilityLabel = LocalizationConstants.Accessibility.title
        productLabel.accessibilityValue = LocalizationConstants.productName
        
        connectTextField.accessibilityIdentifier = "connect-to-text-field"
        connectTextField.accessibilityHint = LocalizationConstants.TextFieldPlaceholders.connect
        connectTextField.accessibilityLabel = LocalizationConstants.Accessibility.connectToTextField
        connectTextField.accessibilityValue = connectTextField.text
        
        connectButton.accessibilityIdentifier = "connect-button"
        connectButton.accessibilityLabel = LocalizationConstants.Buttons.connect

        advancedSettingsButton.accessibilityIdentifier = "advance-settings-button"
        advancedSettingsButton.accessibilityLabel = LocalizationConstants.Buttons.advancedSetting
        
        needHelpButton.accessibilityIdentifier = "need-help-button"
        needHelpButton.accessibilityLabel = LocalizationConstants.Buttons.needHelpAlfresco

        copyrightLabel.accessibilityIdentifier = "copyright-label"
        copyrightLabel.accessibilityLabel = LocalizationConstants.Accessibility.copyright
        copyrightLabel.accessibilityValue = copyrightLabel.text
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let bigButtonScheme = coordinatorServices?.themingService?.containerScheming(for: .loginBigButton),
              let smallButtonSceheme = coordinatorServices?.themingService?.containerScheming(for: .loginSmallButton),
              let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }

        connectButton.applyContainedTheme(withScheme: bigButtonScheme)
        connectButton.setBackgroundColor(currentTheme.onSurface5Color,
                                         for: .disabled)
        connectButton.isUppercaseTitle = false
        connectButton.setShadowColor(.clear, for: .normal)

        advancedSettingsButton.applyTextTheme(withScheme: smallButtonSceheme)
        advancedSettingsButton.isUppercaseTitle = false

        needHelpButton.applyTextTheme(withScheme: smallButtonSceheme)
        needHelpButton.isUppercaseTitle = false

        connectTextFieldAddMaterialComponents()

        productLabel.applyeStyleHeadline6OnSurface(theme: currentTheme)
        copyrightLabel.applyStyleCaptionOnSurface60(theme: currentTheme)
        copyrightLabel.textAlignment = .center
        productLabel.textAlignment = .center

        view.backgroundColor = currentTheme.surfaceColor

        let image = UIImage(color: currentTheme.surfaceColor,
                            size: navigationController?.navigationBar.bounds.size)
        navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = currentTheme.surfaceColor
        navigationController?.navigationBar.tintColor = currentTheme.onSurface60Color
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = currentTheme.surfaceColor
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: currentTheme.headline6TextStyle.font,
             NSAttributedString.Key.foregroundColor: currentTheme.onSurfaceColor]
    }

    func connectTextFieldAddMaterialComponents() {
        guard let themingService = coordinatorServices?.themingService else {
            return
        }
        connectTextField.trailingViewMode = .unlessEditing
        if errorShowInProgress {
            connectTextField.applyErrorTheme(withScheme: themingService.containerScheming(for: .loginTextField))
            connectTextField.trailingView = UIImageView(image: UIImage(named: "ic-error-textfield"))
        } else {
            connectTextField.applyTheme(withScheme: themingService.containerScheming(for: .loginTextField))
            connectTextField.leadingAssistiveLabel.text = ""
            connectTextField.trailingView = UIImageView(image: UIImage(named: "ic-connect-to-qr-code"))
            connectTextField.trailingView?.tintColor = themingService.activeTheme?.onSurface60Color
        }
    }

    func navigationBar(hide: Bool) {
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        if hide {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.view.backgroundColor = .clear
        } else {
            let image = UIImage(color: currentTheme.surfaceColor,
                                size: navigationController?.navigationBar.bounds.size)
            navigationController?.navigationBar.setBackgroundImage(image, for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
        }
    }

    func showError(message: String) {
        Snackbar.dimissAll()
        Snackbar.display(with: message,
                         type: .error,
                         automaticallyDismisses: false) { [weak self] () in
            guard let sSelf = self else { return }
            sSelf.errorShowInProgress = false
            sSelf.connectTextFieldAddMaterialComponents()
        }
    }
}

// MARK: - UITextField Delegate

extension ConnectViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        keyboardHandling?.adaptFrame(in: view, subview: textField)
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        enableConnectButton = (textField.updatedText(for: range,
                                                     replacementString: string) != "")
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        connectButtonTapped(connectButton)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        enableConnectButton = !textField.isEmpty()
    }
}

// MARK: - ConnectViewModel Delegate

extension ConnectViewController: ConnectViewModelDelegate {

    func authServiceAvailable(for authType: AvailableAuthType) {
        activityIndicator?.state = .isIdle
        splashScreenDelegate?.backPadButtonNeedsTo(hide: false)
        errorShowInProgress = false
        connectTextFieldAddMaterialComponents()
        Snackbar.dimissAll()
        switch authType {
        case .aimsAuth:
            connectScreenCoordinatorDelegate?.showAimsScreen()
        case .basicAuth:
            connectScreenCoordinatorDelegate?.showBasicAuthScreen()
        }
    }

    func authServiceUnavailable(with error: APIError) {
        activityIndicator?.state = .isIdle
        errorShowInProgress = true
        connectTextFieldAddMaterialComponents()
        showError(message: error.mapToMessage())
    }

    func authServiceByPass() {
        activityIndicator?.state = .isIdle
    }
}

// MARK: - Aims ViewModel Delegate

extension ConnectViewController: AimsViewModelDelegate {
    func logInFailed(with error: APIError) {
        AnalyticsManager.shared.apiTracker(name: Event.API.apiLogin.rawValue, fileSize: 0, success: false)
        splashScreenDelegate?.backPadButtonNeedsTo(hide: true)
        if error.responseCode != ErrorCodes.AimsWebview.cancel {
            activityIndicator?.state = .isIdle
            errorShowInProgress = true
            connectTextFieldAddMaterialComponents()
            showError(message: error.mapToMessage())
        } else {
            activityIndicator?.state = .isIdle
            errorShowInProgress = false
            connectTextFieldAddMaterialComponents()
            Snackbar.dimissAll()
        }
    }

    func logInSuccessful() {
        activityIndicator?.state = .isIdle
        splashScreenDelegate?.backPadButtonNeedsTo(hide: true)
        errorShowInProgress = false
        connectTextFieldAddMaterialComponents()
        Snackbar.dimissAll()
        connectScreenCoordinatorDelegate?.showApplicationTabBar()
        AnalyticsManager.shared.apiTracker(name: Event.API.apiLogin.rawValue, fileSize: 0, success: true)
    }
}

// MARK: - Storyboard Instantiable

extension ConnectViewController: StoryboardInstantiable { }
