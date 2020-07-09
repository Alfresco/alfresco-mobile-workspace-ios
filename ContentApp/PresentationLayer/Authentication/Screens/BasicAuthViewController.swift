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

class BasicAuthViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var hostnameLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!

    @IBOutlet weak var usernameTextField: MDCFilledTextField!
    @IBOutlet weak var passwordTextField: MDCFilledTextField!
    var showPasswordImageView = UIImageView(image: UIImage(named: "hide-password-icon"))

    @IBOutlet weak var signInButton: MDCButton!

    weak var splashScreenDelegate: SplashScreenDelegate?
    weak var basicAuthCoordinatorDelegate: BasicAuthScreenCoordinatorDelegate?

    var viewModel: BasicAuthViewModel?

    var keyboardHandling: KeyboardHandling? = KeyboardHandling()
    var themingService: MaterialDesignThemingService?
    var activityIndicator: ActivityIndicatorView?

    var enableSignInButton: Bool = false {
        didSet {
            signInButton.isEnabled = enableSignInButton
            signInButton.tintColor = signInButton.currentTitleColor
        }
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel?.delegate = self

        addLocalization()
        enableSignInButton = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addMaterialComponentsTheme()
        activityIndicator = ActivityIndicatorView(currentTheme: themingService?.activeTheme,
                                                  configuration: ActivityIndicatorConfiguration(title: LocalizationConstants.Labels.signingIn,
                                                                                                radius: 40,
                                                                                                strokeWidth: 7,
                                                                                                cycleColors: [themingService?.activeTheme?.activityIndicatorViewColor ?? .black]))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Snackbar.dimissAll()
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

    @IBAction func signInButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            return
        }
        activityIndicator?.state = .isLoading
        viewModel?.authenticate(username: username, password: password)
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @objc func showPasswordButtonTapped(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        showPasswordImageView.image = (passwordTextField.isSecureTextEntry) ? UIImage(named: "hide-password-icon") : UIImage(named: "show-password-icon")
    }

    // MARK: - Helpers

    func addLocalization() {
        self.title = ""
        productLabel.text = LocalizationConstants.productName
        infoLabel.text = LocalizationConstants.Labels.infoBasicAuthConnectTo
        hostnameLabel.text = viewModel?.hostname()
        usernameTextField.label.text = LocalizationConstants.TextFieldPlaceholders.username
        passwordTextField.label.text = LocalizationConstants.TextFieldPlaceholders.password
        signInButton.setTitle(LocalizationConstants.Buttons.signin, for: .normal)
        signInButton.setTitle(LocalizationConstants.Buttons.signin, for: .disabled)
        copyrightLabel.text = String(format: LocalizationConstants.copyright, Calendar.current.component(.year, from: Date()))
    }

    func addMaterialComponentsTheme() {
        guard let themingService = self.themingService, let currentTheme = self.themingService?.activeTheme else { return }

        signInButton.applyContainedTheme(withScheme: themingService.containerScheming(for: .loginButton))
        signInButton.setBackgroundColor(currentTheme.loginButtonDisableColor, for: .disabled)

        productLabel.textColor = currentTheme.productLabelColor
        productLabel.font = currentTheme.productLabelFont

        infoLabel.textColor = currentTheme.loginInfoLabelColor
        infoLabel.font = currentTheme.loginInfoLabelFont

        hostnameLabel.textColor = currentTheme.loginInfoLabelColor
        hostnameLabel.font = currentTheme.loginInfoHostnameLabelFont

        copyrightLabel.textColor = currentTheme.loginCopyrightLabelColor
        copyrightLabel.font = currentTheme.loginCopyrightLabelFont

        applyThemingInTextField(errorTheme: false)
    }

    func applyThemingInTextField(errorTheme: Bool) {
        guard let themingService = self.themingService, let currentTheme = self.themingService?.activeTheme else { return }
        if errorTheme {
            usernameTextField.applyErrorTheme(withScheme: themingService.containerScheming(for: .loginTextField))
            passwordTextField.applyErrorTheme(withScheme: themingService.containerScheming(for: .loginTextField))
        } else {
            usernameTextField.applyTheme(withScheme: themingService.containerScheming(for: .loginTextField))
            passwordTextField.applyTheme(withScheme: themingService.containerScheming(for: .loginTextField))
        }

        usernameTextField.trailingViewMode = .unlessEditing
        usernameTextField.trailingView = UIImageView(image: UIImage(named: "username-icon"))
        usernameTextField.trailingView?.tintColor = currentTheme.loginTextFieldIconColor
        usernameTextField.setFilledBackgroundColor(.clear, for: .normal)
        usernameTextField.setFilledBackgroundColor(.clear, for: .editing)

        showPasswordImageView = UIImageView(image: UIImage(named: "hide-password-icon"))
        showPasswordImageView.contentMode = .scaleAspectFit
        passwordTextField.trailingViewMode = .always
        passwordTextField.trailingView = showPasswordImageView
        passwordTextField.trailingView?.isUserInteractionEnabled = true
        passwordTextField.trailingView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(showPasswordButtonTapped(_:))))
        passwordTextField.trailingView?.tintColor = currentTheme.loginTextFieldIconColor
        passwordTextField.setFilledBackgroundColor(.clear, for: .normal)
        passwordTextField.setFilledBackgroundColor(.clear, for: .editing)
        passwordTextField.isSecureTextEntry = true
    }
}

// MARK: - UITextField Delegate

extension BasicAuthViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.rightView?.tintColor = themingService?.activeTheme?.loginTextFieldPrimaryColor
        keyboardHandling?.adaptFrame(in: view, subview: textField)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case usernameTextField:
            enableSignInButton = (textField.updatedText(for: range, replacementString: string) != "" && passwordTextField.text != "")
        case passwordTextField:
            enableSignInButton = (textField.updatedText(for: range, replacementString: string) != "" && usernameTextField.text != "")
        default: break
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
            signInButtonTapped(signInButton as Any)
        default: break
        }
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.rightView?.tintColor = themingService?.activeTheme?.loginTextFieldIconColor
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        enableSignInButton = (usernameTextField.text != "" && passwordTextField.text != "")
    }
}

extension BasicAuthViewController: BasicAuthViewModelDelegate {

    func logInFailed(with error: APIError) {
        activityIndicator?.state = .isIdle
//        if error.responseCode == 401 {
//            applyThemingInTextField(errorTheme: true)
//        }
//        Snackbar.dimissAll()
//        let snackbar = Snackbar(with: error.mapToMessage(), type: .error, automaticallyDismisses: false)
//        if let theme = themingService?.activeTheme {
//            snackbar.applyTheme(theme: theme)
//        }
//        snackbar.show(completion: { [weak self] () in
//            guard let sSelf = self else { return }
//            sSelf.applyThemingInTextField(errorTheme: false)
//        })
    }

    func logInSuccessful() {
        activityIndicator?.state = .isIdle
        basicAuthCoordinatorDelegate?.showApplicationTabBar()
    }

    func logInWarning(with message: String) {
        activityIndicator?.state = .isIdle
        Snackbar.dimissAll()
        let snackbar = Snackbar(with: message, type: .warning, automaticallyDismisses: false)
        if let theme = themingService?.activeTheme {
            snackbar.applyTheme(theme: theme)
        }
        snackbar.show(completion: nil)
    }
}

// MARK: - Storyboard Instantiable

extension BasicAuthViewController: StoryboardInstantiable { }
