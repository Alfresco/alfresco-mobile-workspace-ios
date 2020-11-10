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
    func showApplicationTabBar()
}

class ConnectScreenCoordinator: Coordinator {
    private let presenter: SplashViewController
    private var connectViewController: ConnectViewController?
    private var containerViewNavigationController: UINavigationController?
    private var advancedSettingsCoordinator: AdvancedSettingsScreenCoordinator?
    private var basicAuthCoordinator: BasicAuthScreenCoordinator?
    private var aimsCoordinator: AimsScreenCoordinator?
    private var needHelpCoordinator: NeedHelpCoordinator?
    private var tabBarCoordinator: TabBarScreenCoordinator?
    private var authenticationError: APIError?

    init(with presenter: SplashViewController, authenticationError: APIError? = nil) {
        self.presenter = presenter
        self.authenticationError = authenticationError
    }

    func start() {
        let loginService = repository.service(of: AuthenticationService.identifier) as? AuthenticationService
        let viewController = ConnectViewController.instantiateViewController()
        let containerViewNavigationController = UINavigationController(rootViewController: viewController)
        let viewModel = ConnectViewModel(with: loginService)
        let aimsViewModel = AimsViewModel(with: loginService, accountService: accountService)

        viewModel.aimsViewModel = aimsViewModel

        viewController.splashScreenDelegate = presenter
        viewController.connectScreenCoordinatorDelegate = self
        viewController.viewModel = viewModel
        viewController.themingService = themingService
        connectViewController = viewController

        presenter.addChild(containerViewNavigationController)
        containerViewNavigationController.view.frame = CGRect(origin: .zero,
                                                              size: CGSize(width: presenter.containerView.frame.size.width,
                                                                           height: presenter.containerView.frame.size.height))
        presenter.containerView.addSubview(containerViewNavigationController.view)
        containerViewNavigationController.didMove(toParent: presenter)
        self.containerViewNavigationController = containerViewNavigationController

        if authenticationError != nil {
            viewController.showError(message: LocalizationConstants.Errors.noLongerAuthenticated)
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

    func showApplicationTabBar() {
        if let containerViewNavigationController = self.containerViewNavigationController {
            let tabBarCoordinator = TabBarScreenCoordinator(with: containerViewNavigationController)
            DispatchQueue.main.async {
                tabBarCoordinator.start()
            }
            self.tabBarCoordinator = tabBarCoordinator
        }
    }
}
