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

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }

    func start() {
        let accountService = repository.service(of: AccountService.identifier) as? AccountService
        let themingService = repository.service(of: MaterialDesignThemingService.identifier) as? MaterialDesignThemingService
        let eventBusService = repository.service(of: EventBusService.identifier) as? EventBusService
        let viewController = ListViewController()

        let listViewModel = RecentViewModel(with: accountService,
                                            listRequest: nil)
        let resultViewModel = ResultsViewModel()
        let globalSearchViewModel = GlobalSearchViewModel(accountService: accountService)
        globalSearchViewModel.delegate = resultViewModel
        resultViewModel.delegate = globalSearchViewModel

        viewController.title = LocalizationConstants.ScreenTitles.recent
        viewController.themingService = themingService
        viewController.eventBusService = eventBusService
        viewController.listViewModel = listViewModel
        viewController.tabBarScreenDelegate = presenter
        viewController.listItemActionDelegate = self
        viewController.searchViewModel = globalSearchViewModel
        viewController.resultViewModel = resultViewModel

        eventBusService?.register(observer: resultViewModel, for: FavouriteEvent.self)
        eventBusService?.register(observer: listViewModel, for: FavouriteEvent.self)

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
    func showPreview(from node: ListNode) {
        if let navigationViewController = self.navigationViewController {
            switch node.kind {
            case .folder, .site:
                let folderDrillDownCoordinator = FolderChildrenScreenCoordinator(with: navigationViewController, listNode: node)
                folderDrillDownCoordinator.start()
                self.folderDrillDownCoordinator = folderDrillDownCoordinator
            case .file:
                let filePreviewCoordinator = FilePreviewScreenCoordinator(with: navigationViewController, listNode: node)
                filePreviewCoordinator.start()
                self.filePreviewCoordinator = filePreviewCoordinator
            }
        }
    }

    func showActionSheetForListItem(node: ListNode, delegate: NodeActionsViewModelDelegate) {
        if let navigationViewController = self.navigationViewController {
            let menu = ActionsMenuGenericMoreButton(with: node)
            let accountService = repository.service(of: AccountService.identifier) as? AccountService
            let actionMenuViewModel = ActionMenuViewModel(with: menu)
            let nodeActionsModel = NodeActionsViewModel(node: node,
                                                        accountService: accountService,
                                                        delegate: delegate)
            let coordinator = ActionMenuScreenCoordinator(with: navigationViewController,
                                                          actionMenuViewModel: actionMenuViewModel,
                                                          nodeActionViewModel: nodeActionsModel)
            coordinator.start()
        }
    }
}
