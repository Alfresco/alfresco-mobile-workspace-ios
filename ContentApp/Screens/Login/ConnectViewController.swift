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
import AlfrescoAuth

import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_FilledTextFieldsTheming

class ConnectViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var connectTextField: MDCFilledTextField!
    @IBOutlet weak var connectButton: MDCButton!
    @IBOutlet weak var advancedSettingsButton: MDCButton!
    @IBOutlet weak var needHelpButton: MDCButton!
    @IBOutlet weak var copyrightLabel: UILabel!

    var keyboardHandling = KeyboardHandling()

    weak var splashScreenDelegate: SplashScreenDelegate?
    weak var connectScreenCoordinatorDelegate: ConnectScreenCoordinatorDelegate?

    var model: ConnectViewModel = ConnectViewModel()
    var enableConnectButton: Bool = false {
        didSet {
            connectButton.isEnabled = enableConnectButton
        }
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = UIDevice.current.userInterfaceIdiom == .pad

        model.delegate = self

        addLocalization()
        addMaterialComponentsTheme()
        enableConnectButton = (connectTextField.text != "")

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar(hide: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationBar(hide: false)
    }

    // MARK: - IBActions

    @IBAction func connectButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let connectURL = connectTextField.text else {
            return
        }
        model.availableAuthType(for: connectURL)
    }

    @IBAction func advancedSettingsButtonTapped(_ sender: UIButton) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            splashScreenDelegate?.showAdvancedSettingsScreen()
        } else {
            connectScreenCoordinatorDelegate?.showAdvancedSettingsScreen()
        }
    }

    @IBAction func needHelpButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: kSegueIDHelpVCFromConnectVC, sender: nil)
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    // MARK: - Helpers

    func addLocalization() {
        productLabel.text = LocalizationConstants.productName
        connectTextField.label.text = LocalizationConstants.TextFieldPlaceholders.connect
        connectButton.setTitle(LocalizationConstants.Buttons.connect, for: .normal)
        advancedSettingsButton.setTitle(LocalizationConstants.Buttons.advancedSetting, for: .normal)
        needHelpButton.setTitle(LocalizationConstants.Buttons.needHelp, for: .normal)
        copyrightLabel.text = String(format: LocalizationConstants.copyright, Calendar.current.component(.year, from: Date()))
    }

    func addMaterialComponentsTheme() {
        let theme = MaterialDesignThemingService()
        theme.activeTheme = DefaultTheme()

        connectButton.applyContainedTheme(withScheme: theme.containerScheming(for: .loginButton))
        advancedSettingsButton.applyTextTheme(withScheme: theme.containerScheming(for: .loginAdvancedSettingsButton))
        needHelpButton.applyTextTheme(withScheme: theme.containerScheming(for: .loginNeedHelpButton))

        connectTextField.applyTheme(withScheme: theme.containerScheming(for: .loginTextField))
        connectTextField.setFilledBackgroundColor(.clear, for: .normal)
        connectTextField.setFilledBackgroundColor(.clear, for: .editing)

        productLabel.textColor = theme.activeTheme?.productLabelColor
        productLabel.font = theme.activeTheme?.productLabelFont

        copyrightLabel.textColor = theme.activeTheme?.loginCopyrightLabelColor
        copyrightLabel.font = theme.activeTheme?.loginCopyrightLabelFont
    }

    func navigationBar(hide: Bool) {
        if hide {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.view.backgroundColor = .clear
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            self.navigationController?.navigationBar.shadowImage = nil
        }
    }
}

// MARK: - UITextField Delegate

extension ConnectViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let textFieldRect = view.convert(textField.frame, to: UIApplication.shared.windows[0])
        let heightTextFieldOpened = textFieldRect.size.height
        keyboardHandling.add(positionObjectInSuperview: textFieldRect.origin.y + heightTextFieldOpened,
                             in: view)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        enableConnectButton = (textField.updatedText(for: range, replacementString: string) != "")
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        connectButtonTapped(connectButton)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        enableConnectButton = (textField.text != "")
    }
}

// MARK: - ConnectViewModel Delegate

extension ConnectViewController: ConnectViewModelDelegate {

    func authServiceAvailable(for authType: AvailableAuthType) {
        switch authType {
        case .aimsAuth:
            performSegue(withIdentifier: kSegueIDAimsVCFromConnectVC, sender: nil)
        case .basicAuth:
            performSegue(withIdentifier: kSegueIDBasicVCFromConnectVC, sender: nil)
        }
    }

    func authServiceUnavailable(with error: APIError) {
    }
}

extension ConnectViewController: StoryboardInstantiable { }
