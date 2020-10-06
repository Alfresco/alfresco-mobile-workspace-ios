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
import AlfrescoContent

class BasicAuthAccount: AccountProtocol, Equatable {
    var identifier: String {
        return credential.username
    }
    var apiBasePath: String {
        return "\(parameters.fullHostnameURL)/\(parameters.serviceDocument)/\(kAPIPathBase)"
    }
    var parameters: AuthenticationParameters
    var credential: BasicAuthCredential

    private var ticket: String?
    private var ticketTimer: Timer?

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
        Keychain.delete(forKey: identifier)
    }

    func removeDiskFolder() {
        DiskServices.delete(directory: identifier)
    }

    func unregister() {
        ticketTimer?.invalidate()
    }

    func registered() {
        createTicket()
    }

    func getSession(completionHandler: @escaping ((AuthenticationProviderProtocol) -> Void)) {
        let basicAuthenticationProvider = BasicAuthenticationProvider(with: credential)
        completionHandler(basicAuthenticationProvider)
    }

    func getTicket() -> String? {
        return ticket
    }

    func logOut(onViewController: UIViewController?, completionHandler: @escaping LogoutHandler) {
        completionHandler(nil)
    }

    func relogIn(onViewController: UIViewController?) {
    }

    func createTicket() {
        let ticketBody = TicketBody(userId: credential.username, password: credential.password)
        AuthenticationAPI.createTicket(ticketBodyCreate: ticketBody) { [weak self] (ticket, error) in
            guard let sSelf = self else { return }

            if error == nil {
                sSelf.ticket = ticket?.entry._id
                sSelf.ticketTimer?.invalidate()
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
