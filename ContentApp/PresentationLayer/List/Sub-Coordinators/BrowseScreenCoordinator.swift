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
    private var previewFileCoordinator: PreviewFileScreenCoordinator?

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }

    func start() {
        let accountService = self.serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService
        let themingService = self.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        let viewController = BrowseViewController.instantiateViewController()

        let resultViewModel = ResultsViewModel()
        let globalSearchViewModel = GlobalSearchViewModel(accountService: accountService)
        globalSearchViewModel.delegate = resultViewModel
        resultViewModel.delegate = globalSearchViewModel
        let browseViewModel = BrowseViewModel()

        viewController.title = LocalizationConstants.ScreenTitles.browse
        viewController.themingService = themingService
        viewController.folderDrillDownScreenCoordinatorDelegate = self
        viewController.browseScreenCoordinatorDelegate = self
        viewController.tabBarScreenDelegate = presenter
        viewController.listViewModel = browseViewModel
        viewController.searchViewModel = globalSearchViewModel
        viewController.resultViewModel = resultViewModel

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
    func showTopLevelFolderScreen(from browseNode: BrowseNode) {
        if let navigationViewController = self.navigationViewController {
            let staticFolderScreenCoordinator = BrowseTopLevelFolderScreenCoordinator(with: navigationViewController, browseNode: browseNode)
            staticFolderScreenCoordinator.start()
            self.browseTopLevelFolderScreenCoordinator = staticFolderScreenCoordinator
        }
    }
}

extension BrowseScreenCoordinator: FolderDrilDownScreenCoordinatorDelegate {
    func showPreview(from node: ListNode) {
        if let navigationViewController = self.navigationViewController {
            switch node.kind {
            case .folder, .site:
                let folderDrillDownCoordinator = FolderChildrenScreenCoordinator(with: navigationViewController, listNode: node)
                folderDrillDownCoordinator.start()
                self.folderDrillDownCoordinator = folderDrillDownCoordinator
            case .file:
                let previewFileCoordinator = PreviewFileScreenCoordinator(with: navigationViewController, listNode: node)
                previewFileCoordinator.start()
                self.previewFileCoordinator = previewFileCoordinator
            }
        }
    }
}
