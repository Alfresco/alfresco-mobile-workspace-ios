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
    var nodeActionsModel: NodeActionsViewModel?
    private var createNodeSheetCoordinator: CreateNodeSheetCoordinator?
    private var multipleSelectionActionMenuCoordinator: MultipleFileActionMenuScreenCoordinator?
    private var filesAndFolderViewController: FilesandFolderListViewController?

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }

    override func start() {
        let favoritesViewModelFactory = FavoritesViewModelFactory(services: coordinatorServices)
        let favoritesDataSource = favoritesViewModelFactory.favoritesDataSource()

        let viewController = FavoritesViewController()
        viewController.title = LocalizationConstants.ScreenTitles.favorites

        let folderAndFilesViewModel = favoritesDataSource.foldersAndFilesViewModel
        let librariesViewModel = favoritesDataSource.librariesViewModel
        let searchViewModel = favoritesDataSource.globalSearchViewModel

        let folderAndFilesPageController = ListPageController(dataSource: folderAndFilesViewModel.model,
                                                              services: coordinatorServices)
        let librariesPageController = ListPageController(dataSource: librariesViewModel.model,
                                                         services: coordinatorServices)
        let searchPageController = ListPageController(dataSource: searchViewModel.searchModel,
                                                      services: coordinatorServices)

        viewController.folderAndFilesListViewModel = folderAndFilesViewModel
        viewController.librariesListViewModel = librariesViewModel
        viewController.searchViewModel = searchViewModel
        viewController.folderAndFilesPageController = folderAndFilesPageController
        viewController.librariesPageController = librariesPageController
        viewController.searchPageController = searchPageController

        viewController.coordinatorServices = coordinatorServices
        viewController.listItemActionDelegate = self
        viewController.tabBarScreenDelegate = presenter

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
                                       presenter: navigationViewController,
                                       sourceNodeToMove: nil)
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
            nodeActionsModel.moveDelegate = self
            let coordinator = ActionMenuScreenCoordinator(with: navigationViewController,
                                                          actionMenuViewModel: actionMenuViewModel,
                                                          nodeActionViewModel: nodeActionsModel,
                                                          listNode: node)
            coordinator.start()
            actionMenuCoordinator = coordinator
        }
    }
    
    func showActionSheetForMultiSelectListItem(for nodes: [ListNode],
                                               from dataSource: ListComponentModelProtocol,
                                               delegate: NodeActionsViewModelDelegate) {
        if let navigationViewController = self.navigationViewController {
            let actionMenuViewModel = MultipleSelectionActionMenuViewModel(nodes: nodes,
                                                          coordinatorServices: coordinatorServices)
            
            let nodeActionsModel = NodeActionsViewModel(node: nodes.first,
                                                        delegate: delegate,
                                                        coordinatorServices: coordinatorServices,
                                                        multipleNodes: nodes)
            nodeActionsModel.moveDelegate = self
            
            let coordinator = MultipleFileActionMenuScreenCoordinator(with: navigationViewController,
                                                                      actionMenuViewModel: actionMenuViewModel,
                                                                      nodeActionViewModel: nodeActionsModel,
                                                                      listNodes: nodes)
            coordinator.start()
            multipleSelectionActionMenuCoordinator = coordinator
        }
    }
    
    func moveNodeTapped(for sourceNode: [ListNode],
                        destinationNode: ListNode,
                        delegate: NodeActionsViewModelDelegate,
                        actionMenu: ActionMenu) {
        for node in sourceNode {
            let nodeActionsModel = NodeActionsViewModel(node: node,
                                                        delegate: delegate,
                                                        coordinatorServices: coordinatorServices)
            nodeActionsModel.moveFilesAndFolder(with: node, and: destinationNode, action: actionMenu)
            self.nodeActionsModel = nodeActionsModel
        }
    }
    
    func renameNodeForListItem(for node: ListNode?, actionMenu: ActionMenu,
                               delegate: CreateNodeViewModelDelegate?) {
        if let node = node, let navigationViewController = self.navigationViewController {
            let coordinator = CreateNodeSheetCoordinator(with: navigationViewController,
                                                         actionMenu: actionMenu,
                                                         parentListNode: node,
                                                         createNodeViewModelDelegate: delegate,
                                                         createNodeViewType: .rename)
            coordinator.start()
            createNodeSheetCoordinator = coordinator
        }
    }
}

extension FavoritesScreenCoordinator: NodeActionMoveDelegate {
    func didSelectMoveFile(node: [ListNode], action: ActionMenu) {
        if let navigationViewController = self.navigationViewController {
            let controller = FilesandFolderListViewController.instantiateViewController()
            controller.sourceNodeToMove = node
            let navController = UINavigationController(rootViewController: controller)
            navigationViewController.present(navController, animated: true)
            filesAndFolderViewController = controller
            filesAndFolderViewController?.didSelectDismissAction = {[weak self] in
                guard let sSelf = self else { return }
                sSelf.favoritesViewController?.folderAndFilesViewController?.resetMultipleSelectionView()
            }
        }
    }
}
