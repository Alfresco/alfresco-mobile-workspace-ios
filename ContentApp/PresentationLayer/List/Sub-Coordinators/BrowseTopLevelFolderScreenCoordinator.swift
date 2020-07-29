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
    private var folderDrillDownCoordinator: FolderChildrenScreenCoordinator?

    init(with presenter: UINavigationController, browseNode: BrowseNode) {
        self.presenter = presenter
        self.browseNode = browseNode
    }

    func start() {
        let router = self.serviceRepository.service(of: Router.serviceIdentifier) as? Router
        let routerPath = NavigationRoutes.browseScreen.path + "/<nodeTitle>" + "/<nodeID>"
        router?.register(route: routerPath, factory: { [weak self] (_, parameters) -> UIViewController? in
            guard let sSelf = self else { return nil }

            let viewController = ListViewController.instantiateViewController()
            viewController.title = parameters["nodeTitle"] as? String ?? ""
            viewController.themingService = sSelf.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
            viewController.folderDrillDownScreenCoordinatorDelegate = self

            let accountService = sSelf.serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService
            let listViewModel: ListViewModelProtocol

            switch BrowseType(rawValue: parameters["nodeID"] as? String ?? "PersonalFiles") {
            case .personalFiles:
                listViewModel = PersonalFileViewModel(with: accountService, listRequest: nil)
            case .myLibraries:
                listViewModel = MyLibrariesViewModel(with: accountService, listRequest: nil)
            case .shared:
                listViewModel = SharedViewModel(with: accountService, listRequest: nil)
            case .trash:
                listViewModel = TrashViewModel(with: accountService, listRequest: nil)
            case .none:
                listViewModel = PersonalFileViewModel(with: accountService, listRequest: nil)
            }
            viewController.listViewModel = listViewModel
            viewController.searchViewModel = GlobalSearchViewModel(accountService: accountService)
            sSelf.listViewController = viewController
            return viewController
        })
        let routerPathValues = NavigationRoutes.browseScreen.path + "/\(browseNode.title)" + "/\(browseNode.type.rawValue)"
        router?.push(route: routerPathValues, from: presenter)
    }
}

extension BrowseTopLevelFolderScreenCoordinator: FolderDrilDownScreenCoordinatorDelegate {
    func showScreen(from node: ListNode) {
        let folderDrillDownCoordinatorDelegate = FolderChildrenScreenCoordinator(with: self.presenter, listNode: node)
        folderDrillDownCoordinatorDelegate.start()
        self.folderDrillDownCoordinator = folderDrillDownCoordinatorDelegate
    }
}
