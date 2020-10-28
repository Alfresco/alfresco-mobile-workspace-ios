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
    func showActionSheetForListItem(node: ListNode, delegate: NodeActionsViewModelDelegate)
}

class FilePreviewScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var filePreviewViewController: FilePreviewViewController?
    private var listNode: ListNode

    init(with presenter: UINavigationController, listNode: ListNode) {
        self.presenter = presenter
        self.listNode = listNode
    }

    func start() {
        let accountService = repository.service(of: AccountService.identifier) as? AccountService
        let themingService = repository.service(of: MaterialDesignThemingService.identifier) as? MaterialDesignThemingService
        let eventBusService = repository.service(of: EventBusService.identifier) as? EventBusService
        let viewController = FilePreviewViewController.instantiateViewController()

        let filePreviewViewModel = FilePreviewViewModel(with: listNode,
                                                        accountService: accountService)
        let menu = ActionsMenuFilePreview(with: listNode)
        let actionMenuViewModel = ActionMenuViewModel(with: menu, toolbarDivide: true)
        let nodeActionsViewModel = NodeActionsViewModel(node: listNode,
                                                        accountService: accountService,
                                                        delegate: viewController)

        viewController.filePreviewCoordinatorDelegate = self
        viewController.actionMenuViewModel = actionMenuViewModel
        viewController.nodeActionsViewModel = nodeActionsViewModel

        filePreviewViewModel.viewModelDelegate = viewController
        viewController.themingService = themingService
        viewController.eventBusService = eventBusService
        viewController.filePreviewViewModel = filePreviewViewModel
        viewController.title = listNode.title

        eventBusService?.register(observer: filePreviewViewModel, for: FavouriteEvent.self)

        presenter.pushViewController(viewController, animated: true)
        filePreviewViewController = viewController
    }
}

extension FilePreviewScreenCoordinator: FilePreviewScreenCoordinatorDelegate {
    func navigateBack() {
        presenter.popViewController(animated: true)
    }

    func showActionSheetForListItem(node: ListNode, delegate: NodeActionsViewModelDelegate) {
        guard let filePreviewViewController = filePreviewViewController,
              let actionMenuViewModel = filePreviewViewController.actionMenuViewModel,
              let nodeActionsViewModel = filePreviewViewController.nodeActionsViewModel else { return }
        let coordinator = ActionMenuScreenCoordinator(with: presenter,
                                                      actionMenuViewModel: actionMenuViewModel,
                                                      nodeActionViewModel: nodeActionsViewModel)
        coordinator.start()
    }
}
