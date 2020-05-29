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

class AuthSettingsParameters: Codable {
    var https: Bool = false
    var port: String = "80"
    var serviceDocument: String = "content-app"
    var realm: String = "alfresco"
    var clientID: String = "alfresco-ios-acs-app"
    var redirectURI: String = "iosacsapp://aims/auth"
    var hostname: String = ""
    var contentURL: String = ""
    var fullHostnameURL: String {
        var fullFormatURL = String(format: "%@://%@", https ? "https" : "http", hostname)
        if port.count != 0 {
            fullFormatURL.append(contentsOf: String(format: ":%@", port))
        }
        return fullFormatURL
    }

    var fullContentURL: String {
        var fullFormatURL = String(format: "%@://%@", https ? "https" : "http", contentURL)
        if port.count != 0 {
            fullFormatURL.append(contentsOf: String(format: ":%@", port))
        }
        return fullFormatURL
    }

    static func parameters() -> AuthSettingsParameters {
        let defaults = UserDefaults.standard
        if let data = defaults.value(forKey: kSaveAuthSettingsParameters) as? Data {
            if let params = try? PropertyListDecoder().decode(AuthSettingsParameters.self, from: data) {
                return params
            }
        }
        return AuthSettingsParameters()
    }

    func save() {
        let defaults = UserDefaults.standard
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self),
                                  forKey: kSaveAuthSettingsParameters)
        defaults.synchronize()
        AlfrescoLog.debug("Authentication Settings Parameters saved in UserDefaults:\n\(Mirror.description(for: self))")
    }
}
