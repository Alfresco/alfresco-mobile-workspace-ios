//
//  AuthenticationService.swift
//  DBPSampleApp
//
//  Created by Emanuel Lupu on 09/10/2019.
//  Copyright © 2019 Alfresco. All rights reserved.
//

import Foundation
import AlfrescoAuth

class AuthenticationService {
    var authenticationParameters: AuthenticationParameters?
    
    // Alfresco Auth module
    var alfrescoAuth: AlfrescoAuth?
    var session: AlfrescoAuthSession?
    var credential: AlfrescoCredential?
    
    
    init() {
        self.authenticationParameters = AuthenticationParameters(contentURL: kContentURL,
                                                                 processURL: kProcessURL,
                                                                 realm: kRealm,
                                                                 clientID: kClientID,
                                                                 redirectURI: kRedirectURI)
    }
    
    func login(onViewController viewController: UIViewController, delegate: AlfrescoAuthDelegate) {
        if let authenticationParameters = self.authenticationParameters {
            let authConfig = AuthConfiguration(baseUrl: authenticationParameters.identityServiceURL,
                                               clientID: authenticationParameters.clientID,
                                               realm: authenticationParameters.realm,
                                               redirectURI: authenticationParameters.redirectURI)
            alfrescoAuth = AlfrescoAuth.init(configuration: authConfig)
            session = alfrescoAuth?.pkceAuth(onViewController: viewController, delegate: delegate)
        }
    }
    
    func refreshSession (delegate: AlfrescoAuthDelegate) {
        alfrescoAuth?.pkceRefreshSession(delegate: delegate)
    }
    
    func logOut () {
        alfrescoAuth = nil
        session = nil
        credential = nil
    }
}
