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

class BrowseTopLevelFolderScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var listViewController: ListViewController?
    private var browseNode: BrowseNode
    private var folderDrillDownCoordinatorDelegate: FolderChildrenScreenCoordinator?

    init(with presenter: UINavigationController, browseNode: BrowseNode) {
        self.presenter = presenter
        self.browseNode = browseNode
    }

    func start() {
        let router = self.serviceRepository.service(of: Router.serviceIdentifier) as? Router
        router?.register(route: NavigationRoutes.folderScreen.path, factory: { [weak self] (_, _) -> UIViewController? in
            guard let sSelf = self else { return nil }

            let viewController = ListViewController.instantiateViewController()
            viewController.title = sSelf.browseNode.title
            viewController.themingService = sSelf.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
            viewController.folderDrilDownScreenCoodrinatorDelegate = self

            let accountService = sSelf.serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService
            let listViewModel: ListViewModelProtocol

            switch sSelf.browseNode.type {
            case .personalFiles:
                listViewModel = PersonalFileViewModel(with: accountService, listRequest: nil)
            case .myLibraries:
                listViewModel = MyLibrariesViewModel(with: accountService, listRequest: nil)
            case .shared:
                listViewModel = SharedViewModel(with: accountService, listRequest: nil)
            case .trash:
                listViewModel = TrashViewModel(with: accountService, listRequest: nil)
            }
            viewController.listViewModel = listViewModel
            viewController.searchViewModel = GlobalSearchViewModel(accountService: accountService)
            sSelf.listViewController = viewController
            return viewController
        })

        router?.push(route: NavigationRoutes.folderScreen.path, from: presenter)
    }
}

extension BrowseTopLevelFolderScreenCoordinator: FolderDrilDownScreenCoodrinatorDelegate {
    func showScreen(from node: ListNode) {
        let folderDrillDownCoordinatorDelegate = FolderChildrenScreenCoordinator(with: self.presenter, listNode: node)
        folderDrillDownCoordinatorDelegate.start()
        self.folderDrillDownCoordinatorDelegate = folderDrillDownCoordinatorDelegate
    }
}
