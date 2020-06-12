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

protocol AuthenticationServiceProtocol {
    var parameters: AuthenticationParameters { get }

    init(with authenticationParameters: AuthenticationParameters)

    func update(authenticationParameters: AuthenticationParameters)
    func availableAuthType(handler: @escaping AvailableAuthTypeCallback<AvailableAuthType>)
    func aimsAuthentication(on viewController: UIViewController, delegate: AlfrescoAuthDelegate)
    func basicAuthentication(with credentials: BasicAuthCredential, handler: @escaping ((Result<Bool, APIError>) -> Void))
}

public typealias AvailableAuthTypeCallback<AuthType> = (Result<AuthType, APIError>) -> Void

class AuthenticationService: AuthenticationServiceProtocol, Service {
    private (set) var parameters: AuthenticationParameters
    private (set) lazy var alfrescoAuth: AlfrescoAuth = {
        let authConfig = parameters.authenticationConfiguration()
        return AlfrescoAuth.init(configuration: authConfig)
    }()

    var session: AlfrescoAuthSession?
    var apiClient: APIClientProtocol?

    required init(with authenticationParameters: AuthenticationParameters) {
        self.parameters = authenticationParameters
    }

    func update(authenticationParameters: AuthenticationParameters) {
        self.parameters = authenticationParameters
    }

    func availableAuthType(handler: @escaping AvailableAuthTypeCallback<AvailableAuthType>) {
        let authConfig = parameters.authenticationConfiguration()
        alfrescoAuth.update(configuration: authConfig)
        alfrescoAuth.availableAuthType(handler: handler)
    }

    func aimsAuthentication(on viewController: UIViewController, delegate: AlfrescoAuthDelegate) {
        let authConfig = parameters.authenticationConfiguration()
        alfrescoAuth.update(configuration: authConfig)
        alfrescoAuth.pkceAuth(onViewController: viewController, delegate: delegate)
    }

    func basicAuthentication(with credentials: BasicAuthCredential, handler: @escaping ((Result<Bool, APIError>) -> Void)) {
        let basicAuthCredentialProvider = BasicAuthenticationProvider(with: credentials)

        apiClient = APIClient(with: String(format: "%@/%@/", parameters.fullHostnameURL, parameters.serviceDocument))
        _ = apiClient?.send(GetContentServicesProfile(with: basicAuthCredentialProvider), completion: { (result) in
            switch result {
            case .success(_):
                handler(.success(true))
            case .failure(let error):
                handler(.failure(error))
            }
        })
    }

    func saveAuthParameters() {
        parameters.save()
    }

    func resumeExternalUserAgentFlow(with url: URL) -> Bool {
        if session == nil {
            session = AlfrescoAuthSession()
        }
        guard let authSession = session else { return false}
        return authSession.resumeExternalUserAgentFlow(with: url)
    }
}
