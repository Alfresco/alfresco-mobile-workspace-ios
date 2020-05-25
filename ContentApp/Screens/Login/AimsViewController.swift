//
//  AimsViewController.swift
//  ContentApp
//
//  Created by Florin Baincescu on 25/05/2020.
//  Copyright © 2020 Florin Baincescu. All rights reserved.
//

import UIKit

class AimsViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var allowLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!

    @IBOutlet weak var repositoryTextFields: UITextField!
    @IBOutlet weak var signInButton: UIButton!

    var authParameters = AuthSettingsParameters()
    var keyboardHandling = KeyboardHandling()

    override func viewDidLoad() {
        super.viewDidLoad()
        addLocalization()
        shouldEnableSignInButton()
    }

    // MARK: - IBActions

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        guard let repositoryURL = repositoryTextFields.text else {
            return
        }
        print(repositoryURL)
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    // MARK: - Helpers

    func addLocalization() {
        self.title = ""
        infoLabel.text = String(format: LocalizationConstants.Labels.infoConnectTo, authParameters.hostname)
        allowLabel.text = LocalizationConstants.Labels.allowSSO
        copyrightLabel.text = String(format: LocalizationConstants.copyright, Calendar.current.component(.year, from: Date()))
        repositoryTextFields.placeholder = LocalizationConstants.TextFieldPlaceholders.repository
        signInButton.setTitle(LocalizationConstants.Buttons.signInWithSSO, for: .normal)
        signInButton.setTitle(LocalizationConstants.Buttons.signInWithSSO, for: .disabled)
    }

    func shouldEnableSignInButton() {
        signInButton.isEnabled = (repositoryTextFields.text != "")
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

extension AimsViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
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
        textField.resignFirstResponder()
        if signInButton.isEnabled {
            signInButtonTapped(signInButton)
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        shouldEnableSignInButton()
    }
}
