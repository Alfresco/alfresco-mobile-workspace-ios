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

class AdvancedSettingsViewController: UIViewController {

    @IBOutlet weak var backPadButton: UIButton!
    @IBOutlet weak var titlePadLabel: UILabel!
    @IBOutlet weak var savePadButton: MDCButton!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var transportProtocolLabel: UILabel!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var authenticationLabel: UILabel!

    @IBOutlet weak var httpsLabel: UILabel!
    @IBOutlet weak var httpsSwitch: UISwitch!

    @IBOutlet weak var portTextField: MDCFilledTextField!
    @IBOutlet weak var serviceDocumentsTextField: MDCFilledTextField!
    @IBOutlet weak var realmTextField: MDCFilledTextField!
    @IBOutlet weak var clientIDTextField: MDCFilledTextField!

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var needHelpButton: MDCButton!
    @IBOutlet weak var resetButton: MDCButton!
    @IBOutlet weak var copyrightLabel: UILabel!

    var model = AdvancedSettingsViewModel()
    var keyboardHandling = KeyboardHandling()
    var enableSaveButton: Bool = false {
        didSet {
            saveButton.isEnabled = enableSaveButton
            savePadButton.isEnabled = enableSaveButton
        }
    }
    var theme = MaterialDesignThemingService()

    override func viewDidLoad() {
        super.viewDidLoad()
        theme.activeTheme = DefaultTheme()
        addLocalization()
        addMaterialComponentsTheme()
        enableSaveButton = false
        updateFields()
    }

    // MARK: - IBAction

    @IBAction func backPadButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func savePadButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        saveFields()
        enableSaveButton = false
    }

    @IBAction func httpsSwitchTapped(_ sender: UISwitch) {
        self.view.endEditing(true)
        httpsLabel.textColor = (httpsSwitch.isOn) ? theme.activeTheme?.loginFieldLabelColor : theme.activeTheme?.loginFieldDisableLabelColor
        portTextField.text = (httpsSwitch.isOn) ? kDefaultLoginSecuredPort : kDefaultLoginUnsecuredPort
        enableSaveButton = true
    }

    @IBAction func resetButtonTapped(_ sender: UIButton) {
        model.resetAuthParameters()
        updateFields()
        enableSaveButton = true
    }

    @IBAction func needHelpButtonTapped(_ sender: UIButton) {
    }

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        saveFields()
        enableSaveButton = false
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    // MARK: - Helpers

    func addLocalization() {
        self.titlePadLabel.text = LocalizationConstants.ScreenTitles.advancedSettings
        self.savePadButton.setTitle(LocalizationConstants.Buttons.save, for: .normal)
        self.savePadButton.setTitle(LocalizationConstants.Buttons.save, for: .disabled)

        self.title = LocalizationConstants.ScreenTitles.advancedSettings

        transportProtocolLabel.text = LocalizationConstants.Labels.transportProtocol
        settingsLabel.text = LocalizationConstants.Labels.alfrescoContentServicesSettings
        authenticationLabel.text = LocalizationConstants.Labels.authentication
        httpsLabel.text = LocalizationConstants.Labels.https
        copyrightLabel.text = String(format: LocalizationConstants.copyright, Calendar.current.component(.year, from: Date()))

        portTextField.label.text = LocalizationConstants.TextFieldPlaceholders.port
        serviceDocumentsTextField.label.text = LocalizationConstants.TextFieldPlaceholders.serviceDocuments
        realmTextField.label.text = LocalizationConstants.TextFieldPlaceholders.realm
        clientIDTextField.label.text = LocalizationConstants.TextFieldPlaceholders.clientID

        saveButton.title = LocalizationConstants.Buttons.save.uppercased()
        needHelpButton.setTitle(LocalizationConstants.Buttons.needHelp, for: .normal)
        resetButton.setTitle(LocalizationConstants.Buttons.resetToDefault, for: .normal)
    }

    func addMaterialComponentsTheme() {
        portTextField.applyTheme(withScheme: theme.containerScheming(for: .loginTextField))
        portTextField.setFilledBackgroundColor(.clear, for: .normal)
        portTextField.setFilledBackgroundColor(.clear, for: .editing)

        serviceDocumentsTextField.applyTheme(withScheme: theme.containerScheming(for: .loginTextField))
        serviceDocumentsTextField.setFilledBackgroundColor(.clear, for: .normal)
        serviceDocumentsTextField.setFilledBackgroundColor(.clear, for: .editing)

        clientIDTextField.applyTheme(withScheme: theme.containerScheming(for: .loginTextField))
        clientIDTextField.setFilledBackgroundColor(.clear, for: .normal)
        clientIDTextField.setFilledBackgroundColor(.clear, for: .editing)

        realmTextField.applyTheme(withScheme: theme.containerScheming(for: .loginTextField))
        realmTextField.setFilledBackgroundColor(.clear, for: .normal)
        realmTextField.setFilledBackgroundColor(.clear, for: .editing)

        transportProtocolLabel.textColor = theme.activeTheme?.loginFieldLabelColor
        transportProtocolLabel.font = theme.activeTheme?.loginFieldLabelFont

        httpsLabel.textColor = (model.authParameters.https) ? theme.activeTheme?.loginFieldLabelColor : theme.activeTheme?.loginFieldDisableLabelColor
        httpsLabel.font = theme.activeTheme?.loginHTTPSLabelFont

        settingsLabel.textColor = theme.activeTheme?.loginFieldLabelColor
        settingsLabel.font = theme.activeTheme?.loginFieldLabelFont

        authenticationLabel.textColor = theme.activeTheme?.loginFieldLabelColor
        authenticationLabel.font = theme.activeTheme?.loginFieldLabelFont

        titlePadLabel.textColor = theme.activeTheme?.applicationTitleColor
        titlePadLabel.font = theme.activeTheme?.loginTitleLabelFont

        copyrightLabel.textColor = theme.activeTheme?.loginCopyrightLabelColor
        copyrightLabel.font = theme.activeTheme?.loginCopyrightLabelFont

        resetButton.applyTextTheme(withScheme: theme.containerScheming(for: .loginResetButton))
        savePadButton.applyTextTheme(withScheme: theme.containerScheming(for: .loginSavePadButton))
        needHelpButton.applyTextTheme(withScheme: theme.containerScheming(for: .loginNeedHelpButton))
        saveButton.tintColor = theme.activeTheme?.loginButtonColor
    }

    func updateFields() {
        httpsSwitch.isOn = model.authParameters.https
        portTextField.text = model.authParameters.port
        serviceDocumentsTextField.text = model.authParameters.serviceDocument
        realmTextField.text = model.authParameters.realm
        clientIDTextField.text = model.authParameters.clientID
    }

    func saveFields() {
        model.saveFields(https: httpsSwitch.isOn,
                         port: portTextField.text,
                         serviceDocuments: serviceDocumentsTextField.text,
                         realm: realmTextField.text,
                         clientID: clientIDTextField.text)
    }
}

extension AdvancedSettingsViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let textFieldRect = scrollView.convert(textField.frame, to: UIApplication.shared.windows[0])
        let heightTextFieldOpened = textFieldRect.size.height
        keyboardHandling.add(positionObjectInSuperview: textFieldRect.origin.y + heightTextFieldOpened,
                             in: view)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        enableSaveButton = true
    }

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
}
