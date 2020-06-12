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

class AimsViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var hostnameLabel: UILabel!
    @IBOutlet weak var allowLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!

    @IBOutlet weak var repositoryTextField: MDCFilledTextField!
    @IBOutlet weak var signInButton: MDCButton!
    @IBOutlet weak var needHelpButton: MDCButton!

    weak var splashScreenDelegate: SplashScreenDelegate?
    weak var aimsScreenCoordinatorDelegate: AimsScreenCoordinatorDelegate?
    var viewModel: AimsViewModel?

    var keyboardHandling: KeyboardHandling? = KeyboardHandling()
    var themingService: MaterialDesignThemingService?
    var activityIndicator: ActivityIndicatorView?

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
        addMaterialComponentsTheme()
        enableSignInButton = (repositoryTextField.text != "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator = ActivityIndicatorView(themingService: themingService)
        activityIndicator?.label(text: LocalizationConstants.Labels.signingIn)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Snackbar.dimissAll()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        activityIndicator?.reload(from: size)
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        guard ThemeMode.get() == .auto else { return }
        switch newCollection.userInterfaceStyle {
        case .dark:
            self.themingService?.activateDarkTheme()
        case .light:
            self.themingService?.activateDefaultTheme()
        default: break
        }
        addMaterialComponentsTheme()
    }

    // MARK: - IBActions

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        guard let repositoryURL = repositoryTextField.text else {
            return
        }
        activityIndicator?.state = .isLoading
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
        copyrightLabel.text = String(format: LocalizationConstants.copyright, Calendar.current.component(.year, from: Date()))
    }

    func addMaterialComponentsTheme() {
        guard let themingService = self.themingService else {
            return
        }

        signInButton.applyContainedTheme(withScheme: themingService.containerScheming(for: .loginButton))
        signInButton.setBackgroundColor(themingService.activeTheme?.loginButtonDisableColor, for: .disabled)
        needHelpButton.applyTextTheme(withScheme: themingService.containerScheming(for: .loginNeedHelpButton))

        repositoryTextField.applyTheme(withScheme: themingService.containerScheming(for: .loginTextField))
        repositoryTextField.setFilledBackgroundColor(.clear, for: .normal)
        repositoryTextField.setFilledBackgroundColor(.clear, for: .editing)

        productLabel.textColor = themingService.activeTheme?.productLabelColor
        productLabel.font = themingService.activeTheme?.productLabelFont

        infoLabel.textColor = themingService.activeTheme?.loginInfoLabelColor
        infoLabel.font = themingService.activeTheme?.loginInfoLabelFont

        hostnameLabel.textColor = themingService.activeTheme?.loginInfoLabelColor
        hostnameLabel.font = themingService.activeTheme?.loginInfoHostnameLabelFont

        allowLabel.textColor = themingService.activeTheme?.loginFieldLabelColor
        allowLabel.font = themingService.activeTheme?.loginInfoHostnameLabelFont

        copyrightLabel.textColor = themingService.activeTheme?.loginCopyrightLabelColor
        copyrightLabel.font = themingService.activeTheme?.loginCopyrightLabelFont
    }

    func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - UITextField Delegate

extension AimsViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        keyboardHandling?.adaptFrame(in: view, subview: textField)
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

// MARK: - Aims ViewModel Delegate

extension AimsViewController: AimsViewModelDelegate {
    func logInFailed(with error: APIError) {
        activityIndicator?.state = .isIdle
        if error.responseCode != kLoginAIMSCancelWebViewErrorCode {
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self, let themingService = sSelf.themingService  else { return }
                let snackbar = Snackbar(with: error.mapToMessage(), type: .error, automaticallyDismisses: false)
                snackbar.applyThemingService(themingService)
                snackbar.show(completion: nil)
            }
        }
    }

    func logInSuccessful() {
        activityIndicator?.state = .isIdle
        showAlert(message: "Login with AIMS with success!")
    }
}

// MARK: - Storyboard Instantiable

extension AimsViewController: StoryboardInstantiable { }
