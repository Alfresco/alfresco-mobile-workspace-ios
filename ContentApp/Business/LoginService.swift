//
//  LoginService.swift
//  ContentApp
//
//  Created by Florin Baincescu on 21/05/2020.
//  Copyright © 2020 Florin Baincescu. All rights reserved.
//

import Foundation
import AlfrescoAuth

public typealias AvailableAuthTypeCallback<AuthType> = (Result<AuthType, APIError>) -> Void

class LoginService {
    private (set) var authParameters: AuthSettingsParameters
    private (set) lazy var alfrescoAuth: AlfrescoAuth = {
        let authConfig = authConfiguration()
        return AlfrescoAuth.init(configuration: authConfig)
    }()
    
    var session: AlfrescoAuthSession?
    
    init(with authenticationParameters: AuthSettingsParameters) {
        self.authParameters = authenticationParameters
    }
    
    func availableAuthType(handler: @escaping AvailableAuthTypeCallback<AvailableAuthType>) {
        let authConfig = authConfiguration()
        alfrescoAuth.update(configuration: authConfig)
        alfrescoAuth.availableAuthType(handler: handler)
    }
    
    // MARK: - Private
    
    private func authConfiguration() -> AuthConfiguration {
        let authConfig = AuthConfiguration(baseUrl: authParameters.fullFormatURL,
                                           clientID: authParameters.clientID,
                                           realm: authParameters.realm,
                                           redirectURI: authParameters.redirectURI.encoding())
        
        return authConfig
    }

}
