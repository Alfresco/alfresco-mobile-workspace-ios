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
    func showBrowseScreen()
    func showSettingsScreen()
    func scrollToTopOrPopToRoot(forScreen item: Int)
}

class TabBarScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var tabBarMainViewController: TabBarMainViewController?
    private var recentCoordinator: RecentScreenCoordinator?
    private var favoritesCoordinator: FavoritesScreenCoordinator?
    private var browseCoordinator: BrowseScreenCoordinator?
    private var settingsCoordinator: SettingsScreenCoordinator?

    init(with presenter: UINavigationController) {
        self.presenter = presenter
    }

    func start() {
        let themingService = repository.service(of: MaterialDesignThemingService.identifier) as? MaterialDesignThemingService
        let viewController = TabBarMainViewController.instantiateViewController()
        let recentTabBarItem = UITabBarItem(title: LocalizationConstants.ScreenTitles.recent,
                                            image: UIImage(named: "recent-unselected"),
                                            selectedImage: UIImage(named: "recent-selected"))
        let favoritesTabBarItem = UITabBarItem(title: LocalizationConstants.ScreenTitles.favorites,
                                               image: UIImage(named: "favorite-unselected"),
                                               selectedImage: UIImage(named: "favorite-selected"))
        let browseTabBarItem = UITabBarItem(title: LocalizationConstants.ScreenTitles.browse,
                                            image: UIImage(named: "browse-unselected"),
                                            selectedImage: UIImage(named: "browse-selected"))

        recentTabBarItem.tag = 0
        favoritesTabBarItem.tag = 1
        browseTabBarItem.tag = 2
        viewController.tabs = [recentTabBarItem, favoritesTabBarItem, browseTabBarItem]
        viewController.themingService = themingService
        viewController.tabBarCoordinatorDelegate = self
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .fullScreen
        tabBarMainViewController = viewController
        presenter.present(viewController, animated: true, completion: nil)
    }
}

extension TabBarScreenCoordinator: TabBarScreenCoordinatorDelegate {
    func showSettingsScreen() {
        if let viewControllers = tabBarMainViewController?.viewControllers,
            let selectedIndex = tabBarMainViewController?.selectedIndex,
            let navigationController = viewControllers[selectedIndex] as? UINavigationController {
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

    func showBrowseScreen() {
        if let tabBarMainViewController = self.tabBarMainViewController {
            browseCoordinator = BrowseScreenCoordinator(with: tabBarMainViewController)
            browseCoordinator?.start()
        }
    }

    func scrollToTopOrPopToRoot(forScreen item: Int) {
        switch item {
        case 0: //Recents
            recentCoordinator?.scrollToTopOrPopToRoot()
        case 1: //Favorites
            favoritesCoordinator?.scrollToTopOrPopToRoot()
        case 2: //Browse
            browseCoordinator?.scrollToTopOrPopToRoot()
        default:
            break
        }
    }
}
