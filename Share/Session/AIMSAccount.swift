//
// Copyright (C) 2005-2022 Alfresco Software Limited.
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
import Foundation
import AlfrescoAuth
import AlfrescoContent

protocol AIMSAccountDelegate: AnyObject {
    func didReSignIn(check oldAccountIdentifier: String)
}

class AIMSAccount: AccountProtocol, Equatable {
    var identifier: String {
        return session.identifier
    }
    var apiBasePath: String {
        return "\(session.parameters.fullContentURL)/\(session.parameters.path)/\(APIConstants.Path.base)"
    }
    var session: AIMSSession

    var ticket: String?
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
        session.persistAuthenticationCredentials()
    }

    func removeAuthenticationParameters() {
        session.parameters.remove(for: identifier)
    }

    func removeAuthenticationCredentials() {
        Keychain.delete(forKey: "\(identifier)-\(String(describing: AlfrescoCredential.self))")
        Keychain.delete(forKey: "\(identifier)-\(String(describing: AlfrescoAuthSession.self))")
    }

    func removeDiskFolder() {
        let path = DiskService.documentsDirectoryPath(for: identifier)
        _ = DiskService.delete(itemAtPath: path)
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

    func reSignIn(onViewController: UIViewController?) {
        guard let viewController = onViewController else { return }
        session.reSignIn(onViewController: viewController)
    }

    func createTicket() {
        getSession { [weak self] authenticationprovider in
            guard let sSelf = self else { return }
            let ticketValidationRequestBuilder = AuthenticationAPI.validateTicketWithRequestBuilder()
            ticketValidationRequestBuilder.addHeaders(authenticationprovider.authorizationHeader())

            ticketValidationRequestBuilder.execute { (response, error) in

                if error == nil {
                    sSelf.ticketTimer?.invalidate()
                    sSelf.ticket = response?.body?.entry._id
                } else {
                    // Retry again in one minute
                    if sSelf.ticketTimer == nil {
                        sSelf.ticketTimer = Timer.scheduledTimer(withTimeInterval: 60,
                                                                 repeats: true) { _ in
                            sSelf.createTicket()
                        }
                    }
                }
            }
        }
    }
}

extension AIMSAccount: AIMSAccountDelegate {
    func didReSignIn(check oldAccountIdentifier: String) {
        createTicket()
        ProfileService.featchPersonalFilesID()

        if oldAccountIdentifier != identifier && !oldAccountIdentifier.isEmpty {
            UserDefaultsModel.set(value: identifier, for: KeyConstants.Save.activeAccountIdentifier)
            session.parameters.save(for: identifier)

            let path = DiskService.documentsDirectoryPath(for: oldAccountIdentifier)
            _ = DiskService.delete(itemAtPath: path)

            Keychain.delete(forKey: "\(oldAccountIdentifier)-\(String(describing: AlfrescoCredential.self))")
            Keychain.delete(forKey: "\(oldAccountIdentifier)-\(String(describing: AlfrescoAuthSession.self))")

            UserProfile.removeUserProfile(forAccountIdentifier: identifier)

            session.parameters.remove(for: oldAccountIdentifier)
        }
        
        UserDefaultsModel.set(value: true, for: KeyConstants.AppGroup.loggedInFromAppExtension)

        let notification = NSNotification.Name(rawValue: KeyConstants.Notification.reSignin)
        NotificationCenter.default.post(name: notification,
                                        object: nil,
                                        userInfo: nil)
    }
}
