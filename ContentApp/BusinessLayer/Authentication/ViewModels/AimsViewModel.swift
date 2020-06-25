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
import UIKit
import AlfrescoAuth
import AlfrescoContentServices

protocol AimsViewModelDelegate: class {
    func logInFailed(with error: APIError)
    func logInSuccessful()
}

class AimsViewModel {
    weak var delegate: AimsViewModelDelegate?
    var authenticationService: AuthenticationServiceProtocol?
    var accountService: AccountServiceProtocol?

    init(with authenticationService: AuthenticationServiceProtocol?, accountService: AccountServiceProtocol?) {
        self.authenticationService = authenticationService
        self.accountService = accountService
    }

    func login(repository: String, in viewController: UIViewController) {
        let authParameters = AuthenticationParameters.parameters()
        authParameters.contentURL = repository
        authenticationService?.update(authenticationParameters: authParameters)
        authenticationService?.aimsAuthentication(on: viewController, delegate: self)
    }

    func hostname() -> String {
        return authenticationService?.parameters.hostname ?? ""
    }

    private func fetchProfileInformation() {
        accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentServicesAPI.customHeaders = authenticationProvider.authorizationHeader()
            PeopleAPI.getPerson(personId: kAPIPathMe) { [weak self] (personEntry, error) in
                guard let sSelf = self else { return }
                if let error = error {
                    AlfrescoLog.error(error)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        sSelf.delegate?.logInFailed(with: APIError(domain: "", message: error.localizedDescription, error: error))
                    }
                    if let activeAccount = sSelf.accountService?.activeAccount {
                        activeAccount.removeDiskFolder()
                        activeAccount.removeAuthenticationCredentials()
                        sSelf.accountService?.unregister(account: activeAccount)
                    }
                } else {
                    if let person = personEntry?.entry {
                        sSelf.persistUserProfile(person: person)
                        DispatchQueue.main.async {
                            sSelf.delegate?.logInSuccessful()
                        }
                    }
                }
            }
        })
    }

    private func persistUserProfile(person: Person) {
        guard let identifier = accountService?.activeAccount?.identifier else { return }
        var profileName = person.firstName
        if let lastName = person.lastName {
            profileName = "\(person) \(lastName)"
        }
        if let displayName = person.displayName {
            profileName = displayName
        }

        let defaults = UserDefaults.standard
        defaults.set(profileName, forKey: "\(identifier)-\(kSaveDiplayProfileName)")
        defaults.set(person.email, forKey: "\(identifier)-\(kSaveEmailProfile)")
        defaults.synchronize()
    }
}

extension AimsViewModel: AlfrescoAuthDelegate {
    func didReceive(result: Result<AlfrescoCredential, APIError>, session: AlfrescoAuthSession?) {
        switch result {
        case .success(let aimsCredential):
            AlfrescoLog.debug("LoginAIMS with success: \(Mirror.description(for: aimsCredential))")

            if let authSession = session, let accountParams = authenticationService?.parameters {
                let accountSession = AIMSSession(with: authSession, parameters: accountParams, credential: aimsCredential)
                let account = AIMSAccount(with: accountSession)
                accountService?.register(account: account)
                accountService?.activeAccount = account

                AlfrescoContentServicesAPI.basePath = account.apiBasePath
                self.fetchProfileInformation()
            }
        case .failure(let error):
            AlfrescoLog.error("Error \(String(describing: authenticationService?.parameters.contentURL)) login with aims : \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                sSelf.delegate?.logInFailed(with: error)
            }
        }
    }

    func didLogOut(result: Result<Int, APIError>) {

    }
}
