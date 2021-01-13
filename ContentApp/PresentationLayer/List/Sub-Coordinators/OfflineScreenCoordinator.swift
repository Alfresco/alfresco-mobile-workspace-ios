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

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }

    func start() {
        let offlineViewModelFactory = OfflineViewModelFactory()
        offlineViewModelFactory.coordinatorServices = coordinatorServices

        let offlineDataSource = offlineViewModelFactory.offlineDataSource()

        let viewController = ListViewController()
        viewController.isPaginationEnabled = false
        viewController.title = LocalizationConstants.ScreenTitles.offline
        viewController.coordinatorServices = coordinatorServices
        viewController.listViewModel = offlineDataSource.offlineViewModel
        viewController.tabBarScreenDelegate = presenter
        viewController.listItemActionDelegate = self
        viewController.searchViewModel = offlineDataSource.globalSearchViewModel
        viewController.resultViewModel = offlineDataSource.resultsViewModel

        let navigationViewController = UINavigationController(rootViewController: viewController)
        self.presenter.viewControllers?.append(navigationViewController)
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
    func showPreview(from node: ListNode) {
        if node.nodeType == .folder, let navigationViewController = self.navigationViewController {
            let coordinator = OfflineFolderChildrenScreenCoordinator(with: navigationViewController,
                                                                     listNode: node)
            coordinator.start()
            self.offlineFolderChildrenScreenCoordinator = coordinator
        }
    }

    func showActionSheetForListItem(for node: ListNode, delegate: NodeActionsViewModelDelegate) {
        if let navigationViewController = self.navigationViewController {
            let actionMenuViewModel = ActionMenuViewModel(node: node,
                                                                   offlineTabDisplayed: true,
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

    func showNodeCreationDialog(with actionMenu: ActionMenu, delegate: CreateNodeViewModelDelegate?) {
        // Do nothing
    }
}
