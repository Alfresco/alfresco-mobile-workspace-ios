//
//  AuthenticationParameters.swift
//  DBPSampleApp
//
//  Created by Emanuel Lupu on 09/10/2019.
//  Copyright © 2019 Alfresco. All rights reserved.
//

import Foundation

struct AuthenticationParameters {
    var identityServiceURL: String
    let contentURL: String
    let processURL: String
    let realm: String
    let clientID: String
    let redirectURI: String
    
    init(identityServiceURL:String = "", contentURL:String, processURL:String,
         realm:String, clientID:String, redirectURI:String) {
        self.identityServiceURL = identityServiceURL
        self.contentURL = contentURL
        self.processURL = processURL
        self.realm = realm
        self.clientID = clientID
        self.redirectURI = redirectURI
    }
}

