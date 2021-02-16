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

        self.offlineDataSource = offlineDataSource

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
    func showPreview(for node: ListNode,
                     from dataSource: ListComponentDataSourceProtocol) {
        if let navigationViewController = self.navigationViewController {
            switch node.nodeType {
            case .folder, .site, .folderLink:
                if dataSource === offlineDataSource?.resultsViewModel {
                    let coordinator = FolderChildrenScreenCoordinator(with: navigationViewController,
                                                                      listNode: node)
                    coordinator.start()
                    self.folderDrillDownCoordinator = coordinator
                } else {
                    let coordinator = OfflineFolderChildrenScreenCoordinator(with: navigationViewController,
                                                                             listNode: node)
                    coordinator.start()
                    self.offlineFolderChildrenScreenCoordinator = coordinator
                }
            case .file, .fileLink:
                let shouldPreviewLatestContent = (dataSource === offlineDataSource?.resultsViewModel)
                let coordinator = FilePreviewScreenCoordinator(with: navigationViewController,
                                                               listNode: node,
                                                               excludedActions: [.moveTrash,
                                                                                 .addFavorite,
                                                                                 .removeFavorite],
                                                               shouldPreviewLatestContent: shouldPreviewLatestContent)
                coordinator.start()
                self.filePreviewCoordinator = coordinator

            default:
                AlfrescoLog.error("Unable to show preview for unknown node type")
            }
        }
    }

    func showActionSheetForListItem(for node: ListNode,
                                    from dataSource: ListComponentDataSourceProtocol,
                                    delegate: NodeActionsViewModelDelegate) {
        if let navigationViewController = self.navigationViewController {
            let actionMenuViewModel: ActionMenuViewModel

            if dataSource === offlineDataSource?.resultsViewModel {
                actionMenuViewModel = ActionMenuViewModel(node: node,
                                                              coordinatorServices: coordinatorServices)
            } else {
                actionMenuViewModel = ActionMenuViewModel(node: node,
                                                          coordinatorServices: coordinatorServices,
                                                          excludedActionTypes: [.moveTrash,
                                                                                .addFavorite,
                                                                                .removeFavorite])
            }

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
