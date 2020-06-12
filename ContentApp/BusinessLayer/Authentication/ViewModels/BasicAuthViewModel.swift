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
                    let accountSession = BasicSession()
                    let account = BasicAuthAccount(with: accountSession, authParams: accountParams, credential: basicAuthCredential)
                    sSelf.accountService?.register(account: account)
                    sSelf.accountService?.activeAccount = account
                }

                sSelf.delegate?.logInSuccessful()
            case .failure(let error):
                AlfrescoLog.error("Error basic-auth: \(error)")
                sSelf.delegate?.logInFailed(with: error)
            }
        })
    }

    func hostname() -> String {
        return authenticationService?.parameters.hostname ?? ""
    }
}
