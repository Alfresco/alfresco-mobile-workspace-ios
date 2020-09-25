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
import AlfrescoContent

protocol AIMSAccountDelegate: class {
    func sessionFailedToRefresh(error: APIError)
}

class AIMSAccount: AccountProtocol, Equatable {
    var identifier: String {
        guard let token = session.credential?.accessToken else { return "" }

        do {
            let jwt = try decode(jwt: token)
            let claim = jwt.claim(name: "preferred_username")
            if let preferredusername = claim.string {
                return preferredusername
            }
        } catch {
            AlfrescoLog.error("Unable to decode account token for extracting account identifier")
        }

        return ""
    }
    var apiBasePath: String {
        return "\(session.parameters.fullContentURL)/\(session.parameters.serviceDocument)/\(kAPIPathBase)"
    }
    var session: AIMSSession

    private var ticket: String?
    private var ticketTimer: Timer?

    static func == (lhs: AIMSAccount, rhs: AIMSAccount) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    init(with session: AIMSSession) {
        self.session = session
        session.delegate = self
    }

    func persistAuthenticationParameters() {
        session.parameters.save(for: identifier)
    }

    func persistAuthenticationCredentials() {
        do {
            if let authSession = session.session {
                let credentialData = try JSONEncoder().encode(session.credential)
                let sessionData = try NSKeyedArchiver.archivedData(withRootObject: authSession, requiringSecureCoding: true)

                _ = Keychain.set(value: credentialData, forKey: "\(identifier)-\(String(describing: AlfrescoCredential.self))")
                _ = Keychain.set(value: sessionData, forKey: "\(identifier)-\(String(describing: AlfrescoAuthSession.self))")
            }
        } catch {
            AlfrescoLog.error("Unable to persist credentials to Keychain.")
        }
    }

    func removeAuthenticationParameters() {
        session.parameters.remove(for: identifier)
    }

    func removeAuthenticationCredentials() {
        Keychain.delete(forKey: "\(identifier)-\(String(describing: AlfrescoCredential.self))")
        Keychain.delete(forKey: "\(identifier)-\(String(describing: AlfrescoAuthSession.self))")
    }

    func removeDiskFolder() {
        DiskServices.delete(directory: identifier)
    }

    func unregister() {
        session.invalidateSessionRefresh()
        ticketTimer?.invalidate()
    }

    func registered() {
        createTicket()
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

    func getTicket() -> String? {
        return ticket
    }

    func logOut(onViewController: UIViewController?, completionHandler: @escaping LogoutHandler) {
        guard let viewController = onViewController else { return }
        session.logOut(onViewController: viewController, completionHandler: completionHandler)
    }

    func createTicket() {
        // Validate ticket with existing credentials
        getSession { authenticationprovider in
            let ticketValidationRequestBuilder = AuthenticationAPI.validateTicketWithRequestBuilder()
            ticketValidationRequestBuilder.addHeaders(authenticationprovider.authorizationHeader())

            ticketValidationRequestBuilder.execute { [weak self] (response, error) in
                guard let sSelf = self else { return }

                if error == nil {
                    sSelf.ticketTimer?.invalidate()
                    sSelf.ticket = response?.body?.entry._id
                } else {
                    // Retry again in one minute
                    if sSelf.ticketTimer == nil {
                        sSelf.ticketTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                            sSelf.createTicket()
                        }
                    }
                }
            }
        }
    }
}

extension AIMSAccount: AIMSAccountDelegate {
    func sessionFailedToRefresh(error: APIError) {
        removeAuthenticationCredentials()
        removeDiskFolder()
    }
}
