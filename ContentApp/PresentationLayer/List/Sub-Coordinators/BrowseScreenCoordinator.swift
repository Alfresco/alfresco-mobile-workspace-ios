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

protocol BrowseScreenCoordinatorDelegate: class {
    func showTopLevelFolderScreen(from browseNode: BrowseNode)
}

class BrowseScreenCoordinator: ListCoordinatorProtocol {
    private let presenter: TabBarMainViewController
    private var browseViewController: BrowseViewController?
    private var navigationViewController: UINavigationController?
    private var browseTopLevelFolderScreenCoordinator: BrowseTopLevelFolderScreenCoordinator?
    private var folderDrillDownCoordinator: FolderChildrenScreenCoordinator?
    private var filePreviewCoordinator: FilePreviewScreenCoordinator?

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }

    func start() {
        let accountService = repository.service(of: AccountService.identifier) as? AccountService
        let themingService = repository.service(of: MaterialDesignThemingService.identifier) as? MaterialDesignThemingService
        let eventBusService = repository.service(of: EventBusService.identifier) as? EventBusService
        let viewController = BrowseViewController.instantiateViewController()

        let resultViewModel = ResultsViewModel()
        let globalSearchViewModel = GlobalSearchViewModel(accountService: accountService)
        let browseViewModel = BrowseViewModel()
        globalSearchViewModel.delegate = resultViewModel
        resultViewModel.delegate = globalSearchViewModel

        viewController.title = LocalizationConstants.ScreenTitles.browse
        viewController.themingService = themingService
        viewController.eventBusService = eventBusService
        viewController.listItemActionDelegate = self
        viewController.browseScreenCoordinatorDelegate = self
        viewController.tabBarScreenDelegate = presenter
        viewController.listViewModel = browseViewModel
        viewController.searchViewModel = globalSearchViewModel
        viewController.resultViewModel = resultViewModel

        eventBusService?.register(observer: resultViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder, .site])

        let navigationViewController = UINavigationController(rootViewController: viewController)
        self.presenter.viewControllers?.append(navigationViewController)
        self.navigationViewController = navigationViewController
        browseViewController = viewController
    }

    func scrollToTopOrPopToRoot() {
        navigationViewController?.popToRootViewController(animated: true)
        browseViewController?.cancelSearchMode()
    }
}

extension BrowseScreenCoordinator: BrowseScreenCoordinatorDelegate {
    func showTopLevelFolderScreen(from browseNode: BrowseNode) {
        if let navigationViewController = self.navigationViewController {
            let staticFolderScreenCoordinator =
                BrowseTopLevelFolderScreenCoordinator(with: navigationViewController,
                                                      browseNode: browseNode)
            staticFolderScreenCoordinator.start()
            self.browseTopLevelFolderScreenCoordinator = staticFolderScreenCoordinator
        }
    }
}

extension BrowseScreenCoordinator: ListItemActionDelegate {
    func showPreview(from node: ListNode) {
        if let navigationViewController = self.navigationViewController {
            switch node.kind {
            case .folder, .site:
                let folderDrillDownCoordinator =
                    FolderChildrenScreenCoordinator(with: navigationViewController,
                                                    listNode: node)
                folderDrillDownCoordinator.start()
                self.folderDrillDownCoordinator = folderDrillDownCoordinator
            case .file:
                let filePreviewCoordinator =
                    FilePreviewScreenCoordinator(with: navigationViewController,
                                                 guidListNode: node.guid)
                filePreviewCoordinator.start()
                self.filePreviewCoordinator = filePreviewCoordinator
            }
        }
    }

    func showActionSheetForListItem(node: ListNode, delegate: NodeActionsViewModelDelegate) {
        if let navigationViewController = self.navigationViewController {
            let menu = ActionsMenuGenericMoreButton(with: node)
            let accountService = repository.service(of: AccountService.identifier) as? AccountService
            let eventBusService = repository.service(of: EventBusService.identifier) as? EventBusService
            let actionMenuViewModel = ActionMenuViewModel(with: menu)
            let nodeActionsModel = NodeActionsViewModel(node: node,
                                                        accountService: accountService,
                                                        eventBusService: eventBusService,
                                                        delegate: delegate)
            let coordinator = ActionMenuScreenCoordinator(with: navigationViewController,
                                                          actionMenuViewModel: actionMenuViewModel,
                                                          nodeActionViewModel: nodeActionsModel)
            coordinator.start()
        }
    }
}
