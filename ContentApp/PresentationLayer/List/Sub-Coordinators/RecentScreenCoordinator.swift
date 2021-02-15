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

class RecentScreenCoordinator: ListCoordinatorProtocol {

    private let presenter: TabBarMainViewController
    private var recentViewController: ListViewController?
    private var navigationViewController: UINavigationController?
    private var folderDrillDownCoordinator: FolderChildrenScreenCoordinator?
    private var filePreviewCoordinator: FilePreviewScreenCoordinator?
    private var actionMenuCoordinator: ActionMenuScreenCoordinator?

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }

    func start() {
        let recentViewModelFactory = RecentViewModelFactory()
        recentViewModelFactory.coordinatorServices = coordinatorServices

        let recentDataSource = recentViewModelFactory.recentDataSource()

        let viewController = ListViewController()
        viewController.title = LocalizationConstants.ScreenTitles.recent
        viewController.coordinatorServices = coordinatorServices
        viewController.listViewModel = recentDataSource.recentViewModel
        viewController.tabBarScreenDelegate = presenter
        viewController.listItemActionDelegate = self
        viewController.searchViewModel = recentDataSource.globalSearchViewModel
        viewController.resultViewModel = recentDataSource.resultsViewModel

        let navigationViewController = UINavigationController(rootViewController: viewController)
        presenter.viewControllers = [navigationViewController]
        self.navigationViewController = navigationViewController
        recentViewController = viewController
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
                     from dataSource: ListComponentDataSourceProtocol) {
        if let navigationViewController = self.navigationViewController {
            switch node.nodeType {
            case .folder, .folderLink, .site:
                let folderDrillDownCoordinator =
                    FolderChildrenScreenCoordinator(with: navigationViewController,
                                                    listNode: node)
                folderDrillDownCoordinator.start()
                self.folderDrillDownCoordinator = folderDrillDownCoordinator
            case .file, .fileLink:
                let filePreviewCoordinator =
                    FilePreviewScreenCoordinator(with: navigationViewController,
                                                 listNode: node)
                filePreviewCoordinator.start()
                self.filePreviewCoordinator = filePreviewCoordinator
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
