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

protocol AimsScreenCoordinatorDelegate: class {
    func showNeedHelpSheet()
    func showApplicationTabBar()
}

class AimsScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private let splashScreen: SplashViewController
    private var aimsViewController: AimsViewController?
    private var needHelpCoordinator: NeedHelpCoordinator?
    private var tabBarCoordinator: TabBarScreenCoordinator?

    init(with presenter: UINavigationController, splashScreen: SplashViewController) {
        self.presenter = presenter
        self.splashScreen = splashScreen
    }

    func start() {
        let router = self.serviceRepository.service(of: Router.serviceIdentifier) as? Router
        router?.register(route: NavigationRoutes.aimsAuthScreen.path, factory: { [weak self] (_, _) -> UIViewController? in
            guard let sSelf = self else { return nil }

            let viewController = AimsViewController.instantiateViewController()
            viewController.aimsScreenCoordinatorDelegate = sSelf
            viewController.themingService = sSelf.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
            viewController.viewModel = AimsViewModel(with: sSelf.serviceRepository.service(of: AuthenticationService.serviceIdentifier) as? AuthenticationService,
                                                     accountService: sSelf.serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService)
            viewController.splashScreenDelegate = sSelf.splashScreen
            sSelf.aimsViewController = viewController

            return viewController
        })

        router?.push(route: NavigationRoutes.aimsAuthScreen.path, from: presenter)
    }
}

extension AimsScreenCoordinator: AimsScreenCoordinatorDelegate {
    func showNeedHelpSheet() {
        let needHelpCoordinator = NeedHelpCoordinator(with: presenter, model: NeedHelpAIMSModel())
        needHelpCoordinator.start()
        self.needHelpCoordinator = needHelpCoordinator
    }

    func showApplicationTabBar() {
        let tabBarCoordinator = TabBarScreenCoordinator(with: presenter)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            tabBarCoordinator.start()
        }
        self.tabBarCoordinator = tabBarCoordinator
    }
}
