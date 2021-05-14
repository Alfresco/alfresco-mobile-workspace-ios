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

class FavoritesScreenCoordinator: PresentingCoordinator,
                                  ListCoordinatorProtocol {
    private let presenter: TabBarMainViewController
    private var favoritesViewController: FavoritesViewController?
    private var navigationViewController: UINavigationController?
    private var actionMenuCoordinator: ActionMenuScreenCoordinator?

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }

    override func start() {
        let favoritesViewModelFactory = FavoritesViewModelFactory()
        favoritesViewModelFactory.coordinatorServices = coordinatorServices

        let favoritesDataSource = favoritesViewModelFactory.favoritesDataSource()

        let viewController = FavoritesViewController()
        viewController.title = LocalizationConstants.ScreenTitles.favorites
        viewController.coordinatorServices = coordinatorServices
        viewController.listItemActionDelegate = self
        viewController.tabBarScreenDelegate = presenter
        viewController.folderAndFilesListViewModel = favoritesDataSource.foldersAndFilesViewModel
        viewController.librariesListViewModel = favoritesDataSource.librariesViewModel
        viewController.searchViewModel = favoritesDataSource.globalSearchViewModel
        viewController.resultViewModel = favoritesDataSource.resultsViewModel

        let navigationViewController = UINavigationController(rootViewController: viewController)
        presenter.viewControllers?.append(navigationViewController)
        self.navigationViewController = navigationViewController
        favoritesViewController = viewController
    }

    func scrollToTopOrPopToRoot() {
        if navigationViewController?.viewControllers.count == 1 {
            favoritesViewController?.scrollToTop()
        } else {
            navigationViewController?.popToRootViewController(animated: true)
        }
        favoritesViewController?.cancelSearchMode()
    }
}

extension FavoritesScreenCoordinator: ListItemActionDelegate {
    func showPreview(for node: ListNode,
                     from dataSource: ListComponentModelProtocol) {
        if let navigationViewController = self.navigationViewController {
            if node.isAFolderType() || node.nodeType == .site {
                startFolderCoordinator(for: node,
                                       presenter: navigationViewController)
            } else if node.isAFileType() {
                startFileCoordinator(for: node,
                                     presenter: navigationViewController)
            } else {
                AlfrescoLog.error("Unable to show preview for unknown node type")
            }
        }
    }

    func showActionSheetForListItem(for node: ListNode,
                                    from dataSource: ListComponentModelProtocol,
                                    delegate: NodeActionsViewModelDelegate) {
        if let navigationViewController = self.navigationViewController {
            let actionMenuViewModel = ActionMenuViewModel(node: node,
                                                          coordinatorServices: coordinatorServices)
            let nodeActionsModel = NodeActionsViewModel(node: node,
                                                        delegate: delegate,
                                                        coordinatorServices: coordinatorServices)
            let coordinator = ActionMenuScreenCoordinator(with: navigationViewController,
                                                          actionMenuViewModel: actionMenuViewModel,
                                                          nodeActionViewModel: nodeActionsModel)
            coordinator.start()
            actionMenuCoordinator = coordinator
        }
    }
}
