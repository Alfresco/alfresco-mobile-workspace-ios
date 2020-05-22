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

class ConnectViewController: UIViewController, SplashScreenProtocol {
    weak var delegate: SplashScreenDelegate?

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var connectTextField: UITextField!

    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var advancedSettingsButton: UIButton!
    @IBOutlet weak var needHelpButton: UIButton!

    @IBOutlet weak var copyrightLabel: UILabel!

    var model: ConnectViewModel = ConnectViewModel()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = UIDevice.current.userInterfaceIdiom == .pad
        model.delegate = self

        addLocalization()
        shouldEnableConnectButton()
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
        if let connectURL = self.connectTextField.text {
            model.availableAuthType(for: connectURL)
        }
    }

    @IBAction func advancedSettingsButtonTapped(_ sender: UIButton) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.delegate?.showAdvancedSettingsScreen()
        } else {
            self.performSegue(withIdentifier: kSegueIDAdvancedSettingsVCFromConnectVC, sender: nil)
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
        connectTextField.placeholder = LocalizationConstants.TextFieldPlaceholders.connect
        connectButton.setTitle(LocalizationConstants.Buttons.connect, for: .normal)
        advancedSettingsButton.setTitle(LocalizationConstants.Buttons.advancedSetting, for: .normal)
        needHelpButton.setTitle(LocalizationConstants.Buttons.needHelp, for: .normal)
        copyrightLabel.text = String(format: LocalizationConstants.copyright, Calendar.current.component(.year, from: Date()))
    }

    func shouldEnableConnectButton() {
        self.connectButton.isEnabled = (self.connectTextField.text != "")
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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.delegate?.backButton(hidden: false)
        switch segue.identifier {
        case kSegueIDHelpVCFromConnectVC: break
        default: break
        }
    }
}

// MARK: - UITextField Delegate

extension ConnectViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        shouldEnableConnectButton()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        shouldEnableConnectButton()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        shouldEnableConnectButton()
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
