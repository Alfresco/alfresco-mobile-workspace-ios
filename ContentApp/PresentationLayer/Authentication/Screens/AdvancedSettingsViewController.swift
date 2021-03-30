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
    @IBOutlet weak var resetToDefaultPadButton: MDCButton!
    @IBOutlet weak var navigationPadBar: UIView!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var transportProtocolLabel: UILabel!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var authenticationLabel: UILabel!

    @IBOutlet weak var httpsLabel: UILabel!
    @IBOutlet weak var httpsSwitch: UISwitch!

    @IBOutlet weak var portTextField: MDCOutlinedTextField!
    @IBOutlet weak var pathTextField: MDCOutlinedTextField!
    @IBOutlet weak var realmTextField: MDCOutlinedTextField!
    @IBOutlet weak var clientIDTextField: MDCOutlinedTextField!

    @IBOutlet weak var resetToDefaultButton: UIBarButtonItem!
    @IBOutlet weak var needHelpButton: MDCButton!
    @IBOutlet weak var saveButton: MDCButton!
    @IBOutlet weak var copyrightLabel: UILabel!

    weak var advSettingsScreenCoordinatorDelegate: AdvancedSettingsScreenCoordinatorDelegate?
    var viewModel = AdvancedSettingsViewModel()

    var keyboardHandling: KeyboardHandling? = KeyboardHandling()

    var enableSaveButton = false {
        didSet {
            saveButton.isEnabled = enableSaveButton
        }
    }

    let unsecuredDefaultPort = "80"
    let securedDefaultPort = "443"

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

    @IBAction func resetToDefaultPadButtonTapped(_ sender: UIButton) {
        viewModel.resetAuthParameters()
        updateFields()
        enableSaveButton = true
    }

    @IBAction func httpsSwitchTapped(_ sender: UISwitch) {
        self.view.endEditing(true)
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        if httpsSwitch.isOn {
            httpsLabel.applyStyleSubtitle2OnSurface(theme: currentTheme)
        } else {
            httpsLabel.applyStyleSubtitle2OnSurface60(theme: currentTheme)
        }
        portTextField.text =
            (httpsSwitch.isOn) ? securedDefaultPort : unsecuredDefaultPort
        enableSaveButton = !pathTextField.isEmpty()
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        saveFields()
        enableSaveButton = false
    }

    @IBAction func needHelpButtonTapped(_ sender: UIButton) {
        advSettingsScreenCoordinatorDelegate?.showNeedHelpSheet()
    }

    @IBAction func resetToDefaultButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.resetAuthParameters()
        updateFields()
        enableSaveButton = true
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    // MARK: - Helpers

    func addLocalization() {
        titlePadLabel.text = LocalizationConstants.ScreenTitles.advancedSettings
        title = LocalizationConstants.ScreenTitles.advancedSettings

        transportProtocolLabel.text = LocalizationConstants.Labels.transportProtocol
        settingsLabel.text = LocalizationConstants.Labels.AlfrescoContentSettings
        authenticationLabel.text = LocalizationConstants.Labels.authentication
        httpsLabel.text = LocalizationConstants.Labels.https
        copyrightLabel.text = String(format: LocalizationConstants.copyright,
                                     Calendar.current.component(.year, from: Date()))

        portTextField.label.text = LocalizationConstants.TextFieldPlaceholders.port
        pathTextField.label.text = LocalizationConstants.TextFieldPlaceholders.path + "*"
        realmTextField.label.text = LocalizationConstants.TextFieldPlaceholders.realm
        clientIDTextField.label.text = LocalizationConstants.TextFieldPlaceholders.clientID

        needHelpButton.setTitle(LocalizationConstants.Buttons.needHelp, for: .normal)
        saveButton.setTitle(LocalizationConstants.General.save, for: .normal)
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard
            let loginTextFieldScheme = coordinatorServices?.themingService?.containerScheming(for: .loginTextField),
            let bigButtonScheme = coordinatorServices?.themingService?.containerScheming(for: .loginBigButton),
            let smallButtonScheme = coordinatorServices?.themingService?.containerScheming(for: .loginSmallButton),
            let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }

        portTextField.applyTheme(withScheme: loginTextFieldScheme)
        pathTextField.applyTheme(withScheme: loginTextFieldScheme)
        clientIDTextField.applyTheme(withScheme: loginTextFieldScheme)
        realmTextField.applyTheme(withScheme: loginTextFieldScheme)

        if viewModel.authParameters.https {
            httpsLabel.applyStyleSubtitle2OnSurface(theme: currentTheme)
        } else {
            httpsLabel.applyStyleSubtitle2OnSurface60(theme: currentTheme)
        }
        transportProtocolLabel.applyStyleSubtitle2OnSurface60(theme: currentTheme)
        settingsLabel.applyStyleSubtitle2OnSurface60(theme: currentTheme)
        authenticationLabel.applyStyleSubtitle2OnSurface60(theme: currentTheme)
        titlePadLabel.applyeStyleHeadline6OnSurface(theme: currentTheme)
        copyrightLabel.applyStyleCaptionOnSurface60(theme: currentTheme)
        copyrightLabel.textAlignment = .center

        saveButton.applyContainedTheme(withScheme: bigButtonScheme)
        saveButton.setBackgroundColor(currentTheme.onSurface5Color,
                                      for: .disabled)
        saveButton.isUppercaseTitle = false
        saveButton.setShadowColor(.clear, for: .normal)

        resetToDefaultPadButton.backgroundColor = .clear
        resetToDefaultPadButton.tintColor = currentTheme.onSurface60Color
        resetToDefaultButton.tintColor = currentTheme.onSurface60Color

        backPadButton.tintColor = currentTheme.onSurface60Color

        needHelpButton.applyTextTheme(withScheme: smallButtonScheme)
        needHelpButton.isUppercaseTitle = false

        view.backgroundColor = currentTheme.surfaceColor
        navigationPadBar.backgroundColor = currentTheme.surfaceColor
    }

    func updateFields() {
        httpsSwitch.isOn = viewModel.authParameters.https
        portTextField.text = viewModel.authParameters.port
        pathTextField.text = viewModel.authParameters.path
        realmTextField.text = viewModel.authParameters.realm
        clientIDTextField.text = viewModel.authParameters.clientID
    }

    func saveFields() {
        if pathTextField.isEmpty() {
            return
        }
        viewModel.saveFields(https: httpsSwitch.isOn,
                         port: portTextField.text,
                         path: pathTextField.text,
                         realm: realmTextField.text,
                         clientID: clientIDTextField.text)

        Snackbar.display(with: LocalizationConstants.Approved.saveSettings,
                         type: .approve,
                         finish: nil)
    }
}

// MARK: - UITextField Delegate

extension AdvancedSettingsViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        keyboardHandling?.adaptFrame(in: scrollView, subview: textField)
        enableSaveButton = !pathTextField.isEmpty()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        enableSaveButton = !pathTextField.isEmpty()
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == pathTextField {
            enableSaveButton = (textField.updatedText(for: range,
                                                      replacementString: string) != "")
        } else {
            enableSaveButton = !pathTextField.isEmpty()
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var nextTextField = textField
        switch textField {
        case portTextField:
            nextTextField = pathTextField
        case pathTextField:
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
        if textField == pathTextField {
            enableSaveButton = false
        }
        return true
    }
}

// MARK: - Storyboard Instantiable

extension AdvancedSettingsViewController: StoryboardInstantiable { }
