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

class FavoritesScreenCoordinator: ListCoordinatorProtocol {

    private let presenter: TabBarMainViewController
    private var favoritesViewController: FavoritesViewController?
    private var navigationViewController: UINavigationController?
    private var folderDrillDownCoordinator: FolderChildrenScreenCoordinator?
    private var previewFileCoordinator: PreviewFileScreenCoordinator?

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }

    func start() {
        let accountService = self.serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService
        let themingService = self.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        let viewController = FavoritesViewController()

        let resultViewModel = ResultsViewModel()
        let foldersAndFilesViewModel = FavoritesViewModel.init(with: accountService, listRequest: nil)
        foldersAndFilesViewModel.listCondition = kWhereFavoritesFileFolderCondition
        let librariesViewModel = FavoritesViewModel.init(with: accountService, listRequest: nil)
        librariesViewModel.listCondition = kWhereFavoritesSiteCondition
        let globalSearchViewModel = GlobalSearchViewModel(accountService: accountService)
        globalSearchViewModel.delegate = resultViewModel
        resultViewModel.delegate = globalSearchViewModel

        viewController.title = LocalizationConstants.ScreenTitles.favorites
        viewController.themingService = themingService
        viewController.folderDrillDownScreenCoordinatorDelegate = self
        viewController.tabBarScreenDelegate = presenter
        viewController.folderAndFilesListViewModel = foldersAndFilesViewModel
        viewController.librariesListViewModel = librariesViewModel
        viewController.searchViewModel = globalSearchViewModel
        viewController.resultViewModel = resultViewModel

        let navigationViewController = UINavigationController(rootViewController: viewController)
        presenter.viewControllers?.append(navigationViewController)
        self.navigationViewController = navigationViewController
        self.favoritesViewController = viewController
    }

    func scrollToTopOrPopToRoot() {
        if navigationViewController?.viewControllers.count == 1 {
            favoritesViewController?.scrollToTop()
        } else {
            navigationViewController?.popToRootViewController(animated: true)
        }
        favoritesViewController?.cancelSearchMode()
    }
}

extension FavoritesScreenCoordinator: FolderDrilDownScreenCoordinatorDelegate {
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
