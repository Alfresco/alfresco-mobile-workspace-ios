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
    var accounts: [AccountProtocol]? { get }
    var activeAccount: AccountProtocol? { get set }

    func register(account: AccountProtocol)
    func unregister(account: AccountProtocol)
    func getSessionForCurrentAccount(completionHandler: @escaping (AuthenticationProviderProtocol) -> Void)
    func logOutFromAccount(account: AccountProtocol, viewController: UIViewController?, completionHandler: @escaping LogoutHandler)
    func logOutFromCurrentAccount(viewController: UIViewController?, completionHandler: @escaping LogoutHandler)
}

class AccountService: AccountServiceProtocol, Service {
    private (set) var accounts: [AccountProtocol]? = []
    var activeAccount: AccountProtocol?

    func register(account: AccountProtocol) {
        accounts?.append(account)
        account.persistAuthenticationParameters()
    }

    func getSessionForCurrentAccount(completionHandler: @escaping ((AuthenticationProviderProtocol) -> Void)) {
        activeAccount?.getSession(completionHandler: { (authenticationProivder) in
            completionHandler(authenticationProivder)
        })
    }

    func logOutFromAccount(account: AccountProtocol, viewController: UIViewController?, completionHandler: @escaping LogoutHandler) {
        account.logOut(onViewController: viewController, completionHandler: { error in
            completionHandler(error)
        })
    }

    func logOutFromCurrentAccount(viewController: UIViewController?, completionHandler: @escaping LogoutHandler) {
        if let account = activeAccount {
            logOutFromAccount(account: account, viewController: viewController) { error in
                completionHandler(error)
            }
        }

        activeAccount = nil
    }

    func unregister(account: AccountProtocol) {
        if let index = accounts?.firstIndex(where: { account === $0 }) {
            accounts?.remove(at: index)
        }
    }
}
