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
import AlfrescoAuth
import AlfrescoContent
import FastCoding

protocol SplashScreenCoordinatorDelegate: AnyObject {
    func showLoginContainerView()
    func showAdvancedSettingsScreen()
    func popViewControllerFromContainer()
}

class SplashScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var splashScreenViewController: SplashViewController?
    private var advancedSettingsCoordinator: AdvancedSettingsScreenCoordinator?
    private var connectScreenCoordinator: ConnectScreenCoordinator?
    private var tabBarScreenCoordinator: TabBarScreenCoordinator?
    private var authenticationError: APIError?

    init(with presenter: UINavigationController, authenticationError: APIError? = nil) {
        self.presenter = presenter
        self.authenticationError = authenticationError
    }

    func start() {
        let viewController = SplashViewController.instantiateViewController()

        viewController.coordinatorDelegate = self
        viewController.coordinatorServices = coordinatorServices
        splashScreenViewController = viewController
        presenter.pushViewController(viewController, animated: true)
        connectScreenCoordinator = ConnectScreenCoordinator(with: viewController, authenticationError: authenticationError)
    }
}

extension SplashScreenCoordinator: SplashScreenCoordinatorDelegate {
    func popViewControllerFromContainer() {
        self.connectScreenCoordinator?.popViewController()
    }

    func showLoginContainerView() {
        if let activeAccountIdentifier = UserDefaultsModel.value(for: KeyConstants.Save.activeAccountIdentifier) as? String {
            let parameters = AuthenticationParameters.parameters(for: activeAccountIdentifier)

            // Check account type whether it's Basic or AIMS
            if let activeAccountPassword = Keychain.string(forKey: activeAccountIdentifier) {
                let basicAuthCredential = BasicAuthCredential(username: activeAccountIdentifier, password: activeAccountPassword)
                let account = BasicAuthAccount(with: parameters, credential: basicAuthCredential)

                registerAndPresent(account: account)
            } else if let activeAccountSessionData = Keychain.data(forKey: "\(activeAccountIdentifier)-\(String(describing: AlfrescoAuthSession.self))"),
                let activeAccountCredentialData = Keychain.data(forKey: "\(activeAccountIdentifier)-\(String(describing: AlfrescoCredential.self))") {

                do {
                    let decoder = JSONDecoder()

                    if let aimsSession = FastCoder.object(with: activeAccountSessionData) as? AlfrescoAuthSession {
                        let aimsCredential = try decoder.decode(AlfrescoCredential.self, from: activeAccountCredentialData)

                        let accountSession = AIMSSession(with: aimsSession, parameters: parameters, credential: aimsCredential)
                        let account = AIMSAccount(with: accountSession)

                        registerAndPresent(account: account)
                    }
                } catch {
                    AlfrescoLog.error("Unable to deserialize session information")
                }
            } else {
                connectScreenCoordinator?.start()
            }
        } else {
            connectScreenCoordinator?.start()
        }
    }

    func showAdvancedSettingsScreen() {
        let advancedSettingsCoordinator = AdvancedSettingsScreenCoordinator(with: presenter)
        advancedSettingsCoordinator.start()
        self.advancedSettingsCoordinator = advancedSettingsCoordinator
    }

    private func registerAndPresent(account: AccountProtocol) {
        AlfrescoContentAPI.basePath = account.apiBasePath
        AlfrescoProcessAPI.basePath = account.processAPIBasePath
        AlfrescoContentAPI.hostname = account.apiHostName
        accountService?.register(account: account)
        accountService?.activeAccount = account

        tabBarScreenCoordinator = TabBarScreenCoordinator(with: presenter)
        tabBarScreenCoordinator?.start()
        MobileConfigManager.shared.fetchMenuOption(accountService: accountService)
        appDelegate()?.startSyncOperation()
    }
}
