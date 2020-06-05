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

public typealias AvailableAuthTypeCallback<AuthType> = (Result<AuthType, APIError>) -> Void

class LoginService: Service {
    private (set) var authParameters: AuthSettingsParameters
    private (set) lazy var alfrescoAuth: AlfrescoAuth = {
        let authConfig = authConfiguration()
        return AlfrescoAuth.init(configuration: authConfig)
    }()

    var session: AlfrescoAuthSession?
    var apiClient: APIClientProtocol?

    init(with authenticationParameters: AuthSettingsParameters) {
        self.authParameters = authenticationParameters
    }

    func update(authenticationParameters: AuthSettingsParameters) {
        self.authParameters = authenticationParameters
    }

    func availableAuthType(handler: @escaping AvailableAuthTypeCallback<AvailableAuthType>) {
        let authConfig = authConfiguration()
        alfrescoAuth.update(configuration: authConfig)
        alfrescoAuth.availableAuthType(handler: handler)
    }

    func aimsAuthentication(on viewController: UIViewController, delegate: AlfrescoAuthDelegate) {
        let authConfig = AuthConfiguration(baseUrl: authParameters.fullContentURL,
                                           clientID: authParameters.clientID,
                                           realm: authParameters.realm,
                                           redirectURI: authParameters.redirectURI.encoding())
        alfrescoAuth.update(configuration: authConfig)
        alfrescoAuth.pkceAuth(onViewController: viewController, delegate: delegate)
    }

    func basicAuthentication(username: String, password: String, handler: @escaping ((Result<Bool, NSError>) -> Void)) {
        let basicAuthCredential = BasicAuthCredential(username: username, password: password)
        let basicAuthCredentialProvider = BasicAuthenticationProvider(with: basicAuthCredential)

        apiClient = APIClient(with: String(format: "%@/%@/", authParameters.fullHostnameURL, authParameters.serviceDocument))
        _ = apiClient?.send(GetContentServicesProfile(with: basicAuthCredentialProvider), completion: { (result) in
            switch result {
            case .success(_):
                handler(.success(true))
            case .failure(let error):
                handler(.failure(error as NSError))
            }
        })
    }

    func saveAuthParameters() {
        authParameters.save()
    }

    func resumeExternalUserAgentFlow(with url: URL) -> Bool {
        if session == nil {
            session = AlfrescoAuthSession()
        }
        guard let authSession = session else { return false}
        return authSession.resumeExternalUserAgentFlow(with: url)
    }

    // MARK: - Private

    private func authConfiguration() -> AuthConfiguration {
        let authConfig = AuthConfiguration(baseUrl: authParameters.fullHostnameURL,
                                           clientID: authParameters.clientID,
                                           realm: authParameters.realm,
                                           redirectURI: authParameters.redirectURI.encoding())
        return authConfig
    }

}
