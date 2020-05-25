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

class BasicAuthViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var showPasswordButton = UIButton()

    @IBOutlet weak var signInButton: UIButton!

    var model = BasicAuthViewModel()
    var keyboardHandling = KeyboardHandling()
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
        updateLayout()
        enableSignInButton = false
    }

    // MARK: - IBActions

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            return
        }
        model.authenticate(username: username, password: password)
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @objc func showPasswordButtonTapped(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry = showPasswordButton.isSelected
        showPasswordButton.isSelected = !showPasswordButton.isSelected
    }

    // MARK: - Helpers

    func updateLayout() {
        usernameTextField.rightViewMode = .unlessEditing
        usernameTextField.rightView = UIImageView(image: UIImage(named: "username-icon"))
        usernameTextField.rightView?.tintColor = #colorLiteral(red: 0.7254338861, green: 0.7255221009, blue: 0.7254036665, alpha: 1)

        showPasswordButton.setImage(UIImage(named: "hide-password-icon"), for: .normal)
        showPasswordButton.setImage(UIImage(named: "show-password-icon"), for: .selected)
        showPasswordButton.addTarget(self, action: #selector(showPasswordButtonTapped(_:)), for: .touchUpInside)

        passwordTextField.rightViewMode = .always
        passwordTextField.rightView = showPasswordButton
        passwordTextField.rightView?.tintColor = #colorLiteral(red: 0.7254338861, green: 0.7255221009, blue: 0.7254036665, alpha: 1)
    }

    func addLocalization() {
        self.title = ""
        infoLabel.text = String(format: LocalizationConstants.Labels.infoConnectTo, model.authParameters.hostname)
        usernameTextField.placeholder = LocalizationConstants.TextFieldPlaceholders.username
        passwordTextField.placeholder = LocalizationConstants.TextFieldPlaceholders.password
        signInButton.setTitle(LocalizationConstants.Buttons.signin, for: .normal)
        signInButton.setTitle(LocalizationConstants.Buttons.signin, for: .disabled)
        copyrightLabel.text = String(format: LocalizationConstants.copyright, Calendar.current.component(.year, from: Date()))
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

extension BasicAuthViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.rightView?.tintColor = #colorLiteral(red: 0.07236295193, green: 0.6188754439, blue: 0.2596520483, alpha: 1)

        let textFieldRect = view.convert(textField.frame, to: UIApplication.shared.windows[0])
        let heightTextFieldOpened = textFieldRect.size.height
        keyboardHandling.add(positionObjectInSuperview: textFieldRect.origin.y + heightTextFieldOpened,
                             in: view)
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
            signInButtonTapped(signInButton)
        default: break
        }
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.rightView?.tintColor = #colorLiteral(red: 0.7254338861, green: 0.7255221009, blue: 0.7254036665, alpha: 1)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        enableSignInButton = (usernameTextField.text != "" && passwordTextField.text != "")
    }
}
