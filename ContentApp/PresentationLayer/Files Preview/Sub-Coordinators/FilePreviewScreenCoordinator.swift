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

protocol FilePreviewScreenCoordinatorDelegate: class {
    func navigateBack()
}

class FilePreviewScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var listNode: ListNode
    private var previewViewController: FilePreviewViewController?

    init(with presenter: UINavigationController, listNode: ListNode) {
        self.presenter = presenter
        self.listNode = listNode
    }

    func start() {
        let router = self.serviceRepository.service(of: Router.serviceIdentifier) as? Router
        let routerPath = NavigationRoutes.filePreviewScreen.path + "/<nodeID>"
        router?.register(route: routerPath, factory: { [weak self] (_, _) -> UIViewController? in
            guard let sSelf = self else { return nil }

            let accountService = sSelf.serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService
            let themingService = sSelf.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
            let filePreviewViewModel = FilePreviewViewModel(node: sSelf.listNode, with: accountService)
            let viewController = FilePreviewViewController.instantiateViewController()
            viewController.filePreviewCoordinatorDelegate = self

            filePreviewViewModel.viewModelDelegate = viewController
            viewController.themingService = themingService
            viewController.filePreviewViewModel = filePreviewViewModel
            viewController.title = sSelf.listNode.title
            sSelf.previewViewController = viewController
            return viewController
        })
        let routerPathValues = NavigationRoutes.filePreviewScreen.path + "/\(listNode.guid)"
        router?.push(route: routerPathValues, from: presenter)
    }
}

extension FilePreviewScreenCoordinator: FilePreviewScreenCoordinatorDelegate {
    func navigateBack() {
        presenter.popViewController(animated: true)
    }
}
