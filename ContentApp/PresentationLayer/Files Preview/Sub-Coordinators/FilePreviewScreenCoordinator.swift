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
        let accountService = serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService
        let themingService = serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        let filePreviewViewModel = FilePreviewViewModel(node: listNode, with: accountService)
        let viewController = FilePreviewViewController.instantiateViewController()
        viewController.filePreviewCoordinatorDelegate = self

        filePreviewViewModel.viewModelDelegate = viewController
        viewController.themingService = themingService
        viewController.filePreviewViewModel = filePreviewViewModel
        viewController.title = listNode.title
        previewViewController = viewController
        presenter.pushViewController(viewController, animated: true)
    }
}

extension FilePreviewScreenCoordinator: FilePreviewScreenCoordinatorDelegate {
    func navigateBack() {
        presenter.popViewController(animated: true)
    }
}
