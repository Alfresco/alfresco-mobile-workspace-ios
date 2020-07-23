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
        let router = self.serviceRepository.service(of: Router.serviceIdentifier) as? Router
        router?.register(route: NavigationRoutes.basicAuthScreen.path, factory: { [weak self] (_, _) -> UIViewController? in
            guard let sSelf = self else { return nil }

            let viewController = BasicAuthViewController.instantiateViewController()
            viewController.splashScreenDelegate = sSelf.splashScreen
            viewController.basicAuthCoordinatorDelegate = sSelf
            viewController.themingService = sSelf.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
            viewController.viewModel = BasicAuthViewModel(with: sSelf.serviceRepository.service(of: AuthenticationService.serviceIdentifier) as? AuthenticationService,
                                                          accountService: sSelf.serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService)
            sSelf.basicAuthViewController = viewController

            return viewController
        })

        router?.push(route: NavigationRoutes.basicAuthScreen.path, from: presenter)
    }
}

extension BasicAuthScreenCoordinator: BasicAuthScreenCoordinatorDelegate {
    func showApplicationTabBar() {
        let tabBarCoordinator = TabBarScreenCoordinator(with: presenter)
        tabBarCoordinator.start()
        self.tabBarCoordinator = tabBarCoordinator
    }
}
