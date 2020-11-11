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

protocol BasicAuthScreenCoordinatorDelegate: class {
    func showApplicationTabBar()
}

class BasicAuthScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var basicAuthViewController: BasicAuthViewController?
    private let splashScreen: SplashViewController
    private var tabBarCoordinator: TabBarScreenCoordinator?

    init(with presenter: UINavigationController, splashScreen: SplashViewController) {
        self.presenter = presenter
        self.splashScreen = splashScreen
    }

    func start() {
        let loginService = repository.service(of: AuthenticationService.identifier) as? AuthenticationService
        let viewController = BasicAuthViewController.instantiateViewController()
        let viewModel = BasicAuthViewModel(with: loginService, accountService: accountService)

        viewController.splashScreenDelegate = splashScreen
        viewController.basicAuthCoordinatorDelegate = self
        viewController.nodeServices = nodeServices

        viewController.viewModel = viewModel
        basicAuthViewController = viewController
        presenter.pushViewController(viewController, animated: true)
    }
}

extension BasicAuthScreenCoordinator: BasicAuthScreenCoordinatorDelegate {
    func showApplicationTabBar() {
        let tabBarCoordinator = TabBarScreenCoordinator(with: presenter)
        tabBarCoordinator.start()
        self.tabBarCoordinator = tabBarCoordinator
    }
}
