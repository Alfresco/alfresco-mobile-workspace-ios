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

    var model: BasicAuthViewModel?

    var keyboardHandling: KeyboardHandling? = KeyboardHandling()
    var theme: MaterialDesignThemingService?

    var enableSignInButton: Bool = false {
        didSet {
            signInButton.isEnabled = enableSignInButton
            signInButton.tintColor = signInButton.currentTitleColor
        }
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

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
        model?.authenticate(username: username, password: password)
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
        hostnameLabel.text = model?.hostname()
        usernameTextField.label.text = LocalizationConstants.TextFieldPlaceholders.username
        passwordTextField.label.text = LocalizationConstants.TextFieldPlaceholders.password
        signInButton.setTitle(LocalizationConstants.Buttons.signin, for: .normal)
        signInButton.setTitle(LocalizationConstants.Buttons.signin, for: .disabled)
        needHelpButton.setTitle(LocalizationConstants.Buttons.needHelp, for: .normal)
        copyrightLabel.text = String(format: LocalizationConstants.copyright, Calendar.current.component(.year, from: Date()))
    }

    func addMaterialComponentsTheme() {
        guard let theme = self.theme else {
            return
        }

        signInButton.applyContainedTheme(withScheme: theme.containerScheming(for: .loginButton))
        needHelpButton.applyTextTheme(withScheme: theme.containerScheming(for: .loginNeedHelpButton))

        usernameTextField.applyTheme(withScheme: theme.containerScheming(for: .loginTextField))
        usernameTextField.trailingViewMode = .unlessEditing
        usernameTextField.trailingView = UIImageView(image: UIImage(named: "username-icon"))
        usernameTextField.trailingView?.tintColor = theme.activeTheme?.loginTextFieldIconColor
        usernameTextField.setFilledBackgroundColor(.clear, for: .normal)
        usernameTextField.setFilledBackgroundColor(.clear, for: .editing)

        passwordTextField.applyTheme(withScheme: theme.containerScheming(for: .loginTextField))
        passwordTextField.trailingViewMode = .always
        passwordTextField.trailingView = showPasswordImageView
        passwordTextField.trailingView?.isUserInteractionEnabled = true
        passwordTextField.trailingView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(showPasswordButtonTapped(_:))))
        passwordTextField.trailingView?.tintColor = theme.activeTheme?.loginTextFieldIconColor
        passwordTextField.setFilledBackgroundColor(.clear, for: .normal)
        passwordTextField.setFilledBackgroundColor(.clear, for: .editing)
        passwordTextField.isSecureTextEntry = true

        productLabel.textColor = theme.activeTheme?.productLabelColor
        productLabel.font = theme.activeTheme?.productLabelFont

        infoLabel.textColor = theme.activeTheme?.loginInfoLabelColor
        infoLabel.font = theme.activeTheme?.loginInfoLabelFont

        hostnameLabel.textColor = theme.activeTheme?.loginInfoLabelColor
        hostnameLabel.font = theme.activeTheme?.loginInfoHostnameLabelFont

        copyrightLabel.textColor = theme.activeTheme?.loginCopyrightLabelColor
        copyrightLabel.font = theme.activeTheme?.loginCopyrightLabelFont
    }
}

extension BasicAuthViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.rightView?.tintColor = theme?.activeTheme?.loginTextFieldPrimaryColor
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
        textField.rightView?.tintColor = theme?.activeTheme?.loginTextFieldIconColor
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        enableSignInButton = (usernameTextField.text != "" && passwordTextField.text != "")
    }
}

extension BasicAuthViewController: StoryboardInstantiable { }
