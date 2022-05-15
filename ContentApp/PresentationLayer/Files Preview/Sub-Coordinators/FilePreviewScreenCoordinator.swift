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

protocol FilePreviewScreenCoordinatorDelegate: AnyObject {
    func navigateBack()
    func showActionSheetForListItem(node: ListNode, delegate: NodeActionsViewModelDelegate)
}

class FilePreviewScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var filePreviewViewController: FilePreviewViewController?
    private var listNode: ListNode
    private var actionMenuCoordinator: ActionMenuScreenCoordinator?
    private let excludedActionsTypes: [ActionMenuType]
    private let shouldPreviewLatestContent: Bool
    private let isLocalFilePreview: Bool
    private let isScannedDocument: Bool

    init(with presenter: UINavigationController,
         listNode: ListNode,
         excludedActions: [ActionMenuType] = [],
         shouldPreviewLatestContent: Bool = true,
         isLocalFilePreview: Bool = false,
         isScannedDocument: Bool = false) {
        self.presenter = presenter
        self.listNode = listNode
        self.excludedActionsTypes = excludedActions
        self.shouldPreviewLatestContent = shouldPreviewLatestContent
        self.isLocalFilePreview = isLocalFilePreview
        self.isScannedDocument = isScannedDocument
    }

    func start() {
        let viewController = FilePreviewViewController.instantiateViewController()

        let filePreviewViewModel = FilePreviewViewModel(with: listNode,
                                                        delegate: viewController,
                                                        coordinatorServices: coordinatorServices,
                                                        excludedActions: excludedActionsTypes,
                                                        shouldPreviewLatestContent: shouldPreviewLatestContent,
                                                        isLocalFilePreview: isLocalFilePreview,
                                                        isScannedDocument: isScannedDocument)
        viewController.filePreviewCoordinatorDelegate = self
        viewController.coordinatorServices = coordinatorServices
        viewController.filePreviewViewModel = filePreviewViewModel
        
        eventBusService?.register(observer: filePreviewViewModel,
                                          for: FavouriteEvent.self,
                                          nodeTypes: [.file])
        
        eventBusService?.register(observer: filePreviewViewModel,
                                          for: SyncStatusEvent.self,
                                          nodeTypes: [.file])

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
              let actionMenuViewModel = filePreviewViewController.filePreviewViewModel?.actionMenuViewModel,
              let nodeActionsViewModel = filePreviewViewController.filePreviewViewModel?.nodeActionsViewModel else { return }
        nodeActionsViewModel.moveDelegate = self
        let coordinator = ActionMenuScreenCoordinator(with: presenter,
                                                      actionMenuViewModel: actionMenuViewModel,
                                                      nodeActionViewModel: nodeActionsViewModel) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.filePreviewViewController?.allowInterfaceRotation()
        }
        coordinator.start()
        actionMenuCoordinator = coordinator
    }
}

extension FilePreviewScreenCoordinator: NodeActionMoveDelegate {
    func didSelectMoveFile(node: ListNode?, action: ActionMenu) {
        let navigationViewController = self.presenter
        let controller = FilesandFolderListViewController.instantiateViewController()
        controller.sourceNodeToMove = node
        let navController = UINavigationController(rootViewController: controller)
        navigationViewController.present(navController, animated: true)
    }
}

