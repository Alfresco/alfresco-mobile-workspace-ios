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

protocol FolderDrilDownScreenCoodrinatorDelegate: class {
    func showScreen(from node: ListNode)
}

class FolderChildrenScreenCoodrinator: Coordinator {
    private let presenter: UINavigationController
    private var listViewController: ListViewController?
    private var listNode: ListNode
    private var folderChildrenScreenCoodrinator: FolderChildrenScreenCoodrinator?

    init(with presenter: UINavigationController, listNode: ListNode) {
        self.presenter = presenter
        self.listNode = listNode
    }

    func start() {
        let router = self.serviceRepository.service(of: Router.serviceIdentifier) as? Router
        router?.register(route: NavigationRoutes.folderScreen.path, factory: { [weak self] (_, _) -> UIViewController? in
            guard let sSelf = self else { return nil }

            let viewController = ListViewController.instantiateViewController()
            viewController.title = sSelf.listNode.title
            viewController.themingService = sSelf.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
            viewController.folderDrilDownScreenCoodrinatorDelegate = self

            let accountService = sSelf.serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService
            let listViewModel = PersonalFileViewModel(with: accountService, listRequest: nil)
            listViewModel.node = sSelf.listNode
            viewController.listViewModel = listViewModel
            viewController.searchViewModel = GlobalSearchViewModel(accountService: accountService)
            sSelf.listViewController = viewController
            return viewController
        })

        router?.push(route: NavigationRoutes.folderScreen.path, from: presenter)
    }
}

extension FolderChildrenScreenCoodrinator: FolderDrilDownScreenCoodrinatorDelegate {
    func showScreen(from node: ListNode) {
        let folderChildrenScreenCoodrinator = FolderChildrenScreenCoodrinator(with: self.presenter, listNode: node)
        folderChildrenScreenCoodrinator.start()
        self.folderChildrenScreenCoodrinator = folderChildrenScreenCoodrinator
    }
}
