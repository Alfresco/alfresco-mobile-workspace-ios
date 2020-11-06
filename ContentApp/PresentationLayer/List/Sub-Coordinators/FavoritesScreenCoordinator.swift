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
    private var filePreviewCoordinator: FilePreviewScreenCoordinator?

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }

    func start() {
        let accountService = repository.service(of: AccountService.identifier) as? AccountService
        let themingService = repository.service(of: MaterialDesignThemingService.identifier) as? MaterialDesignThemingService

        let viewController = FavoritesViewController()

        let resultViewModel = ResultsViewModel()
        let foldersAndFilesViewModel = FavoritesViewModel.init(with: accountService,
                                                               listRequest: nil)
        let librariesViewModel = FavoritesViewModel.init(with: accountService,
                                                         listRequest: nil)
        let globalSearchViewModel = GlobalSearchViewModel(accountService: accountService)
    
        foldersAndFilesViewModel.listCondition = kWhereFavoritesFileFolderCondition
        librariesViewModel.listCondition = kWhereFavoritesSiteCondition
        globalSearchViewModel.delegate = resultViewModel
        resultViewModel.delegate = globalSearchViewModel

        viewController.title = LocalizationConstants.ScreenTitles.favorites
        viewController.themingService = themingService
        viewController.listItemActionDelegate = self
        viewController.tabBarScreenDelegate = presenter
        viewController.folderAndFilesListViewModel = foldersAndFilesViewModel
        viewController.librariesListViewModel = librariesViewModel
        viewController.searchViewModel = globalSearchViewModel
        viewController.resultViewModel = resultViewModel

        registerForFavouriteEvent(resultViewModel: resultViewModel,
                                  foldersAndFilesViewModel: foldersAndFilesViewModel,
                                  librariesViewModel: librariesViewModel)

        registerForMoveEvent(resultViewModel: resultViewModel,
                             foldersAndFilesViewModel: foldersAndFilesViewModel,
                             librariesViewModel: librariesViewModel)

        let navigationViewController = UINavigationController(rootViewController: viewController)
        presenter.viewControllers?.append(navigationViewController)
        self.navigationViewController = navigationViewController
        favoritesViewController = viewController
    }

    func scrollToTopOrPopToRoot() {
        if navigationViewController?.viewControllers.count == 1 {
            favoritesViewController?.scrollToTop()
        } else {
            navigationViewController?.popToRootViewController(animated: true)
        }
        favoritesViewController?.cancelSearchMode()
    }

    // MARK: - Private interface

    private func registerForFavouriteEvent(resultViewModel: ResultsViewModel,
                                           foldersAndFilesViewModel: FavoritesViewModel,
                                           librariesViewModel: FavoritesViewModel) {
        let eventBusService = repository.service(of: EventBusService.identifier) as? EventBusService

        eventBusService?.register(observer: resultViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: foldersAndFilesViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: librariesViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.site])
    }

    private func registerForMoveEvent(resultViewModel: ResultsViewModel,
                                      foldersAndFilesViewModel: FavoritesViewModel,
                                      librariesViewModel: FavoritesViewModel) {
        let eventBusService = repository.service(of: EventBusService.identifier) as? EventBusService

        eventBusService?.register(observer: resultViewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: foldersAndFilesViewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: librariesViewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.site])
    }
}

extension FavoritesScreenCoordinator: ListItemActionDelegate {
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

    func showActionSheetForListItem(for node: ListNode,
                                    dataSource: ListComponentDataSourceProtocol,
                                    delegate: NodeActionsViewModelDelegate) {
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
