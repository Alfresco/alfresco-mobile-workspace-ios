//
//  AdvancedSettingsViewController.swift
//  DBPSampleApp
//
//  Created by Emanuel Lupu on 08/10/2019.
//  Copyright © 2019 Alfresco. All rights reserved.
//

import UIKit
import MaterialComponents

class AdvancedSettingsViewController: UIViewController {
    // Presenter
    let advancedSettingsPresenter: AdvancedSettingsPresenter = AdvancedSettingsPresenter()
    
    // Gesture recognizer
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    // Content and Process URL fields
    @IBOutlet weak var contentURLTextField: MDCTextField!
    @IBOutlet weak var processURLTextField: MDCTextField!
    var contentURLTextFieldController: MDCTextInputControllerOutlined?
    var processURLTextFieldController: MDCTextInputControllerOutlined?
    
    // Authentication parameter fields
    @IBOutlet weak var realmTextField: MDCTextField!
    @IBOutlet weak var clientIDTextField: MDCTextField!
    @IBOutlet weak var redirectURITextField: MDCTextField!
    var realmTextFieldController: MDCTextInputControllerOutlined?
    var clientIDTextFieldController: MDCTextInputControllerOutlined?
    var redirectURITextFieldController: MDCTextInputControllerOutlined?
    
    // Keyboard handling
    var adjustViewForKeyboard: Bool = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        advancedSettingsPresenter.delegate = self
        
        // Content and Process URL fields set up
        contentURLTextFieldController = MDCTextInputControllerOutlined(textInput: contentURLTextField)
        contentURLTextFieldController?.placeholderText = advancedSettingsPresenter.contentURLPlaceholderText
        contentURLTextField.text = advancedSettingsPresenter.contentURLDefaultValueText
        
        processURLTextFieldController = MDCTextInputControllerOutlined(textInput: processURLTextField)
        processURLTextFieldController?.placeholderText = advancedSettingsPresenter.processURLPlaceholderText
        processURLTextField.text = advancedSettingsPresenter.processURLDefaultValueText
        
        if let contentURLTextFieldController = self.contentURLTextFieldController,
            let processURLTextFieldController = self.processURLTextFieldController {
            MDCTextFieldColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: contentURLTextFieldController)
            MDCTextFieldColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: processURLTextFieldController)
        }
        
        // Authentication parameter fields set up
        realmTextFieldController = MDCTextInputControllerOutlined(textInput: realmTextField)
        realmTextFieldController?.placeholderText = advancedSettingsPresenter.realmPlaceholderText
        realmTextField.text = advancedSettingsPresenter.realmDefaultValueText
        
        clientIDTextFieldController = MDCTextInputControllerOutlined(textInput: clientIDTextField)
        clientIDTextFieldController?.placeholderText = advancedSettingsPresenter.clientIDPlaceholderText
        clientIDTextField.text = advancedSettingsPresenter.clientIDDefaultValueText
        
        redirectURITextFieldController = MDCTextInputControllerOutlined(textInput: redirectURITextField)
        redirectURITextFieldController?.placeholderText = advancedSettingsPresenter.redirectURIPlaceholderText
        redirectURITextField.text = advancedSettingsPresenter.redirectURIDefaultValueText
        
        if let realmTextFieldController = self.realmTextFieldController,
            let clientIDTextFieldController = self.clientIDTextFieldController,
            let redirectURITextFieldController = self.redirectURITextFieldController {
            MDCTextFieldColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: realmTextFieldController)
            MDCTextFieldColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: clientIDTextFieldController)
            MDCTextFieldColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: redirectURITextFieldController)
        }
        
        contentURLTextField.delegate = self
        processURLTextField.delegate = self
        realmTextField.delegate = self
        clientIDTextField.delegate = self
        redirectURITextField.delegate = self
        
        // Keyboard handling
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        if let gestureRecognizer = tapGestureRecognizer {
            self.view .addGestureRecognizer(gestureRecognizer)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: Action handling
    
    @IBAction func onSaveButtonTap(_ sender: Any) {
        self.view.endEditing(true)
        let authenticationParameters = AuthenticationParameters(contentURL: self.contentURLTextField.text ?? "",
                                                                processURL: self.processURLTextField.text ?? "",
                                                                realm: self.realmTextField.text ?? "",
                                                                clientID: self.clientIDTextField.text ?? "",
                                                                redirectURI: self.redirectURITextField.text ?? "")
        advancedSettingsPresenter.saveNewAuthenticationParameters(authenticationParameters: authenticationParameters)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if adjustViewForKeyboard {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 200
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

//MARK: UITextFieldDelegate

extension AdvancedSettingsViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if clientIDTextField == textField || redirectURITextField == textField {
            adjustViewForKeyboard = true
        } else {
            adjustViewForKeyboard = false
        }
        
        return true;
    }
}

//MARK: AdvancedSettingsPresenterDelegate

extension AdvancedSettingsViewController: AdvancedSettingsPresenterDelegate {
    func didSaveAuthenticationParameters(message: String) {
        self.navigationController?.popViewController(animated: true)
        showToastWithMessage(message: message)
    }
}
