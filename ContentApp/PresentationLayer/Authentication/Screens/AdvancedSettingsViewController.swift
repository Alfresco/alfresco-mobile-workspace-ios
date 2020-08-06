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
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class AdvancedSettingsViewController: SystemThemableViewController {

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

    @IBOutlet weak var portTextField: MDCOutlinedTextField!
    @IBOutlet weak var serviceDocumentsTextField: MDCOutlinedTextField!
    @IBOutlet weak var realmTextField: MDCOutlinedTextField!
    @IBOutlet weak var clientIDTextField: MDCOutlinedTextField!

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var needHelpButton: MDCButton!
    @IBOutlet weak var resetButton: MDCButton!
    @IBOutlet weak var copyrightLabel: UILabel!

    weak var advSettingsScreenCoordinatorDelegate: AdvancedSettingsScreenCoordinatorDelegate?
    var viewModel = AdvancedSettingsViewModel()

    var keyboardHandling: KeyboardHandling? = KeyboardHandling()

    var enableSaveButton: Bool = false {
        didSet {
            saveButton.isEnabled = enableSaveButton
            savePadButton.isEnabled = enableSaveButton
        }
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addLocalization()
        enableSaveButton = false
        updateFields()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Snackbar.dimissAll()
    }

    // MARK: - IBAction

    @IBAction func backPadButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        advSettingsScreenCoordinatorDelegate?.dismiss()
    }

    @IBAction func savePadButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        saveFields()
        enableSaveButton = false
    }

    @IBAction func httpsSwitchTapped(_ sender: UISwitch) {
        self.view.endEditing(true)
        guard let currentTheme = self.themingService?.activeTheme else { return }
        if httpsSwitch.isOn {
            httpsLabel.applyStyleSubtitle2OnSurface(theme: currentTheme)
        } else {
            httpsLabel.applyStyleSubtitle2OnSurface60(theme: currentTheme)
        }
        portTextField.text = (httpsSwitch.isOn) ? kDefaultLoginSecuredPort : kDefaultLoginUnsecuredPort
        enableSaveButton = (serviceDocumentsTextField.text != "")
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
        settingsLabel.text = LocalizationConstants.Labels.AlfrescoContentSettings
        authenticationLabel.text = LocalizationConstants.Labels.authentication
        httpsLabel.text = LocalizationConstants.Labels.https
        copyrightLabel.text = String(format: LocalizationConstants.copyright, Calendar.current.component(.year, from: Date()))

        portTextField.label.text = LocalizationConstants.TextFieldPlaceholders.port
        serviceDocumentsTextField.label.text = LocalizationConstants.TextFieldPlaceholders.serviceDocuments + "*"
        realmTextField.label.text = LocalizationConstants.TextFieldPlaceholders.realm
        clientIDTextField.label.text = LocalizationConstants.TextFieldPlaceholders.clientID

        saveButton.title = LocalizationConstants.Buttons.save
        needHelpButton.setTitle(LocalizationConstants.Buttons.needHelp, for: .normal)
        resetButton.setTitle(LocalizationConstants.Buttons.resetToDefault, for: .normal)
    }

    override func applyComponentsThemes() {
        guard let themingService = self.themingService, let currentTheme = self.themingService?.activeTheme else { return }

        portTextField.applyTheme(withScheme: themingService.containerScheming(for: .loginTextField))
        serviceDocumentsTextField.applyTheme(withScheme: themingService.containerScheming(for: .loginTextField))
        clientIDTextField.applyTheme(withScheme: themingService.containerScheming(for: .loginTextField))
        realmTextField.applyTheme(withScheme: themingService.containerScheming(for: .loginTextField))

        if viewModel.authParameters.https {
            httpsLabel.applyStyleSubtitle2OnSurface(theme: currentTheme)
        } else {
            httpsLabel.applyStyleSubtitle2OnSurface60(theme: currentTheme)
        }
        transportProtocolLabel.applyStyleSubtitle2OnSurface60(theme: currentTheme)
        settingsLabel.applyStyleSubtitle2OnSurface60(theme: currentTheme)
        authenticationLabel.applyStyleSubtitle2OnSurface60(theme: currentTheme)
        titlePadLabel.applyStyleSubtitle2OnSurface60(theme: currentTheme)
        copyrightLabel.applyStyleCaptionOnSurface60(theme: currentTheme)
        copyrightLabel.textAlignment = .center

        resetButton.applyTextTheme(withScheme: themingService.containerScheming(for: .loginResetButton))
        resetButton.isUppercaseTitle = false

        savePadButton.applyTextTheme(withScheme: themingService.containerScheming(for: .loginSavePadButton))
        savePadButton.setTitleColor(currentTheme.dividerColor, for: .disabled)
        savePadButton.isUppercaseTitle = false

        needHelpButton.applyTextTheme(withScheme: themingService.containerScheming(for: .loginNeedHelpButton))
        needHelpButton.isUppercaseTitle = false

        saveButton.tintColor = currentTheme.primaryVariantColor
        backPadButton.tintColor = currentTheme.primaryVariantColor

        view.backgroundColor = currentTheme.backgroundColor
    }

    func updateFields() {
        httpsSwitch.isOn = viewModel.authParameters.https
        portTextField.text = viewModel.authParameters.port
        serviceDocumentsTextField.text = viewModel.authParameters.serviceDocument
        realmTextField.text = viewModel.authParameters.realm
        clientIDTextField.text = viewModel.authParameters.clientID
    }

    func saveFields() {
        if serviceDocumentsTextField.text == "" {
            return
        }
        viewModel.saveFields(https: httpsSwitch.isOn,
                         port: portTextField.text,
                         serviceDocuments: serviceDocumentsTextField.text,
                         realm: realmTextField.text,
                         clientID: clientIDTextField.text)

        let snackbar = Snackbar(with: LocalizationConstants.Errors.saveSettings, type: .approve, automaticallyDismisses: true)
        snackbar.applyTheme(theme: self.themingService?.activeTheme)
        snackbar.hideButton(true)
        snackbar.show(completion: nil)
    }
}

// MARK: - UITextField Delegate

extension AdvancedSettingsViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        keyboardHandling?.adaptFrame(in: scrollView, subview: textField)
        enableSaveButton = (serviceDocumentsTextField.text != "")
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        enableSaveButton = (serviceDocumentsTextField.text != "")
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == serviceDocumentsTextField {
            enableSaveButton = (textField.updatedText(for: range, replacementString: string) != "")
        } else {
            enableSaveButton = (serviceDocumentsTextField.text != "")
        }
        return true
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

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == serviceDocumentsTextField {
            enableSaveButton = false
        }
        return true
    }
}

// MARK: - Storyboard Instantiable

extension AdvancedSettingsViewController: StoryboardInstantiable { }
