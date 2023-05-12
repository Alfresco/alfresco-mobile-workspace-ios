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

protocol TabBarScreenCoordinatorDelegate: AnyObject {
    func showRecentScreen()
    func showFavoritesScreen()
    func showBrowseScreen()
    func showOfflineScreen()
    func showSettingsScreen()
    func scrollToTopOrPopToRoot(forScreen item: Int)
    func showTasksScreen()
    func showMultipleSelectionOption()
}

class TabBarScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var tabBarMainViewController: TabBarMainViewController?
    private var recentCoordinator: RecentScreenCoordinator?
    private var favoritesCoordinator: FavoritesScreenCoordinator?
    private var browseCoordinator: BrowseScreenCoordinator?
    private var offlineCoordinator: OfflineScreenCoordinator?
    private var settingsCoordinator: SettingsScreenCoordinator?
    private var tasksCoordinator: TasksScreenCoordinator?

    init(with presenter: UINavigationController) {
        self.presenter = presenter
    }

    func start() {
        coordinatorServices.syncTriggersService?.registerTriggers()

        let viewController = TabBarMainViewController.instantiateViewController()
        let recentTabBarItem = UITabBarItem(title: LocalizationConstants.ScreenTitles.recent,
                                            image: UIImage(named: "ic-recent-unselected"),
                                            selectedImage: UIImage(named: "ic-recent-selected"))
        let favoritesTabBarItem = UITabBarItem(title: LocalizationConstants.ScreenTitles.favorites,
                                               image: UIImage(named: "ic-favorite-unselected"),
                                               selectedImage: UIImage(named: "ic-favorite-selected"))
        let offlineTabBarItem = UITabBarItem(title: LocalizationConstants.ScreenTitles.offline,
                                            image: UIImage(named: "ic-offline-unselected"),
                                            selectedImage: UIImage(named: "ic-offline-selected"))
        let browseTabBarItem = UITabBarItem(title: LocalizationConstants.ScreenTitles.browse,
                                            image: UIImage(named: "ic-browse-unselected"),
                                            selectedImage: UIImage(named: "ic-browse-selected"))
        let tasksTabBarItem = UITabBarItem(title: LocalizationConstants.ScreenTitles.tasks,
                                            image: UIImage(named: "ic-tasks-unselected"),
                                            selectedImage: UIImage(named: "ic-tasks-selected"))
        
        recentTabBarItem.accessibilityIdentifier = "recentTab"
        favoritesTabBarItem.accessibilityIdentifier = "favoritesTab"
        offlineTabBarItem.accessibilityIdentifier = "offlineTab"
        browseTabBarItem.accessibilityIdentifier = "browseTab"
        tasksTabBarItem.accessibilityIdentifier = "tasksTab"

        recentTabBarItem.tag = 0
        favoritesTabBarItem.tag = 1
        tasksTabBarItem.tag = 2
        offlineTabBarItem.tag = 3
        browseTabBarItem.tag = 4
        viewController.tabs = [recentTabBarItem,
                               favoritesTabBarItem,
                               tasksTabBarItem,
                               offlineTabBarItem,
                               browseTabBarItem]
        viewController.themingService = themingService
        viewController.connectivityService = coordinatorServices.connectivityService
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

    func showOfflineScreen() {
        if let tabBarMainViewController = self.tabBarMainViewController {
            offlineCoordinator = OfflineScreenCoordinator(with: tabBarMainViewController)
            offlineCoordinator?.start()
        }
    }

    func showBrowseScreen() {
        if let tabBarMainViewController = self.tabBarMainViewController {
            browseCoordinator = BrowseScreenCoordinator(with: tabBarMainViewController)
            browseCoordinator?.start()
        }
    }
    
    func showTasksScreen() {
        if let tabBarMainViewController = self.tabBarMainViewController {
            tasksCoordinator = TasksScreenCoordinator(with: tabBarMainViewController)
            tasksCoordinator?.start()
        }
    }

    func scrollToTopOrPopToRoot(forScreen item: Int) {
        switch item {
        case 0: // Recents
            recentCoordinator?.scrollToTopOrPopToRoot()
        case 1: // Favorites
            favoritesCoordinator?.scrollToTopOrPopToRoot()
        case 2: // tasks
            tasksCoordinator?.scrollToTopOrPopToRoot()
        case 3: // Offline
            offlineCoordinator?.scrollToTopOrPopToRoot()
        case 4: // Browse
            browseCoordinator?.scrollToTopOrPopToRoot()
        default:
            break
        }
    }
    
    func showMultipleSelectionOption() {
        MultipleSelectionModel.shared.toggleMultipleSelection()
        MultipleSelectionModel.shared.tabBarScreenCoordinator = self
        reloadCollectionViews()
    }
    
    func reloadCollectionViews() {
        recentCoordinator?.showMultipleSelectionOption()
        favoritesCoordinator?.showMultipleSelectionOption()
        offlineCoordinator?.showMultipleSelectionOption()
    }
}

