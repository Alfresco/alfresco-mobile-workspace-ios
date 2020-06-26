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
import AlfrescoCore

protocol ConnectScreenCoordinatorDelegate: class {
    func showAdvancedSettingsScreen()
    func showBasicAuthScreen()
    func showAimsScreen()
    func showNeedHelpSheet()
}

class ConnectScreenCoordinator: Coordinator {
    private let presenter: SplashViewController
    private var connectViewController: ConnectViewController?
    private var containerViewNavigationController: UINavigationController?
    private var advancedSettingsCoordinator: AdvancedSettingsScreenCoordinator?
    private var basicAuthCoordinator: BasicAuthScreenCoordinator?
    private var aimsCoordinator: AimsScreenCoordinator?
    private var needHelpCoordinator: NeedHelpCoordinator?
    private var authenticationError: APIError?

    init(with presenter: SplashViewController, authenticationError: APIError? = nil) {
        self.presenter = presenter
        self.authenticationError = authenticationError
    }

    func start() {
        let connectViewController = ConnectViewController.instantiateViewController()
        connectViewController.splashScreenDelegate = presenter
        connectViewController.connectScreenCoordinatorDelegate = self
        connectViewController.viewModel = ConnectViewModel(with: self.serviceRepository.service(of: AuthenticationService.serviceIdentifier) as? AuthenticationService)
        connectViewController.themingService = self.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        self.connectViewController = connectViewController

        let containerViewNavigationController = UINavigationController(rootViewController: connectViewController)
        presenter.addChild(containerViewNavigationController)
        containerViewNavigationController.view.frame = CGRect(x: 0, y: 0, width: presenter.containerView.frame.size.width, height: presenter.containerView.frame.size.height)
        presenter.containerView.addSubview(containerViewNavigationController.view)
        containerViewNavigationController.didMove(toParent: presenter)
        self.containerViewNavigationController = containerViewNavigationController

        if authenticationError != nil {
            connectViewController.showError(message: LocalizationConstants.Errors.noLongerAuthenticated)
        }
    }

    func popViewController() {
        self.containerViewNavigationController?.popViewController(animated: kPushAnimation)
    }
}

extension ConnectScreenCoordinator: ConnectScreenCoordinatorDelegate {
    func showAdvancedSettingsScreen() {
        if let containerViewNavigationController = self.containerViewNavigationController {
            let advancedSettingsCoordinator = AdvancedSettingsScreenCoordinator(with: containerViewNavigationController)
            advancedSettingsCoordinator.start()
            self.advancedSettingsCoordinator = advancedSettingsCoordinator
        }
    }

    func showBasicAuthScreen() {
        if let containerViewNavigationController = self.containerViewNavigationController {
            let basicAuthCoordinator = BasicAuthScreenCoordinator(with: containerViewNavigationController, splashScreen: self.presenter)
            basicAuthCoordinator.start()
            self.basicAuthCoordinator = basicAuthCoordinator
        }
    }

    func showAimsScreen() {
        if let containerViewNavigationController = self.containerViewNavigationController {
            let aimsCoordinator = AimsScreenCoordinator(with: containerViewNavigationController, splashScreen: self.presenter)
            aimsCoordinator.start()
            self.aimsCoordinator = aimsCoordinator
        }
    }

    func showNeedHelpSheet() {
        if let containerViewNavigationController = self.containerViewNavigationController {
            let needHelpCoordinator = NeedHelpCoordinator(with: containerViewNavigationController, model: NeedHelpConnectScreenModel())
            needHelpCoordinator.start()
            self.needHelpCoordinator = needHelpCoordinator
        }
    }
}
