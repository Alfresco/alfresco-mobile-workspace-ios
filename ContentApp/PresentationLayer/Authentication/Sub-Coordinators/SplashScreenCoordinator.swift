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

protocol SplashScreenCoordinatorDelegate: class {
    func showLoginContainerView()
    func showAdvancedSettingsScreen()
    func popViewControllerFromContainer()
}

class SplashScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var splashScreenViewController: SplashViewController?
    private var advancedSettingsCoordinator: AdvancedSettingsScreenCoordinator?
    private var connectScreenCoordinator: ConnectScreenCoordinator?

    init(with presenter: UINavigationController) {
        self.presenter = presenter
    }

    func start() {
        // Set up the splash view controller
        let splashScreenViewController = SplashViewController.instantiateViewController()
        splashScreenViewController.coordinatorDelegate = self
        splashScreenViewController.themingService = self.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        self.splashScreenViewController = splashScreenViewController
        presenter.pushViewController(splashScreenViewController, animated: true)

        // Set up the connect view controller
        let connectScreenCoordinator = ConnectScreenCoordinator(with: splashScreenViewController)
        self.connectScreenCoordinator = connectScreenCoordinator
    }
}

extension SplashScreenCoordinator: SplashScreenCoordinatorDelegate {
    func popViewControllerFromContainer() {
        self.connectScreenCoordinator?.popViewController()
    }

    func showLoginContainerView() {
        connectScreenCoordinator?.start()
    }

    func showAdvancedSettingsScreen() {
        let advancedSettingsCoordinator = AdvancedSettingsScreenCoordinator(with: presenter)
        advancedSettingsCoordinator.start()
        self.advancedSettingsCoordinator = advancedSettingsCoordinator
    }
}
