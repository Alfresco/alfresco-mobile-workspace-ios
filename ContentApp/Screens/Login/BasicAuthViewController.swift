//
//  BasicAuthViewController.swift
//  ContentApp
//
//  Created by Florin Baincescu on 25/05/2020.
//  Copyright © 2020 Florin Baincescu. All rights reserved.
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

    var authParameters = AuthSettingsParameters.parameters()
    var keyboardHandling = KeyboardHandling()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        addLocalization()
        updateLayout()
        shouldEnableSignInButton()
    }

    // MARK: - IBActions

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
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
        infoLabel.text = String(format: LocalizationConstants.Labels.infoConnectTo, authParameters.hostname)
        usernameTextField.placeholder = LocalizationConstants.TextFieldPlaceholders.username
        passwordTextField.placeholder = LocalizationConstants.TextFieldPlaceholders.password
        signInButton.setTitle(LocalizationConstants.Buttons.signin, for: .normal)
        signInButton.setTitle(LocalizationConstants.Buttons.signin, for: .disabled)
    }

    func shouldEnableSignInButton() {
        let enable = (usernameTextField.text != "" && passwordTextField.text != "")
        signInButton.isEnabled = enable
        signInButton.tintColor = signInButton.currentTitleColor
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
        shouldEnableSignInButton()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.rightView?.tintColor = #colorLiteral(red: 0.7254338861, green: 0.7255221009, blue: 0.7254036665, alpha: 1)
        shouldEnableSignInButton()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == passwordTextField && signInButton.isEnabled == true {
            signInButtonTapped(signInButton)
        }
    }
}
