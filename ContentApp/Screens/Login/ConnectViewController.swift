//
//  ConnectViewController.swift
//  ContentApp
//
//  Created by Florin Baincescu on 20/05/2020.
//  Copyright © 2020 Florin Baincescu. All rights reserved.
//

import UIKit
import AlfrescoAuth

class ConnectViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var connectTextField: UITextField!
    
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var advancedSettingsButton: UIButton!
    @IBOutlet weak var needHelpButton: UIButton!
    
    @IBOutlet weak var copyrightLabel: UILabel!
    
    var model: ConnectViewModel = ConnectViewModel()
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLocalization()
        model.delegate = self
        shouldEnableConnectButton()
        hideNavigationBar()
    }
    
    //MARK: - IBActions
    
    @IBAction func connectButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        if let connectURL = self.connectTextField.text {
            model.availableAuthType(for: connectURL)
        }
    }
    
    @IBAction func advancedSettingsButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: kSegueIDAdvancedSettingsVCFromConnectVC, sender: nil)
    }
    
    @IBAction func needHelpButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: kSegueIDHelpVCFromConnectVC, sender: nil)
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: - Helpers
    
    func addLocalization() {
        connectTextField.placeholder = LocalizationConstants.LoginIdentifiers.connectTextFieldPlaceholder
        connectButton.setTitle(LocalizationConstants.LoginIdentifiers.connectButton, for: .normal)
        advancedSettingsButton.setTitle(LocalizationConstants.LoginIdentifiers.advancedSettingButton, for: .normal)
        needHelpButton.setTitle(LocalizationConstants.LoginIdentifiers.needHelpButton, for: .normal)
        copyrightLabel.text = String(format: LocalizationConstants.LoginIdentifiers.copyright, Calendar.current.component(.year, from: Date()))
    }
    
    func shouldEnableConnectButton() {
        self.connectButton.isEnabled = (self.connectTextField.text != "")
    }
    
    func hideNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    
    func authServiceAvailable(for authType:AvailableAuthType) {
        switch authType {
        case .aimsAuth:
            performSegue(withIdentifier: kSegueIDAimsVCFromConnectVC, sender: nil)
        case .basicAuth:
            performSegue(withIdentifier: kSegueIDBasicVCFromConnectVC, sender: nil)
        }
    }
    
    func authServiceUnavailable(with error:APIError) {
        
    }
}
