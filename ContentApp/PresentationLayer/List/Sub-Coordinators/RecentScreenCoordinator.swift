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

class RecentScreenCoordinator: PresentingCoordinator,
                               ListCoordinatorProtocol {

    private let presenter: TabBarMainViewController
    private var recentViewController: ListViewController?
    private var navigationViewController: UINavigationController?
    private var actionMenuCoordinator: ActionMenuScreenCoordinator?
    private var uploadFilesScreenCoordinator: UploadFilesScreenCoordinator?
    private var nodeActionsModel: NodeActionsViewModel?
    private var createNodeSheetCoordinator: CreateNodeSheetCoordinator?
    private var multipleSelectionActionMenuCoordinator: MultipleFileActionMenuScreenCoordinator?
    private var filesAndFolderViewController: FilesandFolderListViewController?

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }

    override func start() {
        let recentViewModelFactory = RecentViewModelFactory(services: coordinatorServices)
        let recentDataSource = recentViewModelFactory.recentDataSource()

        let viewController = ListViewController()
        viewController.title = LocalizationConstants.ScreenTitles.recent
        viewController.coordinatorServices = coordinatorServices

        let viewModel = recentDataSource.recentViewModel
        let pageController = ListPageController(dataSource: viewModel.model,
                                                services: coordinatorServices)

        let searchViewModel = recentDataSource.globalSearchViewModel
        let searchPageController = ListPageController(dataSource: searchViewModel.searchModel,
                                                      services: coordinatorServices)

        viewController.pageController = pageController
        viewController.searchPageController = searchPageController
        viewController.viewModel = viewModel
        viewController.searchViewModel = searchViewModel

        viewController.tabBarScreenDelegate = presenter
        viewController.listItemActionDelegate = self

        let navigationViewController = UINavigationController(rootViewController: viewController)
        presenter.viewControllers = [navigationViewController]
        self.navigationViewController = navigationViewController
        recentViewController = viewController
        APSService.checkIfAPSServiceEnabled()
    }

    func scrollToTopOrPopToRoot() {
        if navigationViewController?.viewControllers.count == 1 {
            recentViewController?.scrollToTop()
        } else {
            navigationViewController?.popToRootViewController(animated: true)
        }
        recentViewController?.cancelSearchMode()
    }
}

extension RecentScreenCoordinator: ListItemActionDelegate {
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
                                                        coordinatorServices: coordinatorServices,
                                                        multipleNodes: [])
            nodeActionsModel.moveDelegate = self
            let coordinator = ActionMenuScreenCoordinator(with: navigationViewController,
                                                          actionMenuViewModel: actionMenuViewModel,
                                                          nodeActionViewModel: nodeActionsModel,
                                                          listNode: node)
            coordinator.start()
            actionMenuCoordinator = coordinator
            self.nodeActionsModel = nodeActionsModel
        }
    }
    
    func showActionSheetForMultiSelectListItem(for nodes: [ListNode],
                                               from dataSource: ListComponentModelProtocol,
                                               delegate: NodeActionsViewModelDelegate) {
        if let navigationViewController = self.navigationViewController {
            let isFavoriteAllowed = UIFunction.isFavoriteAllowedForACSVersion()
            var excludedActions: [ActionMenuType] = []
            if !isFavoriteAllowed {
                excludedActions = [.addFavorite, .removeFavorite]
            }
            
            let actionMenuViewModel = MultipleSelectionActionMenuViewModel(nodes: nodes,
                                                                           excludedActions: excludedActions,
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
    
    func didSelectMoveMultipleListItems(for nodes: [ListNode],
                                        from dataSource: ListComponentModelProtocol,
                                        delegate: NodeActionsViewModelDelegate) {
       
        let actionMenu = ActionMenu(title: LocalizationConstants.ActionMenu.moveToFolder, type: .moveToFolder)
        didSelectMoveFile(node: nodes, action: actionMenu)
    }
    
    func showUploadingFiles() {
        if let navigationViewController = self.navigationViewController {
            let uploadFilesScreenCoordinator = UploadFilesScreenCoordinator(with: navigationViewController)
            uploadFilesScreenCoordinator.start()
            self.uploadFilesScreenCoordinator = uploadFilesScreenCoordinator
        }
    }
    
    func moveNodeTapped(for sourceNode: [ListNode],
                        destinationNode: ListNode,
                        delegate: NodeActionsViewModelDelegate,
                        actionMenu: ActionMenu) {
        for node in sourceNode {
            let nodeActionsModel = NodeActionsViewModel(node: node,
                                                        delegate: delegate,
                                                        coordinatorServices: coordinatorServices,
                                                        multipleNodes: sourceNode)
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

extension RecentScreenCoordinator: NodeActionMoveDelegate {
    func didSelectMoveFile(node: [ListNode], action: ActionMenu) {
        if let navigationViewController = self.navigationViewController {
            let controller = FilesandFolderListViewController.instantiateViewController()
            controller.sourceNodeToMove = node
            let navController = UINavigationController(rootViewController: controller)
            navigationViewController.present(navController, animated: true)
            filesAndFolderViewController = controller
            filesAndFolderViewController?.didSelectDismissAction = {[weak self] in
                guard let sSelf = self else { return }
                sSelf.recentViewController?.listController?.resetMultipleSelectionView()
            }
        }
    }
}
