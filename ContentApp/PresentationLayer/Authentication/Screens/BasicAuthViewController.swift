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

class BasicAuthViewController: SystemThemableViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var hostnameLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!

    @IBOutlet weak var usernameTextField: MDCOutlinedTextField!
    @IBOutlet weak var passwordTextField: MDCOutlinedTextField!
    var showPasswordImageView = UIImageView(image: UIImage(named: "ic-password-hide"))

    @IBOutlet weak var signInButton: MDCButton!

    weak var splashScreenDelegate: SplashScreenDelegate?
    weak var basicAuthCoordinatorDelegate: BasicAuthScreenCoordinatorDelegate?

    var viewModel: BasicAuthViewModel?

    var keyboardHandling: KeyboardHandling? = KeyboardHandling()
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

        activityIndicator =
            ActivityIndicatorView(currentTheme: coordinatorServices?.themingService?.activeTheme)
        activityIndicator?.label(text: LocalizationConstants.Labels.signingIn)
        if let activityIndicator = activityIndicator {
            UIApplication.shared.windows[0].addSubview(activityIndicator)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator?.applyTheme(coordinatorServices?.themingService?.activeTheme)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Snackbar.dimissAll()
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        activityIndicator?.applyTheme(coordinatorServices?.themingService?.activeTheme)
    }

    // MARK: - IBActions

    @IBAction func signInButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        guard let username = usernameTextField.text,
              let password = passwordTextField.text else {
            return
        }

        Snackbar.dimissAll()
        activityIndicator?.state = .isLoading
        viewModel?.authenticate(username: username, password: password)
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @objc func showPasswordButtonTapped(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        let hidePasswordImage = UIImage(named: "ic-password-hide")
        let showPasswordImage = UIImage(named: "ic-password-show")
        showPasswordImageView.image =
            (passwordTextField.isSecureTextEntry) ? hidePasswordImage : showPasswordImage
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
        copyrightLabel.text = String(format: LocalizationConstants.copyright,
                                     Calendar.current.component(.year, from: Date()))
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let loginButtonScheme = coordinatorServices?.themingService?.containerScheming(for: .loginBigButton),
              let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }

        separator.backgroundColor = currentTheme.onSurface15Color

        signInButton.applyContainedTheme(withScheme: loginButtonScheme)
        signInButton.setBackgroundColor(currentTheme.onSurface15Color,
                                        for: .disabled)
        signInButton.isUppercaseTitle = false
        signInButton.setShadowColor(.clear, for: .normal)

        productLabel.applyeStyleHeadline6OnSurface(theme: currentTheme)
        infoLabel.applyStyleCaptionOnSurface60(theme: currentTheme)

        hostnameLabel.textColor = currentTheme.onSurfaceColor
        hostnameLabel.font = currentTheme.body1TextStyle.font

        copyrightLabel.applyStyleCaptionOnSurface60(theme: currentTheme)
        copyrightLabel.textAlignment = .center
        productLabel.textAlignment = .center

        applyThemingInTextField(errorTheme: false)

        view.backgroundColor = currentTheme.surfaceColor
    }

    func applyThemingInTextField(errorTheme: Bool) {
        guard let loginTextFieldScheme = coordinatorServices?.themingService?.containerScheming(for: .loginTextField),
              let currentTheme = coordinatorServices?.themingService?.activeTheme else {
            return
        }
        if errorTheme {
            usernameTextField.applyErrorTheme(withScheme: loginTextFieldScheme)
            passwordTextField.isSecureTextEntry = false
            passwordTextField.applyErrorTheme(withScheme: loginTextFieldScheme)
        } else {
            usernameTextField.applyTheme(withScheme: loginTextFieldScheme)
            passwordTextField.isSecureTextEntry = false
            passwordTextField.applyTheme(withScheme: loginTextFieldScheme)
        }

        usernameTextField.trailingViewMode = .unlessEditing
        usernameTextField.trailingView = UIImageView(image: UIImage(named: "ic-username"))
        usernameTextField.trailingView?.tintColor = currentTheme.onSurface60Color

        showPasswordImageView = UIImageView(image: UIImage(named: "ic-password-hide"))
        showPasswordImageView.contentMode = .scaleAspectFit
        passwordTextField.trailingViewMode = .always
        passwordTextField.trailingView = showPasswordImageView
        passwordTextField.trailingView?.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self,
                                                            action: #selector(showPasswordButtonTapped(_:)))
        passwordTextField.trailingView?.addGestureRecognizer(tapGestureRecognizer)
        passwordTextField.trailingView?.tintColor = currentTheme.onSurface60Color
        passwordTextField.isSecureTextEntry = true
    }
}

// MARK: - UITextField Delegate

extension BasicAuthViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.rightView?.tintColor = coordinatorServices?.themingService?.activeTheme?.primaryVariantT1Color
        keyboardHandling?.adaptFrame(in: view, subview: textField)
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        switch textField {
        case usernameTextField:
            enableSignInButton = (textField.updatedText(for: range,
                                                        replacementString: string) != "" &&
                                    passwordTextField.text != "")
        case passwordTextField:
            enableSignInButton = (textField.updatedText(for: range,
                                                        replacementString: string) != "" &&
                                    usernameTextField.text != "")
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
        textField.rightView?.tintColor = coordinatorServices?.themingService?.activeTheme?.onSurface15Color
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        enableSignInButton = (usernameTextField.text != "" && passwordTextField.text != "")
    }
}

extension BasicAuthViewController: BasicAuthViewModelDelegate {

    func logInFailed(with error: APIError) {
        activityIndicator?.state = .isIdle
        if error.responseCode == ErrorCodes.unauthorized {
            applyThemingInTextField(errorTheme: true)
        }
        Snackbar.display(with: error.mapToMessage(),
                         type: .error,
                         automaticallyDismisses: false) { [weak self] () in
            guard let sSelf = self else { return }
            sSelf.applyThemingInTextField(errorTheme: false)
        }
    }

    func logInSuccessful() {
        activityIndicator?.state = .isIdle
        basicAuthCoordinatorDelegate?.showApplicationTabBar()
    }

    func logInWarning(with message: String) {
        activityIndicator?.state = .isIdle
        Snackbar.display(with: message, type: .warning, automaticallyDismisses: false, finish: nil)
    }
}

// MARK: - Storyboard Instantiable

extension BasicAuthViewController: StoryboardInstantiable { }
