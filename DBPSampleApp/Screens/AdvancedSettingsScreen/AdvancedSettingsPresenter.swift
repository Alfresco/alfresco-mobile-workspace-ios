//
//  AdvancedSettingsPresenter.swift
//  DBPSampleApp
//
//  Created by Emanuel Lupu on 08/10/2019.
//  Copyright © 2019 Alfresco. All rights reserved.
//

import Foundation

protocol AdvancedSettingsPresenterDelegate: class {
    func didSaveAuthenticationParameters(message: String)
}

class AdvancedSettingsPresenter {
    // Localization
    let contentURLPlaceholderText = LocalizationConstants.LoginAdvancedSettingsIdentifiers.uiContentURL
    let processURLPlaceholderText = LocalizationConstants.LoginAdvancedSettingsIdentifiers.uiProcessURL
    let realmPlaceholderText = LocalizationConstants.LoginAdvancedSettingsIdentifiers.uiRealm
    let clientIDPlaceholderText = LocalizationConstants.LoginAdvancedSettingsIdentifiers.uiClientID
    let redirectURIPlaceholderText = LocalizationConstants.LoginAdvancedSettingsIdentifiers.uiRedirectURI
    
    // Authentication service
    var authenticationService: AuthenticationService?
    
    weak var delegate:AdvancedSettingsPresenterDelegate?
    
    // Computed properties
    var contentURLDefaultValueText: String {
        get {
            guard let contentURL = authenticationService?.authenticationParameters?.contentURL else { return "" }
            return contentURL
        }
    }
    
    var processURLDefaultValueText: String {
        get {
            guard let processURL = authenticationService?.authenticationParameters?.processURL else { return "" }
            return processURL
        }
    }
    
    var realmDefaultValueText: String {
        get {
            guard let realm = authenticationService?.authenticationParameters?.realm else { return "" }
            return realm
        }
    }
    
    var clientIDDefaultValueText: String {
        get {
            guard let clientID = authenticationService?.authenticationParameters?.clientID else { return "" }
            return clientID
        }
    }
    
    var redirectURIDefaultValueText: String {
        get {
            guard let redirectURI = authenticationService?.authenticationParameters?.redirectURI else { return "" }
            return redirectURI
        }
    }
    
    func saveNewAuthenticationParameters(authenticationParameters: AuthenticationParameters) {
        delegate?.didSaveAuthenticationParameters(message: LocalizationConstants.LoginAdvancedSettingsIdentifiers.msgDidSavedLoginParams)
        authenticationService?.authenticationParameters = authenticationParameters
    }
}
