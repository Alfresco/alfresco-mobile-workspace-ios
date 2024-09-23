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
import AlfrescoContent

protocol AimsViewModelDelegate: AnyObject {
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
        authenticationService?.isContentServicesAvailable(on: authParameters.fullContentURL,
                                                          handler: { [weak self] (result) in
            guard let sSelf = self else { return }
            switch result {
            case .success(let isVersionOverMinium):
                guard isVersionOverMinium else {
                    DispatchQueue.main.async { [weak self] in
                        guard let sSelf = self else { return }
                        sSelf.delegate?.logInFailed(with: APIError(domain: ""))
                    }
                    return
                }
                sSelf.authenticationService?.update(authenticationParameters: authParameters)
                sSelf.authenticationService?.aimsAuthentication(on: viewController, delegate: sSelf)
            case .failure(let error):
                AlfrescoLog.error(error)
                DispatchQueue.main.async { [weak self] in
                    guard let sSelf = self else { return }
                    sSelf.delegate?.logInFailed(with: error)
                }
            }
        })
    }

    func loginByPass(repository: String, in viewController: UIViewController) {
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
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            PeopleAPI.getPerson(personId: APIConstants.me) { [weak self] (personEntry, error) in
                guard let sSelf = self else { return }
                if let error = error {
                    AlfrescoLog.error(error)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
                        ProfileService.fetchAPSProfileDetails()
                        
                        DispatchQueue.main.async {
                            sSelf.delegate?.logInSuccessful()
                        }
                    }
                }
            }
        })
    }
}

extension AimsViewModel: AlfrescoAuthDelegate {
    func didReceive(result: Result<AlfrescoCredential?, APIError>, session: AlfrescoAuthSession?) {
        switch result {
        case .success(let aimsCredential):
            guard let aimsCredential = aimsCredential  else { return }
            AlfrescoLog.debug("LoginAIMS with success: \(Mirror.description(for: aimsCredential))")

            if let authSession = session, let accountParams = authenticationService?.parameters {
                let accountSession = AIMSSession(with: authSession,
                                                 parameters: accountParams,
                                                 credential: aimsCredential)
                let account = AIMSAccount(with: accountSession)
                AlfrescoContentAPI.hostname = account.apiHostName
                AlfrescoContentAPI.basePath = account.apiBasePath
                AlfrescoProcessAPI.basePath = account.processAPIBasePath

                accountService?.register(account: account)
                accountService?.activeAccount = account
                MobileConfigManager.shared.fetchMenuOption(accountService: accountService)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.fetchProfileInformation()
                }
            }
        case .failure(let error):
            let contentURL = authenticationService?.parameters.contentURL
            AlfrescoLog.error("Error \(String(describing: contentURL)) login with aims : \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                sSelf.delegate?.logInFailed(with: error)
            }
        }
    }

    func didLogOut(result: Result<Int, APIError>, session: AlfrescoAuthSession?) {
    }
}
