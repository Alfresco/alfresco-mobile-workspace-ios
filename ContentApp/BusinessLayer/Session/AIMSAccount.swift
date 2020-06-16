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
import JWTDecode

class AIMSAccount: AccountProtocol, Equatable {
    var identifier: String {
        guard let token = session.credential?.accessToken else { return "" }

        do {
            let jwt = try decode(jwt: token)
            let claim = jwt.claim(name: "email")
            if let email = claim.string {
                return email
            }
        } catch {
            AlfrescoLog.error("Unable to decode account token for extracting account identifier")
        }

        return ""
    }
    var session: AIMSSession

    static func == (lhs: AIMSAccount, rhs: AIMSAccount) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    init(with session: AIMSSession) {
        self.session = session
    }

    func persistAuthenticationParameters() {
        session.parameters.save(for: identifier)
    }

    func removeAuthenticationParameters() {
        session.parameters.remove(for: identifier)
    }

    func getSession(completionHandler: @escaping ((AuthenticationProviderProtocol) -> Void)) {
        // Check if existing credentials are valid and return them if true
        if let credential = session.credential {
            let aimsAuthenticationProvider = AIMSAuthenticationProvider(with: credential)

            if aimsAuthenticationProvider.areCredentialsValid() {
                completionHandler(aimsAuthenticationProvider)
            } else { // Otherwise refresh the session
                session.refreshSession { (credential) in
                    let aimsAuthenticationProvider = AIMSAuthenticationProvider(with: credential)
                    completionHandler(aimsAuthenticationProvider)
                }
            }
        }
    }

    func logOut(onViewController: UIViewController?, completionHandler: @escaping LogoutHandler) {
        guard let viewController = onViewController else { return }
        session.logOut(onViewController: viewController, completionHandler: completionHandler)
    }
}
