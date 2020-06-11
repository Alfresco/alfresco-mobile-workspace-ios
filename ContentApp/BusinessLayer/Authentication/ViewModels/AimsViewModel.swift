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
        return authenticationService?.authParameters.hostname ?? ""
    }
}

extension AimsViewModel: AlfrescoAuthDelegate {
    func didReceive(result: Result<AlfrescoCredential, APIError>, session: AlfrescoAuthSession?) {
        switch result {
        case .success(let aimsCredential):
            AlfrescoLog.debug("LoginAIMS with success: \(Mirror.description(for: aimsCredential))")

            if let authSession = session, let accountParams = authenticationService?.authParameters {
                let accountSession = AIMSSession(with: authSession)
                let account = AIMSAccount(with: accountSession, authParams: accountParams, credential: aimsCredential)
                accountService?.register(account: account)
                accountService?.activeAccount = account
            }
            self.delegate?.logInSuccessful()
        case .failure(let error):
            AlfrescoLog.error("Error \(String(describing: authenticationService?.authParameters.contentURL)) login with aims : \(error.localizedDescription)")
            self.delegate?.logInFailed(with: error)
        }
    }

    func didLogOut(result: Result<Int, APIError>) {

    }
}
