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
    var openKeyboard: Bool = true
    var errorShowInProgress: Bool = false
    var activityIndicator: ActivityIndicatorView?

    var enableConnectButton: Bool = false {
        didSet {
            connectButton.isEnabled = enableConnectButton
        }
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = UIDevice.current.userInterfaceIdiom == .pad
        viewModel?.delegate = self

        addLocalization()
        enableConnectButton = (connectTextField.text != "")
        activityIndicator = ActivityIndicatorView(currentTheme: themingService?.activeTheme)
        activityIndicator?.label(text: LocalizationConstants.Labels.conneting)
        if let activityIndicator = activityIndicator {
            kWindow.addSubview(activityIndicator)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar(hide: true)
        splashScreenDelegate?.backPadButtonNeedsTo(hide: false)
        activityIndicator?.applyTheme(themingService?.activeTheme)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if openKeyboard {
            openKeyboard = false
            DispatchQueue.main.asyncAfter(deadline: .now() + kAnimationSplashScreenLogo + kAnimationSplashScreenContainerViews,
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

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        activityIndicator?.applyTheme(themingService?.activeTheme)
    }

    // MARK: - IBActions

    @IBAction func connectButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let connectURL = connectTextField.text else {
            return
        }
        activityIndicator?.state = .isLoading
        viewModel?.availableAuthType(for: connectURL)
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
        needHelpButton.setTitle(LocalizationConstants.Buttons.needHelp, for: .normal)
        copyrightLabel.text = String(format: LocalizationConstants.copyright, Calendar.current.component(.year, from: Date()))

    }

    override func applyComponentsThemes() {
        guard let themingService = self.themingService, let currentTheme = self.themingService?.activeTheme else { return }

        connectButton.applyContainedTheme(withScheme: themingService.containerScheming(for: .loginButton))
        connectButton.setBackgroundColor(currentTheme.dividerColor, for: .disabled)
        connectButton.isUppercaseTitle = false

        advancedSettingsButton.applyTextTheme(withScheme: themingService.containerScheming(for: .loginAdvancedSettingsButton))
        advancedSettingsButton.isUppercaseTitle = false

        needHelpButton.applyTextTheme(withScheme: themingService.containerScheming(for: .loginNeedHelpButton))
        needHelpButton.isUppercaseTitle = false

        connectTextFieldAddMaterialComponents()

        productLabel.applyeStyleHeadline5OnSurface(theme: currentTheme)
        copyrightLabel.applyStyleCaptionOnSurface60(theme: currentTheme)
        copyrightLabel.textAlignment = .center

        view.backgroundColor = (UIDevice.current.userInterfaceIdiom == .pad) ? .clear : currentTheme.backgroundColor
        navigationController?.navigationBar.tintColor = currentTheme.onSurfaceColor.withAlphaComponent(0.6)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: currentTheme.headline6TextStyle.font,
                                                                   NSAttributedString.Key.foregroundColor: currentTheme.onSurfaceColor]
    }

    func connectTextFieldAddMaterialComponents() {
        guard let themingService = self.themingService else {
            return
        }
        if errorShowInProgress {
            connectTextField.applyErrorTheme(withScheme: themingService.containerScheming(for: .loginTextField))
        } else {
            connectTextField.applyTheme(withScheme: themingService.containerScheming(for: .loginTextField))
            connectTextField.leadingAssistiveLabel.text = ""
        }
    }

    func navigationBar(hide: Bool) {
        if hide {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.view.backgroundColor = .clear
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            self.navigationController?.navigationBar.shadowImage = nil
        }
    }

    func showError(message: String) {
        Snackbar.dimissAll()
        let snackbar = Snackbar(with: message, type: .error, automaticallyDismisses: false)
        snackbar.show(completion: { [weak self] () in
            guard let sSelf = self else { return }
            sSelf.errorShowInProgress = false
            sSelf.connectTextFieldAddMaterialComponents()
        })
    }
}

// MARK: - UITextField Delegate

extension ConnectViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        keyboardHandling?.adaptFrame(in: view, subview: textField)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        enableConnectButton = (textField.updatedText(for: range, replacementString: string) != "")
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        connectButtonTapped(connectButton)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        enableConnectButton = (textField.text != "")
    }
}

// MARK: - ConnectViewModel Delegate

extension ConnectViewController: ConnectViewModelDelegate {

    func authServiceAvailable(for authType: AvailableAuthType) {
        activityIndicator?.state = .isIdle
        splashScreenDelegate?.backPadButtonNeedsTo(hide: true)
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
}

// MARK: - Storyboard Instantiable

extension ConnectViewController: StoryboardInstantiable { }
