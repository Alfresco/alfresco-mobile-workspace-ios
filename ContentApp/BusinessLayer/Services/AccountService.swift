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

protocol AccountServiceProtocol {
    /// Array of registered accounts.
    var accounts: [AccountProtocol] { get }
    /// Account on which requests will be executed.
    var activeAccount: AccountProtocol? { get set }

    /// Registers an account and persists authentication related parameters.
    /// - Parameter account: Account to be registered
    func register(account: AccountProtocol)

    /**
     Creates for current account an authentication ticket used for convenient content fetching.

     - SeeAlso:
       [AuthenticationAPI](https://api-explorer.alfresco.com/api-explorer/#/authentication)
    */
    func createTicketForCurrentAccount()

    /// Removes an account but it doesn not automatically log out the user from it.
    /// - Parameter account: Account to be removed
    func unregister(account: AccountProtocol)

    /// Returns a valid session, whether that's being a cached one or it needs to be recreated.
    /// - Parameter completionHandler: Authentication provider containing credentials
    func getSessionForCurrentAccount(completionHandler: @escaping (AuthenticationProviderProtocol) -> Void)

    /// Logs out of an account. Does not automatically unregisters the account
    /// - Parameters:
    ///   - account: Account from which to log out. If it's the current account, a substitute will have to be provided manually.
    ///   - viewController: Optional view controller on which to present optional log out context for some accounts
    ///   - completionHandler: Success or failure of the operation
    func logOutFromAccount(account: AccountProtocol, viewController: UIViewController?, completionHandler: @escaping LogoutHandler)

    /// Conveniece method for logging out of the current account.
    /// - Parameters:
    ///   - viewController: Optional view controller on which to present optional log out context for some accounts
    ///   - completionHandler: Success or failure of the operation
    func logOutFromCurrentAccount(viewController: UIViewController?, completionHandler: @escaping LogoutHandler)
}

class AccountService: AccountServiceProtocol, Service {

    private var connectivityService: ConnectivityService?
    private var kvoConnectivity: NSKeyValueObservation?
    private(set) var accounts: [AccountProtocol] = []

    var activeAccount: AccountProtocol? {
        didSet {
            if let activeAccountIdentifier = activeAccount?.identifier {
                UserDefaultsModel.set(value: activeAccountIdentifier, for: KeyConstants.Save.activeAccountIdentifier)
            } else {
                UserDefaultsModel.remove(forKey: KeyConstants.Save.activeAccountIdentifier)
            }
        }
    }

    init(connectivityService: ConnectivityService) {
        self.connectivityService = connectivityService
        self.observeConnectivity()
    }

    deinit {
        kvoConnectivity?.invalidate()
    }

    func register(account: AccountProtocol) {
        accounts.append(account)
        account.persistAuthenticationParameters()
        account.persistAuthenticationCredentials()

        if connectivityService?.hasInternetConnection() == true {
            account.registered()
        }
    }

    func createTicketForCurrentAccount() {
        guard connectivityService?.hasInternetConnection() == true else { return }
        activeAccount?.createTicket()
    }

    func getSessionForCurrentAccount(completionHandler: @escaping ((AuthenticationProviderProtocol) -> Void)) {
        guard connectivityService?.hasInternetConnection() == true else { return }

        OperationQueueService.worker.async { [weak self] in
            guard let sSelf = self else { return }

            sSelf.activeAccount?.getSession(completionHandler: { (authenticationProivder) in
                completionHandler(authenticationProivder)
            })
        }
    }

    func logOutFromAccount(account: AccountProtocol, viewController: UIViewController?, completionHandler: @escaping LogoutHandler) {
        OperationQueueService.main.async {
            account.logOut(onViewController: viewController, completionHandler: { error in
                completionHandler(error)
            })
        }
    }

    func logOutFromCurrentAccount(viewController: UIViewController?, completionHandler: @escaping LogoutHandler) {
        guard connectivityService?.hasInternetConnection() == true else { return }
        if let account = activeAccount {
            logOutFromAccount(account: account, viewController: viewController) { [weak self] error in
                guard let sSelf = self else { return }
                completionHandler(error)
                if error == nil {
                    sSelf.activeAccount = nil
                }
            }
        }
    }

    func unregister(account: AccountProtocol) {
        if let index = accounts.firstIndex(where: { account === $0 }) {
            if account.identifier == activeAccount?.identifier {
                UserDefaultsModel.remove(forKey: KeyConstants.Save.activeAccountIdentifier)
            }
            account.unregister()
            accounts.remove(at: index)
        }
    }

    func delete(account: AccountProtocol) {
        if let index = accounts.firstIndex(where: { account === $0 }) {
            if account.identifier == activeAccount?.identifier {
                UserDefaultsModel.remove(forKey: KeyConstants.Save.activeAccountIdentifier)
            }
            account.unregister()

            account.removeDiskFolder()
            account.removeAuthenticationParameters()
            account.removeAuthenticationCredentials()

            let listNodeDataAccessor = ListNodeDataAccessor()
            listNodeDataAccessor.removeAllNodes()

            UserProfile.removeUserProfile(forAccountIdentifier: identifier)
            UserDefaultsModel.remove(forKey: APIConstants.latestServerVersion)
            accounts.remove(at: index)
        }
    }

    // MARK: Private Helpers

    private func observeConnectivity() {
        kvoConnectivity = connectivityService?.observe(\.status,
                                                       options: [.new],
                                                       changeHandler: { [weak self] (_, _) in
                                                        guard let sSelf = self else { return }
                                                        sSelf.handleConnectivity()
                                                       })
    }

    private func handleConnectivity() {
        if connectivityService?.hasInternetConnection() == false {
            activeAccount?.unregister()
        } else {
            activeAccount?.registered()
        }
    }
}
