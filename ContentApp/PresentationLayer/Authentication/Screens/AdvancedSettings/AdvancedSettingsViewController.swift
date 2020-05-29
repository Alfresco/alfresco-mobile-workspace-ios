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

    weak var advSettingsScreenCoordinatorDelegate: AdvancedSettingsScreenCoordinatorDelegate?
    var viewModel = AdvancedSettingsViewModel()

    var keyboardHandling: KeyboardHandling? = KeyboardHandling()
    var themingService: MaterialDesignThemingService?

    var enableSaveButton: Bool = false {
        didSet {
            saveButton.isEnabled = enableSaveButton
            savePadButton.isEnabled = enableSaveButton
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addLocalization()
        addMaterialComponentsTheme()
        enableSaveButton = false
        updateFields()
    }

    // MARK: - IBAction

    @IBAction func backPadButtonTapped(_ sender: UIButton) {
        advSettingsScreenCoordinatorDelegate?.dismiss()
    }

    @IBAction func savePadButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        saveFields()
        enableSaveButton = false
    }

    @IBAction func httpsSwitchTapped(_ sender: UISwitch) {
        self.view.endEditing(true)
        httpsLabel.textColor = (httpsSwitch.isOn) ? themingService?.activeTheme?.loginFieldLabelColor : themingService?.activeTheme?.loginFieldDisableLabelColor
        portTextField.text = (httpsSwitch.isOn) ? kDefaultLoginSecuredPort : kDefaultLoginUnsecuredPort
        enableSaveButton = true
    }

    @IBAction func resetButtonTapped(_ sender: UIButton) {
        viewModel.resetAuthParameters()
        updateFields()
        enableSaveButton = true
    }

    @IBAction func needHelpButtonTapped(_ sender: UIButton) {
        advSettingsScreenCoordinatorDelegate?.showNeedHelpSheet()
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
        guard let themingService = self.themingService else {
            return
        }

        portTextField.applyTheme(withScheme: themingService.containerScheming(for: .loginTextField))
        portTextField.setFilledBackgroundColor(.clear, for: .normal)
        portTextField.setFilledBackgroundColor(.clear, for: .editing)

        serviceDocumentsTextField.applyTheme(withScheme: themingService.containerScheming(for: .loginTextField))
        serviceDocumentsTextField.setFilledBackgroundColor(.clear, for: .normal)
        serviceDocumentsTextField.setFilledBackgroundColor(.clear, for: .editing)

        clientIDTextField.applyTheme(withScheme: themingService.containerScheming(for: .loginTextField))
        clientIDTextField.setFilledBackgroundColor(.clear, for: .normal)
        clientIDTextField.setFilledBackgroundColor(.clear, for: .editing)

        realmTextField.applyTheme(withScheme: themingService.containerScheming(for: .loginTextField))
        realmTextField.setFilledBackgroundColor(.clear, for: .normal)
        realmTextField.setFilledBackgroundColor(.clear, for: .editing)

        transportProtocolLabel.textColor = themingService.activeTheme?.loginFieldLabelColor
        transportProtocolLabel.font = themingService.activeTheme?.loginFieldLabelFont

        httpsLabel.textColor = (viewModel.authParameters.https) ? themingService.activeTheme?.loginFieldLabelColor : themingService.activeTheme?.loginFieldDisableLabelColor
        httpsLabel.font = themingService.activeTheme?.loginHTTPSLabelFont

        settingsLabel.textColor = themingService.activeTheme?.loginFieldLabelColor
        settingsLabel.font = themingService.activeTheme?.loginFieldLabelFont

        authenticationLabel.textColor = themingService.activeTheme?.loginFieldLabelColor
        authenticationLabel.font = themingService.activeTheme?.loginFieldLabelFont

        titlePadLabel.textColor = themingService.activeTheme?.applicationTitleColor
        titlePadLabel.font = themingService.activeTheme?.loginTitleLabelFont

        copyrightLabel.textColor = themingService.activeTheme?.loginCopyrightLabelColor
        copyrightLabel.font = themingService.activeTheme?.loginCopyrightLabelFont

        resetButton.applyTextTheme(withScheme: themingService.containerScheming(for: .loginResetButton))
        savePadButton.applyTextTheme(withScheme: themingService.containerScheming(for: .loginSavePadButton))
        needHelpButton.applyTextTheme(withScheme: themingService.containerScheming(for: .loginNeedHelpButton))
        saveButton.tintColor = themingService.activeTheme?.loginButtonColor
        backPadButton.tintColor = themingService.activeTheme?.loginButtonColor
    }

    func updateFields() {
        httpsSwitch.isOn = viewModel.authParameters.https
        portTextField.text = viewModel.authParameters.port
        serviceDocumentsTextField.text = viewModel.authParameters.serviceDocument
        realmTextField.text = viewModel.authParameters.realm
        clientIDTextField.text = viewModel.authParameters.clientID
    }

    func saveFields() {
        viewModel.saveFields(https: httpsSwitch.isOn,
                         port: portTextField.text,
                         serviceDocuments: serviceDocumentsTextField.text,
                         realm: realmTextField.text,
                         clientID: clientIDTextField.text)
        showAlert(message: "Settings saved!")
    }

    func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension AdvancedSettingsViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        keyboardHandling?.adaptFrame(in: scrollView, subview: textField)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        enableSaveButton = true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var nextTextField = textField
        switch textField {
        case portTextField:
            nextTextField = serviceDocumentsTextField
        case serviceDocumentsTextField:
            nextTextField = realmTextField
        case realmTextField:
            nextTextField = clientIDTextField
        default:
            textField.resignFirstResponder()
            return true
        }

        nextTextField.becomeFirstResponder()
        return true
    }
}

extension UIScrollView {

    func scrollToView(view: UIView, animated: Bool) {
        if let origin = view.superview {
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            self.scrollRectToVisible(CGRect(x: 0, y: childStartPoint.y, width: 1, height: self.frame.height), animated: animated)
        }
    }

}

extension AdvancedSettingsViewController: StoryboardInstantiable { }
