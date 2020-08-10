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
import AlfrescoContent

protocol BasicAuthViewModelDelegate: class {
    func logInFailed(with error: APIError)
    func logInWarning(with message: String)
    func logInSuccessful()
}

class BasicAuthViewModel {
    weak var delegate: BasicAuthViewModelDelegate?
    var authenticationService: AuthenticationService?
    var accountService: AccountServiceProtocol?

    init(with authenticationService: AuthenticationService?, accountService: AccountServiceProtocol?) {
        self.authenticationService = authenticationService
        self.accountService = accountService
    }

    func authenticate(username: String, password: String) {
        if authenticationService?.parameters.serviceDocument == "" {
            self.delegate?.logInWarning(with: LocalizationConstants.Errors.serviceDocumentEmpty)
            return
        }
        let basicAuthCredential = BasicAuthCredential(username: username, password: password)
        authenticationService?.basicAuthentication(with: basicAuthCredential, handler: { [weak self] (result) in
            guard let sSelf = self else { return }
            switch result {
            case .success:
                if let accountParams = sSelf.authenticationService?.parameters {
                    let account = BasicAuthAccount(with: accountParams, credential: basicAuthCredential)
                    sSelf.accountService?.register(account: account)
                    sSelf.accountService?.activeAccount = account

                    AlfrescoContentAPI.basePath = account.apiBasePath
                }

                sSelf.fetchProfileInformation()
            case .failure(let error):
                AlfrescoLog.error("Error basic-auth: \(error)")
                DispatchQueue.main.async {
                    sSelf.delegate?.logInFailed(with: error)
                }
            }
        })
    }

    func hostname() -> String {
        return authenticationService?.parameters.hostname ?? ""
    }

    private func fetchProfileInformation() {
        accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            PeopleAPI.getPerson(personId: kAPIPathMe) { [weak self] (personEntry, error) in
                guard let sSelf = self else { return }
                if let error = error {
                    AlfrescoLog.error(error)
                    DispatchQueue.main.async {
                        sSelf.delegate?.logInFailed(with: APIError(domain: "", message: error.localizedDescription, error: error))
                    }
                    if let activeAccount = sSelf.accountService?.activeAccount {
                        activeAccount.removeAuthenticationCredentials()
                        sSelf.accountService?.unregister(account: activeAccount)
                    }
                } else {
                    if let person = personEntry?.entry {
                        UserProfile.persistUserProfile(person: person)
                        ProfileService.featchPersonalFilesID()
                        DispatchQueue.main.async {
                            sSelf.delegate?.logInSuccessful()
                        }
                    }
                }
            }
        })
    }
}
