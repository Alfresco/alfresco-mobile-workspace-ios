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
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class AimsViewController: SystemThemableViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var hostnameLabel: UILabel!
    @IBOutlet weak var allowLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!

    @IBOutlet weak var repositoryTextField: MDCOutlinedTextField!
    @IBOutlet weak var signInButton: MDCButton!
    @IBOutlet weak var needHelpButton: MDCButton!

    weak var splashScreenDelegate: SplashScreenDelegate?
    weak var aimsScreenCoordinatorDelegate: AimsScreenCoordinatorDelegate?
    var viewModel: AimsViewModel?

    var keyboardHandling: KeyboardHandling? = KeyboardHandling()

    var enableSignInButton: Bool = false {
        didSet {
            signInButton.isEnabled = enableSignInButton
            signInButton.tintColor = signInButton.currentTitleColor
        }
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel?.delegate = self

        addLocalization()
        enableSignInButton = (repositoryTextField.text != "")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Snackbar.dimissAll()
    }

    // MARK: - IBActions

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        guard let repositoryURL = repositoryTextField.text else {
            return
        }
        Snackbar.dimissAll()
        viewModel?.login(repository: repositoryURL, in: self)
    }

    @IBAction func needHelpButtonTapped(_ sender: Any) {
        aimsScreenCoordinatorDelegate?.showNeedHelpSheet()
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    // MARK: - Helpers

    func addLocalization() {
        self.title = ""
        productLabel.text = LocalizationConstants.productName
        infoLabel.text = LocalizationConstants.Labels.infoAimsConnectTo
        hostnameLabel.text = viewModel?.hostname()
        allowLabel.text = LocalizationConstants.Labels.allowSSO
        repositoryTextField.label.text = LocalizationConstants.TextFieldPlaceholders.repository
        signInButton.setTitle(LocalizationConstants.Buttons.signInWithSSO, for: .normal)
        signInButton.setTitle(LocalizationConstants.Buttons.signInWithSSO, for: .disabled)
        needHelpButton.setTitle(LocalizationConstants.Buttons.needHelp, for: .normal)
        copyrightLabel.text =
            String(format: LocalizationConstants.copyright, Calendar.current.component(.year,
                                                                                       from: Date()))
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let bigButtonScheme = coordinatorServices?.themingService?.containerScheming(for: .loginBigButton),
              let smallButtonScheme = coordinatorServices?.themingService?.containerScheming(for: .loginSmallButton),
              let repositoryTextFieldScheme = coordinatorServices?.themingService?.containerScheming(for: .loginTextField),
              let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }

        separator.backgroundColor = currentTheme.onSurface15Color

        signInButton.applyContainedTheme(withScheme: bigButtonScheme)
        signInButton.setBackgroundColor(currentTheme.onSurface15Color, for: .disabled)
        signInButton.isUppercaseTitle = false
        signInButton.setShadowColor(.clear, for: .normal)

        needHelpButton.applyTextTheme(withScheme: smallButtonScheme)
        needHelpButton.isUppercaseTitle = false

        repositoryTextField.applyTheme(withScheme: repositoryTextFieldScheme)

        productLabel.applyeStyleHeadline6OnSurface(theme: currentTheme)
        infoLabel.applyStyleCaptionOnSurface60(theme: currentTheme)
        allowLabel.applyStyleBody2OnSurface60(theme: currentTheme)

        hostnameLabel.textColor = currentTheme.onSurfaceColor
        hostnameLabel.font = currentTheme.body1TextStyle.font

        copyrightLabel.applyStyleCaptionOnSurface60(theme: currentTheme)
        copyrightLabel.textAlignment = .center
        productLabel.textAlignment = .center

        view.backgroundColor = currentTheme.surfaceColor
    }
}

// MARK: - UITextField Delegate

extension AimsViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        keyboardHandling?.adaptFrame(in: view, subview: textField)
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        enableSignInButton = (textField.updatedText(for: range,
                                                    replacementString: string) != "")
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

// MARK: - Aims ViewModel Delegate

extension AimsViewController: AimsViewModelDelegate {
    func logInFailed(with error: APIError) {
        if error.responseCode != kLoginAIMSCancelWebViewErrorCode {
            Snackbar.display(with: error.mapToMessage(), type: .error, finish: nil)
        }
    }

    func logInSuccessful() {
        aimsScreenCoordinatorDelegate?.showApplicationTabBar()
    }
}

// MARK: - Storyboard Instantiable

extension AimsViewController: StoryboardInstantiable { }
