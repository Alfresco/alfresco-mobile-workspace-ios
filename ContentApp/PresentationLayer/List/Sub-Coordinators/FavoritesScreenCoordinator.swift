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

class FavoritesScreenCoordinator: ListCoordinatorProtocol {

    private let presenter: TabBarMainViewController
    private var favoritesViewController: FavoritesViewController?
    private var navigationViewController: UINavigationController?
    private var folderDrillDownCoordinator: FolderChildrenScreenCoordinator?
    private var filePreviewCoordinator: FilePreviewScreenCoordinator?
    private var actionMenuCoordinator: ActionMenuScreenCoordinator?

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }

    func start() {
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
                     from dataSource: ListComponentDataSourceProtocol) {
        if let navigationViewController = self.navigationViewController {
            switch node.nodeType {
            case .folder, .site, .folderLink:
                let coordinator = FolderChildrenScreenCoordinator(with: navigationViewController,
                                                                  listNode: node)
                coordinator.start()
                self.folderDrillDownCoordinator = coordinator
            case .file, .fileLink:
                let coordinator = FilePreviewScreenCoordinator(with: navigationViewController,
                                                               listNode: node)
                coordinator.start()
                self.filePreviewCoordinator = coordinator

            default:
                AlfrescoLog.error("Unable to show preview for unknown node type")
            }
        }
    }

    func showActionSheetForListItem(for node: ListNode,
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

    func showNodeCreationSheet(delegate: NodeActionsViewModelDelegate) {
        // Do nothing
    }

    func showNodeCreationDialog(with actionMenu: ActionMenu,
                                delegate: CreateNodeViewModelDelegate?) {
        // Do nothing
    }
}
