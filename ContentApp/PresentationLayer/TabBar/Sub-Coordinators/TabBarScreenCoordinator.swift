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
        let router = self.serviceRepository.service(of: Router.serviceIdentifier) as? Router
        router?.register(route: NavigationRoutes.mainTabBarScreen.path, factory: { [weak self] (_, _) -> UIViewController? in
            guard let sSelf = self else { return nil }

            let viewController = TabBarMainViewController.instantiateViewController()

            let recentTabBarItem = UITabBarItem(title: LocalizationConstants.ScreenTitles.recent,
                                                image: UIImage(named: "recent-unselected"),
                                                selectedImage: UIImage(named: "recent-selected"))
            recentTabBarItem.tag = 0
            let favoritesTabBarItem = UITabBarItem(title: LocalizationConstants.ScreenTitles.favorites,
                                                   image: UIImage(named: "favorite-unselected"),
                                                   selectedImage: UIImage(named: "favorite-selected"))
            favoritesTabBarItem.tag = 1
            let browseTabBarItem = UITabBarItem(title: LocalizationConstants.ScreenTitles.browse,
                                                image: UIImage(named: "browse-unselected"),
                                                selectedImage: UIImage(named: "browse-selected"))
            viewController.tabs = [recentTabBarItem, favoritesTabBarItem, browseTabBarItem]

            viewController.themingService = sSelf.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
            viewController.tabBarCoordinatorDelegate = sSelf
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .fullScreen
            sSelf.tabBarMainViewController = viewController

            return viewController
        })

        router?.present(route: NavigationRoutes.mainTabBarScreen.path, from: presenter)
    }
}

extension TabBarScreenCoordinator: TabBarScreenCoordinatorDelegate {
    func showSettingsScreen() {
        if let navigationController = tabBarMainViewController?.viewControllers?.first as? UINavigationController {
            tabBarMainViewController?.tabBar.isHidden = true
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
