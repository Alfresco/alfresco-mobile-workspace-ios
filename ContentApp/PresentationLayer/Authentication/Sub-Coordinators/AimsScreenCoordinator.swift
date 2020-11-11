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
        let loginService = repository.service(of: AuthenticationService.identifier) as? AuthenticationService
        let viewController = AimsViewController.instantiateViewController()
        let viewModel = AimsViewModel(with: loginService, accountService: accountService)

        viewController.aimsScreenCoordinatorDelegate = self
        viewController.nodeServices = nodeServices
        viewController.viewModel = viewModel
        viewController.splashScreenDelegate = splashScreen
        aimsViewController = viewController
        presenter.pushViewController(viewController, animated: true)
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
        DispatchQueue.main.async {
            tabBarCoordinator.start()
        }
        self.tabBarCoordinator = tabBarCoordinator
    }
}
