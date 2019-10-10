//
//  LoginPresenter.swift
//  DBPSampleApp
//
//  Created by Emanuel Lupu on 08/10/2019.
//  Copyright © 2019 Alfresco. All rights reserved.
//

import Foundation
import UIKit
import AlfrescoAuth

protocol LoginPresenterDelegate: class {
    func didLogin(message: String)
    func failedToAuthenticate(error: APIError)
}

class LoginPresenter {
    
    // Localization
    let urlPlaceholderText = LocalizationConstants.LoginIdentifiers.uiAlfrescoURL
    let httpsLabelText = LocalizationConstants.LoginIdentifiers.uiLoginHTTPS
    let loginButtonText = LocalizationConstants.LoginIdentifiers.uiLogin
    let advancedSettingsButtonText = LocalizationConstants.LoginIdentifiers.uiAdvancedSettings
    let heloButtonText = LocalizationConstants.LoginIdentifiers.uiHelp
    
    // Authentication service
    var authenticationService: AuthenticationService?
    
    weak var delegate: LoginPresenterDelegate?
    
    func updateAuthenticationParameters(with identityServiceURL:String, isSecureConnection:Bool) {
        let fullFormatURL = String(format: "%@://%@", isSecureConnection ? "https" : "http", identityServiceURL)
        
        authenticationService?.authenticationParameters?.identityServiceURL = fullFormatURL
    }
    
    func login(onViewController viewController: UIViewController) {
        authenticationService?.login(onViewController: viewController, delegate: self)
    }
}

//MARK: - AlfrescoAuth Delegate
extension LoginPresenter: AlfrescoAuthDelegate {
    func didReceive(result: Result<AlfrescoCredential, APIError>) {
        switch result {
        case .success(let alfrescoCredential):
            authenticationService?.credential = alfrescoCredential
            delegate?.didLogin(message: LocalizationConstants.LoginIdentifiers.msgDidLogIn)
        case .failure(let error):
            delegate?.failedToAuthenticate(error: error)
        }
    }
}
