//
//  ViewController.swift
//  DBPSampleApp
//
//  Created by Florin Baincescu on 12/08/2019.
//  Copyright © 2019 Alfresco. All rights reserved.
//

import UIKit
import AlfrescoAuth


class ViewController: UIViewController {
    
    var authViewController: UIViewController!
    var alfrescoAuth: AlfrescoAuth!
    var alfrescoCredential: AlfrescoCredential?
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var console: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let authConfig = AuthConfiguration(baseUrl: kBaseUrlString,
                                           clientID: kClientID,
                                           realm: kRealm,
                                           clientSecret: kClientSecret,
                                           redirectURI: kRedirectUri)
        alfrescoAuth = AlfrescoAuth.init(configuration: authConfig)
    }
    
    //MARK: - IBActions
    
    @IBAction func loginWithSAMLButtonPressed(_ sender: UIButton) {
        addConsole(message: "SAML!")
        authViewController = alfrescoAuth.webAuth(delegate: self)
        self.navigationController?.pushViewController(authViewController, animated: true)
    }
    
    @IBAction func loginWithBasicButtonPressed(_ sender: Any) {
        addConsole(message: "Basic login!")
        alfrescoAuth.basicAuth(username: usernameTextField.text, password: passwordTextField.text, delegate: self)
    }
    
    @IBAction func refreshSessionButtonPressed(_ sender: Any) {
        if let cred = self.alfrescoCredential {
            addConsole(message: "Refresh session!")
            alfrescoAuth.refreshSession(credential: cred, delegate: self)
        }
    }
    
    @IBAction func loginWithPKCEPressed(_ sender: Any) {
        addConsole(message: "PKCE login!")
        appDelegate?.alfrescoAuthSession = alfrescoAuth.pkceAuth(onViewController: self, delegate: self)
    }
    
    @IBAction func refreshPKCEButtonPressed(_ sender: Any) {
        addConsole(message: "Refresh PKCE session!")
        alfrescoAuth.pkceRefreshSession(delegate: self)
    }
    
    //MARK: - Utils
    
    func showAlertView(with message: String) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) {
            UIAlertAction in
            self.navigationController?.popViewController(animated: false)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addConsole(message: String) {
        console.text = console.text + "\n\(message)"
    }
}

//MARK: - AlfrescoAuth Delegate

extension ViewController: AlfrescoAuthDelegate {
    func didReceive(result: Result<AlfrescoCredential, APIError>) {
        switch result {
        case .success(let alfrescoCredential):
            showAlertView(with: "Authentication successful!")
            print(alfrescoCredential as AnyObject)
            addConsole(message: "Token received!")
            self.alfrescoCredential = alfrescoCredential
        case .failure(let error):
            showAlertView(with: error.localizedDescription)
            print(error)
            addConsole(message: "Error:" + error.localizedDescription)
        }
    }
}

 
