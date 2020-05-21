//
//  ConnectPresenter.swift
//  ContentApp
//
//  Created by Florin Baincescu on 21/05/2020.
//  Copyright © 2020 Florin Baincescu. All rights reserved.
//

import Foundation
import AlfrescoAuth
import os.log

protocol ConnectViewModelDelegate: class {
    func authServiceAvailable(for authType:AvailableAuthType)
    func authServiceUnavailable(with error:APIError)
}

class ConnectViewModel {
    weak var delegate: ConnectViewModelDelegate?
    var authenticationService: LoginService?
    
    func availableAuthType(for url: String) {
        let authParameters = AuthSettingsParameters.parameters()
        authParameters.hostname = url
        authenticationService = LoginService(with: authParameters)
        authenticationService?.availableAuthType(handler: { [weak self] (result) in
            guard let sSelf = self else { return }
            switch result {
            case .success(let authType):
                switch authType {
                case .aimsAuth:
                    AlfrescoLog.debug("URL \(url) has authentication type AIMS.")
                case .basicAuth:
                    AlfrescoLog.debug("URL \(url) has authentication type BASIC.")
                }
                authParameters.save()
                sSelf.delegate?.authServiceAvailable(for: authType)
            case .failure(let error):
                AlfrescoLog.error("Error \(url) auth_type: \(error.localizedDescription)")
                sSelf.delegate?.authServiceUnavailable(with: error)
            }
        })
    }
}
