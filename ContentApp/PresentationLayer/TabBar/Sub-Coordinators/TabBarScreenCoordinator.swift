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

protocol TabBarScreenCoordinatorDelegate: class {
    func showRecentScreen()
    func showFavoritesScreen()
    func showSettingsScreen()
}

class TabBarScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var tabBarMainViewController: TabBarMainViewController?
    private var recentCoordinator: RecentScreenCoordinator?
    private var favoritesCoordinator: FavoritesScreenCoordinator?
    private var settingsCoordinator: SettingsScreenCoordinator?

    init(with presenter: UINavigationController) {
        self.presenter = presenter
    }

    func start() {
        let viewController = TabBarMainViewController.instantiateViewController()
        viewController.themingService = self.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        viewController.tabBarCoordinatorDelegate = self
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .fullScreen
        self.tabBarMainViewController = viewController

        presenter.present(viewController, animated: true, completion: nil)
    }
}

extension TabBarScreenCoordinator: TabBarScreenCoordinatorDelegate {
    func showSettingsScreen() {
        if let navigationController = tabBarMainViewController?.viewControllers?.first as? UINavigationController {
            settingsCoordinator = SettingsScreenCoordinator(with: navigationController)
            settingsCoordinator?.start()
        }
    }

    func showRecentScreen() {
        if let tabBarMainViewController = self.tabBarMainViewController {
            recentCoordinator = RecentScreenCoordinator(with: tabBarMainViewController)
            recentCoordinator?.start()
        }
    }

    func showFavoritesScreen() {
        if let tabBarMainViewController = self.tabBarMainViewController {
            favoritesCoordinator = FavoritesScreenCoordinator(with: tabBarMainViewController)
            favoritesCoordinator?.start()
        }
    }
}
