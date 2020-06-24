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

import UIKit

class BasicAuthAccount: AccountProtocol, Equatable {

    var identifier: String {
        return credential.username
    }
    var apiBasePath: String {
        return "\(parameters.fullHostnameURL)/\(parameters.serviceDocument)/\(kAPIPathBase)"
    }
    var parameters: AuthenticationParameters
    var credential: BasicAuthCredential

    static func == (lhs: BasicAuthAccount, rhs: BasicAuthAccount) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    init(with authParams: AuthenticationParameters, credential: BasicAuthCredential) {
        self.parameters = authParams
        self.credential = credential
    }

    func persistAuthenticationParameters() {
        parameters.save(for: identifier)
    }

    func persistAuthenticationCredentials() {
        _ = Keychain.set(value: credential.password, forKey: identifier)
    }

    func removeAuthenticationParameters() {
        parameters.remove(for: identifier)
    }

    func removeAuthenticationCredentials() {
        _ = Keychain.delete(forKey: identifier)

    }

    func removeDiskFolder() {
        DiskServices.delete(directory: identifier)
    }

    func getSession(completionHandler: @escaping ((AuthenticationProviderProtocol) -> Void)) {
        let basicAuthenticationProvider = BasicAuthenticationProvider(with: credential)
        completionHandler(basicAuthenticationProvider)
    }

    func logOut(onViewController: UIViewController?, completionHandler: @escaping LogoutHandler) {
        completionHandler(nil)
    }
}
