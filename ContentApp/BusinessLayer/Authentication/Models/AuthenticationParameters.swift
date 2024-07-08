//
// Copyright (C) 2005-2020 Alfresco Software Limited.
//
// This file is part of the Alfresco Content Mobile iOS App.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import AlfrescoAuth

class AuthenticationParameters: Codable {
    var unsecuredDefaultPort = "80"
    var securedDefaultPort = "443"
    var https = true
    var port: String = "443"
    var path: String = "alfresco"
    var realm: String = "alfresco"
    var clientID: String = "alfresco-ios-acs-app"
    var redirectURI: String = "iosacsapp://aims/auth"
    var hostname: String = ""
    var contentURL: String = ""
    var fullHostnameURL: String {
        var fullFormatURL = String(format: "%@://%@", https ? "https" : "http", hostname)
        return urlWithPort(fullFormatURL: &fullFormatURL)
    }

    var fullContentURL: String {
        var fullFormatURL = String(format: "%@://%@", https ? "https" : "http", contentURL)
        return urlWithPort(fullFormatURL: &fullFormatURL)
    }
    
    var processAppClientID: String = "activiti-app"
    var processAppQueryString: String = "api"
    var processAppDefinition: String = "enterprise"
    var authType: AvailableAuthType = .aimsAuth
    var authTypeID: String = "1"
    
    static func parameters() -> AuthenticationParameters {
        parameters(for: KeyConstants.Save.authSettingsParameters)
    }

    static func parameters(for accountIdentifier: String) -> AuthenticationParameters {
        if let data = UserDefaultsModel.value(for: accountIdentifier) as? Data {
            if let params = try? PropertyListDecoder().decode(AuthenticationParameters.self, from: data) {
                return params
            }
        }
        return AuthenticationParameters()
    }

    func save() {
        save(for: KeyConstants.Save.authSettingsParameters)
    }

    func save(for accountIdentifier: String) {
        UserDefaultsModel.set(value: try? PropertyListEncoder().encode(self), for: accountIdentifier)
        AlfrescoLog.debug("Authentication parameters saved in UserDefaults:\n\(Mirror.description(for: self))")
    }

    func remove(for accountIdentifier: String) {
        UserDefaultsModel.remove(forKey: accountIdentifier)
        AlfrescoLog.debug("Authentication parameters removed for account: \(accountIdentifier)")
    }

    func authenticationConfiguration() -> AuthConfiguration {
        let authConfig = AuthConfiguration(baseUrl: fullHostnameURL,
                                           clientID: clientID,
                                           realm: realm,
                                           redirectURI: redirectURI.encoding(), authType: authType)
        return authConfig
    }
    
    func urlWithPort(fullFormatURL: inout String) -> String {
        if !port.isEmpty {
            if https && port != securedDefaultPort {
                fullFormatURL.append(contentsOf: String(format: ":%@", port))
            } else if !https && port != unsecuredDefaultPort {
                fullFormatURL.append(contentsOf: String(format: ":%@", port))
            }
        }
        return fullFormatURL
    }
}
