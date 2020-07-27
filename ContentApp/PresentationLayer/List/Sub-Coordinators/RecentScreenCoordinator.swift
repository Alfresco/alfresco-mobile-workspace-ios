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
    private var folderChildrenScreenCoodrinator: FolderChildrenScreenCoodrinator?

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }

    func start() {
        let viewController = ListViewController.instantiateViewController()
        viewController.title = LocalizationConstants.ScreenTitles.recent
        viewController.themingService = self.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        viewController.folderDrilDownScreenCoodrinatorDelegate = self
        let accountService = self.serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService
        viewController.listViewModel = RecentViewModel(with: accountService, listRequest: nil)
        viewController.searchViewModel = GlobalSearchViewModel(accountService: accountService)
        viewController.tabBarScreenDelegate = presenter

        let navigationViewController = UINavigationController(rootViewController: viewController)
        presenter.viewControllers = [navigationViewController]
        self.navigationViewController = navigationViewController
        self.recentViewController = viewController
    }

    func scrollToTop() {
        recentViewController?.scrollToTop()
    }

    func popToRoot() {

    }
}

extension RecentScreenCoordinator: FolderDrilDownScreenCoodrinatorDelegate {
    func showScreen(from node: ListNode) {
        if let navigationViewController = self.navigationViewController {
            let folderChildrenScreenCoodrinator = FolderChildrenScreenCoodrinator(with: navigationViewController, listNode: node)
            folderChildrenScreenCoodrinator.start()
            self.folderChildrenScreenCoodrinator = folderChildrenScreenCoodrinator
        }
    }
}
