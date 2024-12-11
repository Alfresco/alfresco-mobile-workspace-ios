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

protocol ConnectViewModelDelegate: AnyObject {
    func authServiceAvailable(for authType: AvailableAuthType)
    func authServiceUnavailable(with error: APIError)
    func authServiceByPass()
}

class ConnectViewModel {
    weak var delegate: ConnectViewModelDelegate?
    var authenticationService: AuthenticationService?
    var aimsViewModel: AimsViewModel?

    init(with loginService: AuthenticationService?) {
        authenticationService = loginService
    }

    func availableAuthType(for url: String, in viewController: UIViewController) {
        let authParameters = AuthenticationParameters.parameters()
        authParameters.hostname = url
        authenticationService?.update(authenticationParameters: authParameters)
        authenticationService?.availableAuthTypeServer(on: authParameters.fullHostnameURL, handler: { [weak self] (result) in
            guard let sSelf = self else { return }
            switch result {
            case .success(let appConfigDetails):
                sSelf.updateAuthParameter(appConfigDetails: appConfigDetails, authParameters: authParameters)
                sSelf.availableAimsAuthType(for: url, in: viewController)
            case .failure(let error):
                AlfrescoLog.error("Error \(url) auth_type: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    sSelf.delegate?.authServiceUnavailable(with: error)
                }
            }
        })
    }
    
    private func updateAuthParameter(appConfigDetails: AppConfigDetails, authParameters: AuthenticationParameters) {
        
        if let authType = appConfigDetails.oauth2?.authType, authType == "auth0" {
            authParameters.authType = .auth0
            authParameters.realm = appConfigDetails.oauth2?.audience ?? ""
            authParameters.clientID = appConfigDetails.oauth2?.clientId ?? ""
            authParameters.clientSecret = appConfigDetails.oauth2?.secret ?? ""
            let host = appConfigDetails.oauth2?.host ?? ""
            authParameters.auth0BaseUrl = host
            let auth0RedirectUri = String(format: "com.alfresco.contentapp://%@/ios/com.alfresco.contentapp/callback", host.replacingOccurrences(of: "https://", with: ""))
            authParameters.redirectURI = auth0RedirectUri
            
        } else {
            authParameters.authType = .aimsAuth
            authParameters.realm = "alfresco"
            authParameters.clientID = "alfresco-ios-acs-app"
            authParameters.clientSecret = ""
            authParameters.redirectURI = "iosacsapp://aims/auth"
        }
        authenticationService?.update(authenticationParameters: authParameters)
        
    }
    
    private func availableAimsAuthType(for url: String, in viewController: UIViewController) {
        authenticationService?.availableAuthType(handler: { [weak self] (result) in
            guard let sSelf = self else { return }
            switch result {
            case .success(let authType):
                sSelf.authenticationService?.saveAuthParameters()
                sSelf.authenticationService?.isContentServicesAvailable(on: AuthenticationParameters.parameters().fullHostnameURL,
                                                                        handler: { (result) in
                    switch result {
                    case .success(let isVersionOverMinium):
                        sSelf.contentService(available: isVersionOverMinium,
                                             authType: authType,
                                             url: url,
                                             in: viewController)
                    case .failure(let error):
                        AlfrescoLog.error(error)
                        sSelf.contentService(available: false,
                                             authType: authType,
                                             url: url,
                                             in: viewController)
                    }
                })
            case .failure(let error):
                AlfrescoLog.error("Error \(url) auth_type: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    sSelf.delegate?.authServiceUnavailable(with: error)
                }
            }
        })
    }
    
    func contentService(available: Bool,
                        authType: AvailableAuthType,
                        url: String,
                        in viewController: UIViewController) {
        switch authType {
        case .aimsAuth, .auth0:
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                if available {
                    sSelf.delegate?.authServiceByPass()
                    sSelf.aimsViewModel?.loginByPass(repository: url, in: viewController)
                } else {
                    sSelf.delegate?.authServiceAvailable(for: authType)
                }
            }
        default:
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                if available {
                    sSelf.delegate?.authServiceAvailable(for: authType)
                } else {
                    sSelf.delegate?.authServiceUnavailable(with: APIError(domain: ""))
                }
            }
        }
    }
    
    func apiToCheckServerDetails(on stringURL: String, handler: @escaping ((Result<Bool, APIError>) -> Void)) {
        self.authenticationService?.isFavAllowedOnMultSelect(on: stringURL, handler: { (result) in
            handler(result)
        })
    }
}
