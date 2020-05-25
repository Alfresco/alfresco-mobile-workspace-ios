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

class AimsViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var allowLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!

    @IBOutlet weak var repositoryTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!

    var model = AimsViewModel()
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
        enableSignInButton = (repositoryTextField.text != "")
    }

    // MARK: - IBActions

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        guard let repositoryURL = repositoryTextField.text else {
            return
        }
        model.authenticate(repository: repositoryURL, in: self)
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    // MARK: - Helpers

    func addLocalization() {
        self.title = ""
        infoLabel.text = String(format: LocalizationConstants.Labels.infoConnectTo, model.authParameters.hostname)
        allowLabel.text = LocalizationConstants.Labels.allowSSO
        repositoryTextField.placeholder = LocalizationConstants.TextFieldPlaceholders.repository
        signInButton.setTitle(LocalizationConstants.Buttons.signInWithSSO, for: .normal)
        signInButton.setTitle(LocalizationConstants.Buttons.signInWithSSO, for: .disabled)
        copyrightLabel.text = String(format: LocalizationConstants.copyright, Calendar.current.component(.year, from: Date()))
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
        enableSignInButton = (textField.updatedText(for: range, replacementString: string) != "")
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        signInButtonTapped(signInButton)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        enableSignInButton = (textField.text != "")
    }
}
