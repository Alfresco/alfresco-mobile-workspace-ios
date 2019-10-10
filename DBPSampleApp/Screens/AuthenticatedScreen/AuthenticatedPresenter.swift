//
//  AuthenticatedPresenter.swift
//  DBPSampleApp
//
//  Created by Emanuel Lupu on 09/10/2019.
//  Copyright © 2019 Alfresco. All rights reserved.
//

import Foundation
import AlfrescoAuth

protocol AuthenticatedPresenterDelegate: class {
    func didRefreshSession(message: String)
    func failedToAuthenticate(error: APIError)
}

class AuthenticatedPresenter {
    // Localization
    let refreshSessionText = LocalizationConstants.AuthenticatedIdentifiers.uiRefreshSession
    
    // Authentication service
    var authenticationService: AuthenticationService?
    
    weak var delegate: AuthenticatedPresenterDelegate?
    
    func refreshSession () {
        authenticationService?.refreshSession(delegate: self)
    }
    
    func logOut () {
        authenticationService?.logOut()
    }
}

//MARK: - AlfrescoAuth Delegate
extension AuthenticatedPresenter: AlfrescoAuthDelegate {
    func didReceive(result: Result<AlfrescoCredential, APIError>) {
        switch result {
        case .success(let alfrescoCredential):
            authenticationService?.credential = alfrescoCredential
            delegate?.didRefreshSession(message: LocalizationConstants.AuthenticatedIdentifiers.msgSessionRefresh)
        case .failure(let error):
            delegate?.failedToAuthenticate(error: error)
        }
    }
}
