//
//  LoginViewController.swift
//  DBPSampleApp
//
//  Created by Emanuel Lupu on 08/10/2019.
//  Copyright © 2019 Alfresco. All rights reserved.
//

import UIKit
import MaterialComponents
import AlfrescoAuth

class LoginViewController: UIViewController {
    // Presenter
    let loginPresenter: LoginPresenter = LoginPresenter()
    
    // Gesture recognizer
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    // URL text field
    @IBOutlet weak var urlTextField: MDCTextField!
    var urlTextFieldController: MDCTextInputControllerOutlined?
    
    // HTTPS section
    @IBOutlet weak var httpsLabel: UILabel!
    @IBOutlet weak var httpsSwitch: UISwitch!
    
    // Buttons section
    @IBOutlet weak var loginButton: MDCButton!
    @IBOutlet weak var advancedSettingsButton: MDCButton!
    @IBOutlet weak var helpButton: MDCButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginPresenter.delegate = self
        
        // URL text field set up
        urlTextFieldController = MDCTextInputControllerOutlined(textInput: urlTextField)
        urlTextFieldController?.placeholderText = loginPresenter.urlPlaceholderText
        
        if let urlTextFieldController = self.urlTextFieldController {
            MDCTextFieldColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme,
            to: urlTextFieldController)
        }
        
        // HTTPS section set up
        httpsLabel.text = loginPresenter.httpsLabelText
        httpsLabel.font = ApplicationScheme.shared.typographyScheme.subtitle1
        httpsLabel.textColor = ApplicationScheme.shared.colorScheme.onBackgroundColor
        httpsSwitch.onTintColor = ApplicationScheme.shared.colorScheme.primaryColor
        
        // Buttons section set up
        loginButton.applyContainedTheme(withScheme: ApplicationScheme.shared.buttonScheme)
        loginButton.setElevation(ShadowElevation.none, for: .normal)
        loginButton.setElevation(ShadowElevation.none, for: .highlighted)
        advancedSettingsButton.applyTextTheme(withScheme: ApplicationScheme.shared.buttonScheme)
        helpButton.applyTextTheme(withScheme: ApplicationScheme.shared.buttonScheme)
        
        loginButton.setTitle(loginPresenter.loginButtonText, for: .normal)
        advancedSettingsButton.setTitle(loginPresenter.advancedSettingsButtonText, for: .normal)
        helpButton.setTitle(loginPresenter.heloButtonText, for: .normal)
        
        // Dismiss keyboard on taps outside text fields
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        if let gestureRecognizer = tapGestureRecognizer {
            self.view .addGestureRecognizer(gestureRecognizer)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: Login actions
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        loginPresenter.updateAuthenticationParameters(with: self.urlTextField.text ?? "", isSecureConnection: self.httpsSwitch.isOn)
        loginPresenter.login(onViewController: self)
    }
    
    @IBAction func advancedSettingsButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "AdvancedSettingsViewControllerSegue", sender: sender)
    }
    
    @IBAction func helpButtonTapped(_ sender: Any) {
       if let url = URL(string: kAlfrescoDocsURL) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        dismissKeyboard()
        if segue.identifier == kSegueAdvancedSettingsViewController {
            let vc = segue.destination as! AdvancedSettingsViewController
            vc.advancedSettingsPresenter.authenticationService = loginPresenter.authenticationService
        } else if segue.identifier == kSegueAuthenticatedViewController {
            let vc = segue.destination as! AuthenticatedViewController
            vc.authenticatedPresenter.authenticationService = loginPresenter.authenticationService
        }
    }
}

// MARK: LoginPresenterDelegate


extension LoginViewController: LoginPresenterDelegate {
    func didLogin(message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.showToastWithMessage(message: message)
            
            sSelf.performSegue(withIdentifier: kSegueAuthenticatedViewController, sender: nil)
        }
    }
    
    func failedToAuthenticate(error: APIError) {
        showToastWithErrorMessage(message: error.localizedDescription)
    }
}
