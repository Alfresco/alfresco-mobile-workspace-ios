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
    func showScreen(from browseNode: BrowseNode)
}

class BrowseScreenCoordinator: ListCoordinatorProtocol {
    private let presenter: TabBarMainViewController
    private var browseViewController: BrowseViewController?
    private var navigationViewController: UINavigationController?
    private var browseTopLevelFolderScreenCoordinator: BrowseTopLevelFolderScreenCoordinator?
    private var folderDrillDownCoordinator: FolderChildrenScreenCoordinator?

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }

    func start() {
        let accountService = self.serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService
        let themingService = self.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        let viewController = BrowseViewController.instantiateViewController()

        let resultViewModel = ResultsViewModel()
        let globalSearchViewModel = GlobalSearchViewModel(accountService: accountService)
        let browseViewModel = BrowseViewModel()

        viewController.title = LocalizationConstants.ScreenTitles.browse
        viewController.themingService = themingService
        viewController.folderDrillDownScreenCoordinatorDelegate = self
        viewController.browseScreenCoordinatorDelegate = self
        viewController.tabBarScreenDelegate = presenter
        viewController.listViewModel = browseViewModel
        viewController.searchViewModel = globalSearchViewModel
        viewController.resultViewModel = resultViewModel
        globalSearchViewModel.delegate = resultViewModel

        let navigationViewController = UINavigationController(rootViewController: viewController)
        self.presenter.viewControllers?.append(navigationViewController)
        self.navigationViewController = navigationViewController
        self.browseViewController = viewController
    }

    func scrollToTopOrPopToRoot() {
        navigationViewController?.popToRootViewController(animated: true)
        browseViewController?.cancelSearchMode()
    }
}

extension BrowseScreenCoordinator: BrowseScreenCoordinatorDelegate {
    func showScreen(from browseNode: BrowseNode) {
        if let navigationViewController = self.navigationViewController {
            let staticFolderScreenCoordinator = BrowseTopLevelFolderScreenCoordinator(with: navigationViewController, browseNode: browseNode)
            staticFolderScreenCoordinator.start()
            self.browseTopLevelFolderScreenCoordinator = staticFolderScreenCoordinator
        }
    }
}

extension BrowseScreenCoordinator: FolderDrilDownScreenCoordinatorDelegate {
    func showScreen(from node: ListNode) {
        if let navigationViewController = self.navigationViewController {
            let folderDrillDownCoordinatorDelegate = FolderChildrenScreenCoordinator(with: navigationViewController, listNode: node)
            folderDrillDownCoordinatorDelegate.start()
            self.folderDrillDownCoordinator = folderDrillDownCoordinatorDelegate
        }
    }
}
