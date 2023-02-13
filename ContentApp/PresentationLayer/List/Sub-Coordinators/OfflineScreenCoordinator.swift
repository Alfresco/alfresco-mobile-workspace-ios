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

class OfflineScreenCoordinator: ListCoordinatorProtocol {
    private let presenter: TabBarMainViewController
    private var offlineViewController: ListViewController?
    private var navigationViewController: UINavigationController?
    private var actionMenuCoordinator: ActionMenuScreenCoordinator?
    private var offlineFolderChildrenScreenCoordinator: OfflineFolderChildrenScreenCoordinator?
    private var folderDrillDownCoordinator: FolderChildrenScreenCoordinator?
    private var filePreviewCoordinator: FilePreviewScreenCoordinator?
    private var offlineDataSource: OfflineDataSource?
    var nodeActionsModel: NodeActionsViewModel?
    private var createNodeSheetCoordinator: CreateNodeSheetCoordinator?
    let listNodeDataAccessor = ListNodeDataAccessor()

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }

    func start() {
        let offlineViewModelFactory = OfflineViewModelFactory(services: coordinatorServices)
        let offlineDataSource = offlineViewModelFactory.offlineDataSource()

        let viewController = ListViewController()
        viewController.title = LocalizationConstants.ScreenTitles.offline
        AnalyticsManager.shared.pageViewEvent(for: Event.Page.offlineTab)

        let viewModel = offlineDataSource.offlineViewModel
        let pageController = ListPageController(dataSource: viewModel.model,
                                                services: coordinatorServices)

        let searchViewModel = offlineDataSource.globalSearchViewModel
        let searchPageController = ListPageController(dataSource: searchViewModel.searchModel,
                                                      services: coordinatorServices)

        viewController.pageController = pageController
        viewController.searchPageController = searchPageController
        viewController.viewModel = viewModel
        viewController.searchViewModel = searchViewModel
        viewController.coordinatorServices = coordinatorServices
        
        viewController.tabBarScreenDelegate = presenter
        viewController.listItemActionDelegate = self

        self.offlineDataSource = offlineDataSource

        let navigationViewController = UINavigationController(rootViewController: viewController)
        presenter.viewControllers?.append(navigationViewController)
        self.navigationViewController = navigationViewController
        offlineViewController = viewController
    }

    func scrollToTopOrPopToRoot() {
        navigationViewController?.popToRootViewController(animated: true)
        if navigationViewController?.viewControllers.count == 1 {
            offlineViewController?.scrollToTop()
        } else {
            navigationViewController?.popToRootViewController(animated: true)
        }
        offlineViewController?.cancelSearchMode()
    }
}

extension OfflineScreenCoordinator: ListItemActionDelegate {
    func showPreview(for node: ListNode,
                     from dataSource: ListComponentModelProtocol) {
        if let navigationViewController = self.navigationViewController {
            let isNodeOffline = isNodeOffline(node: node)
            if node.isAFolderType() {
                
                if isNodeOffline {
                    let coordinator = OfflineFolderChildrenScreenCoordinator(with: navigationViewController,
                                                                             listNode: node)
                    coordinator.start()
                    self.offlineFolderChildrenScreenCoordinator = coordinator
                } else {
                    let coordinator = FolderChildrenScreenCoordinator(with: navigationViewController,
                                                                      listNode: node)
                    coordinator.start()
                    self.folderDrillDownCoordinator = coordinator
                }
            } else if node.isAFileType() {
                if isNodeOffline {
                    let coordinator = FilePreviewScreenCoordinator(with: navigationViewController,
                                                                   listNode: node,
                                                                   excludedActions: [.moveTrash,
                                                                                     .addFavorite,
                                                                                     .removeFavorite,
                                                                                     .renameNode,
                                                                                     .more,
                                                                                     .moveToFolder],
                                                                   shouldPreviewLatestContent: false)
                    coordinator.start()
                    self.filePreviewCoordinator = coordinator
                } else {
                    let coordinator = FilePreviewScreenCoordinator(with: navigationViewController,
                                                                   listNode: node)
                    coordinator.start()
                    self.filePreviewCoordinator = coordinator
                }
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
                                                      coordinatorServices: coordinatorServices,
                                                      excludedActionTypes: [.moveTrash,
                                                                            .addFavorite,
                                                                            .removeFavorite,
                                                                            .renameNode,
                                                                            .moveToFolder])
            
            let nodeActionsModel = NodeActionsViewModel(node: node,
                                                        delegate: delegate,
                                                        coordinatorServices: coordinatorServices)
            nodeActionsModel.moveDelegate = self
            let coordinator = ActionMenuScreenCoordinator(with: navigationViewController,
                                                          actionMenuViewModel: actionMenuViewModel,
                                                          nodeActionViewModel: nodeActionsModel)
            coordinator.start()
            actionMenuCoordinator = coordinator
        }
    }
    
    func moveNodeTapped(for sourceNode: ListNode,
                        destinationNode: ListNode,
                        delegate: NodeActionsViewModelDelegate,
                        actionMenu: ActionMenu) {
        let nodeActionsModel = NodeActionsViewModel(node: sourceNode,
                                                    delegate: delegate,
                                                    coordinatorServices: coordinatorServices)
        nodeActionsModel.moveFilesAndFolder(with: sourceNode, and: destinationNode, action: actionMenu)
        self.nodeActionsModel = nodeActionsModel
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

extension OfflineScreenCoordinator: NodeActionMoveDelegate {
    func didSelectMoveFile(node: ListNode?, action: ActionMenu) {
        if let navigationViewController = self.navigationViewController {
            let controller = FilesandFolderListViewController.instantiateViewController()
            controller.sourceNodeToMove = node
            let navController = UINavigationController(rootViewController: controller)
            navigationViewController.present(navController, animated: true)
        }
    }
}

// MARK: - Check if File/Folder is Offline
extension OfflineScreenCoordinator {
    private func isNodeOffline(node: ListNode) -> Bool {
        let offlineNodes = listNodeDataAccessor.queryMarkedOffline()
        if offlineNodes.contains(node) {
            return true
        }
        return false
    }
}
