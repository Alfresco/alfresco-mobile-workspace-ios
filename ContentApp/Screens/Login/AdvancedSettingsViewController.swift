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

class AdvancedSettingsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!

    @IBOutlet weak var transportProtocolLabel: UILabel!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var authenticationLabel: UILabel!

    @IBOutlet weak var httpsLabel: UILabel!
    @IBOutlet weak var httpsSwitch: UISwitch!

    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var serviceDocumentsTextField: UITextField!
    @IBOutlet weak var realmTextField: UITextField!
    @IBOutlet weak var clientIDTextField: UITextField!

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var needHelpButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var copyrightLabel: UILabel!

    var authParameters = AuthSettingsParameters()
    var keyboardHandling = KeyboardHandling()

    override func viewDidLoad() {
        super.viewDidLoad()
        addLocalization()

        saveButton.isEnabled = false
        authParameters = AuthSettingsParameters.parameters()
        updateFields()
    }


    // MARK: - IBAction

    @IBAction func httpsSwitchTapped(_ sender: UISwitch) {
        saveButton.isEnabled = true
    }

    @IBAction func resetButtonTapped(_ sender: UIButton) {
        authParameters = AuthSettingsParameters()
        updateFields()
        saveButton.isEnabled = true
    }

    @IBAction func needHelpButtonTapped(_ sender: UIButton) {
    }

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        saveFields()
        saveButton.isEnabled = false
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    // MARK: - Helpers

    func addLocalization() {
        self.title = LocalizationConstants.ScreenTitles.advancedSettings

        transportProtocolLabel.text = LocalizationConstants.Labels.transportProtocol
        settingsLabel.text = LocalizationConstants.Labels.alfrescoContentServicesSettings
        authenticationLabel.text = LocalizationConstants.Labels.authentication
        httpsLabel.text = LocalizationConstants.Labels.https
        copyrightLabel.text = String(format: LocalizationConstants.copyright, Calendar.current.component(.year, from: Date()))

        portTextField.placeholder = LocalizationConstants.TextFieldPlaceholders.port
        serviceDocumentsTextField.placeholder = LocalizationConstants.TextFieldPlaceholders.serviceDocuments
        realmTextField.placeholder = LocalizationConstants.TextFieldPlaceholders.realm
        clientIDTextField.placeholder = LocalizationConstants.TextFieldPlaceholders.clientID

        saveButton.title = LocalizationConstants.Buttons.save
        needHelpButton.setTitle(LocalizationConstants.Buttons.needHelp, for: .normal)
        resetButton.setTitle(LocalizationConstants.Buttons.resetToDefault, for: .normal)
    }

    func updateFields() {
        httpsSwitch.isOn = authParameters.https
        portTextField.text = authParameters.port
        serviceDocumentsTextField.text = authParameters.serviceDocument
        realmTextField.text = authParameters.realm
        clientIDTextField.text = authParameters.clientID
    }

    func saveFields() {
        authParameters.https = httpsSwitch.isOn
        authParameters.port = portTextField.text ?? ""
        authParameters.serviceDocument = serviceDocumentsTextField.text ?? ""
        authParameters.realm = realmTextField.text ?? ""
        authParameters.clientID = clientIDTextField.text ?? ""
        authParameters.save()
    }
}

extension AdvancedSettingsViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case portTextField:
            serviceDocumentsTextField.becomeFirstResponder()
        case serviceDocumentsTextField:
            realmTextField.becomeFirstResponder()
        case realmTextField:
            clientIDTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let textFieldRect = scrollView.convert(textField.frame, to: UIApplication.shared.windows[0])
        let heightTextFieldOpened = textFieldRect.size.height 
        keyboardHandling.add(positionObjectInSuperview: textFieldRect.origin.y + heightTextFieldOpened,
                             in: view)
        return true
    }
}
