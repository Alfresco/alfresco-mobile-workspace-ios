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
    @IBOutlet weak var needHelpButton: MDCButton!

    var viewModel: BasicAuthViewModel?

    var keyboardHandling: KeyboardHandling? = KeyboardHandling()
    var themingService: MaterialDesignThemingService?

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
        addMaterialComponentsTheme()
        enableSignInButton = false
    }

    // MARK: - IBActions

    @IBAction func signInButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            return
        }
        viewModel?.authenticate(username: username, password: password)
    }

    @IBAction func needHelpButtonTapped(_ sender: Any) {
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
        infoLabel.text = LocalizationConstants.Labels.infoConnectTo
        hostnameLabel.text = viewModel?.hostname()
        usernameTextField.label.text = LocalizationConstants.TextFieldPlaceholders.username
        passwordTextField.label.text = LocalizationConstants.TextFieldPlaceholders.password
        signInButton.setTitle(LocalizationConstants.Buttons.signin, for: .normal)
        signInButton.setTitle(LocalizationConstants.Buttons.signin, for: .disabled)
        needHelpButton.setTitle(LocalizationConstants.Buttons.needHelp, for: .normal)
        copyrightLabel.text = String(format: LocalizationConstants.copyright, Calendar.current.component(.year, from: Date()))
    }

    func addMaterialComponentsTheme() {
        guard let themingService = self.themingService else {
            return
        }

        signInButton.applyContainedTheme(withScheme: themingService.containerScheming(for: .loginButton))
        needHelpButton.applyTextTheme(withScheme: themingService.containerScheming(for: .loginNeedHelpButton))

        usernameTextField.applyTheme(withScheme: themingService.containerScheming(for: .loginTextField))
        usernameTextField.trailingViewMode = .unlessEditing
        usernameTextField.trailingView = UIImageView(image: UIImage(named: "username-icon"))
        usernameTextField.trailingView?.tintColor = themingService.activeTheme?.loginTextFieldIconColor
        usernameTextField.setFilledBackgroundColor(.clear, for: .normal)
        usernameTextField.setFilledBackgroundColor(.clear, for: .editing)

        passwordTextField.applyTheme(withScheme: themingService.containerScheming(for: .loginTextField))
        passwordTextField.trailingViewMode = .always
        passwordTextField.trailingView = showPasswordImageView
        passwordTextField.trailingView?.isUserInteractionEnabled = true
        passwordTextField.trailingView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(showPasswordButtonTapped(_:))))
        passwordTextField.trailingView?.tintColor = themingService.activeTheme?.loginTextFieldIconColor
        passwordTextField.setFilledBackgroundColor(.clear, for: .normal)
        passwordTextField.setFilledBackgroundColor(.clear, for: .editing)
        passwordTextField.isSecureTextEntry = true

        productLabel.textColor = themingService.activeTheme?.productLabelColor
        productLabel.font = themingService.activeTheme?.productLabelFont

        infoLabel.textColor = themingService.activeTheme?.loginInfoLabelColor
        infoLabel.font = themingService.activeTheme?.loginInfoLabelFont

        hostnameLabel.textColor = themingService.activeTheme?.loginInfoLabelColor
        hostnameLabel.font = themingService.activeTheme?.loginInfoHostnameLabelFont

        copyrightLabel.textColor = themingService.activeTheme?.loginCopyrightLabelColor
        copyrightLabel.font = themingService.activeTheme?.loginCopyrightLabelFont
    }

    func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

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
   func logInFailed(with error: Error) {
        showAlert(message: error.localizedDescription)
    }

    func logInSuccessful() {
        showAlert(message: "Login with AIMS with success!")
    }
}

extension BasicAuthViewController: StoryboardInstantiable { }
