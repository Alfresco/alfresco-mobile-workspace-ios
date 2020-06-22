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
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_FilledTextFieldsTheming

class ConnectViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var connectTextField: MDCFilledTextField!
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
    var themingService: MaterialDesignThemingService?
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addMaterialComponentsTheme()
        activityIndicator = ActivityIndicatorView(themingService: themingService)
        navigationBar(hide: true)
        self.splashScreenDelegate?.backPadButtonNeedsTo(hide: false)
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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        activityIndicator?.reload(from: size)
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        themingService?.activateUserSelectedTheme()
        addMaterialComponentsTheme()
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

    func addMaterialComponentsTheme() {
        guard let themingService = self.themingService else {
            return
        }
        connectButton.applyContainedTheme(withScheme: themingService.containerScheming(for: .loginButton))
        connectButton.setBackgroundColor(themingService.activeTheme?.loginButtonDisableColor, for: .disabled)
        advancedSettingsButton.applyTextTheme(withScheme: themingService.containerScheming(for: .loginAdvancedSettingsButton))
        needHelpButton.applyTextTheme(withScheme: themingService.containerScheming(for: .loginNeedHelpButton))

        connectTextFieldAddMaterialComponents()

        productLabel.textColor = themingService.activeTheme?.productLabelColor
        productLabel.font = themingService.activeTheme?.productLabelFont

        copyrightLabel.textColor = themingService.activeTheme?.loginCopyrightLabelColor
        copyrightLabel.font = themingService.activeTheme?.loginCopyrightLabelFont

        self.navigationController?.navigationBar.tintColor = themingService.activeTheme?.loginButtonColor
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
        connectTextField.setFilledBackgroundColor(.clear, for: .normal)
        connectTextField.setFilledBackgroundColor(.clear, for: .editing)
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
        if let theme = themingService?.activeTheme {
            snackbar.applyTheme(theme: theme)
        }
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
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.splashScreenDelegate?.backPadButtonNeedsTo(hide: true)
            sSelf.errorShowInProgress = false
            sSelf.connectTextFieldAddMaterialComponents()
            Snackbar.dimissAll()
            switch authType {
            case .aimsAuth:
                sSelf.connectScreenCoordinatorDelegate?.showAimsScreen()
            case .basicAuth:
                sSelf.connectScreenCoordinatorDelegate?.showBasicAuthScreen()
            }
        }
    }

    func authServiceUnavailable(with error: APIError) {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.errorShowInProgress = true
            sSelf.connectTextFieldAddMaterialComponents()

            sSelf.showError(message: error.mapToMessage())
        }
        activityIndicator?.state = .isIdle
    }
}

// MARK: - Storyboard Instantiable

extension ConnectViewController: StoryboardInstantiable { }
