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
    func saveScannedDocument(for node: ListNode?, delegate: CreateNodeViewModelDelegate?)
    func renameNodeForListItem(for node: ListNode?, actionMenu: ActionMenu,
                               delegate: CreateNodeViewModelDelegate?)
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
    private var createNodeSheetCoordinator: CreateNodeSheetCoordinator?
    weak var createNodeCoordinatorDelegate: CreateNodeCoordinatorDelegate?

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
    
    func saveScannedDocument(for node: ListNode?, delegate: CreateNodeViewModelDelegate?) {
        if let node = node {
            let actionMenu = ActionMenu(title: LocalizationConstants.ActionMenu.scanDocuments, type: .scanDocuments)
            let coordinator = CreateNodeSheetCoordinator(with: self.presenter,
                                                         actionMenu: actionMenu,
                                                         parentListNode: node,
                                                         createNodeViewModelDelegate: delegate,
                                                         createNodeViewType: .scanDocument)
            coordinator.createNodeCoordinatorDelegate = self
            coordinator.start()
            createNodeSheetCoordinator = coordinator
        }
    }
    
    func renameNodeForListItem(for node: ListNode?, actionMenu: ActionMenu,
                               delegate: CreateNodeViewModelDelegate?) {
        if let node = node {
            let navigationViewController = self.presenter
            let coordinator = CreateNodeSheetCoordinator(with: navigationViewController,
                                                         actionMenu: actionMenu,
                                                         parentListNode: node,
                                                         createNodeViewModelDelegate: delegate,
                                                         createNodeViewType: .rename)
            coordinator.start()
            createNodeSheetCoordinator = coordinator
        }
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

// MARK: - Scanned document delegate
extension FilePreviewScreenCoordinator: CreateNodeCoordinatorDelegate {
    func saveScannedDocument(with title: String?, description: String?) {
        if let node = filePreviewViewController?.filePreviewViewModel?.listNode {
            let nodeTitle = node.title
            var extensionType = ""
            let titleArray = nodeTitle.components(separatedBy: ".")
            if titleArray.count > 1 {
                extensionType = titleArray[1]
            }
            
            let uploadTransfer = UploadTransfer(parentNodeId: node.parentGuid ?? "",
                                                nodeName: title ?? "",
                                                extensionType: extensionType,
                                                mimetype: node.mimeType ?? "",
                                                nodeDescription: "",
                                                localFilenamePath: node.uploadLocalPath ?? "")
            
            let uploadTransferDataAccessor = UploadTransferDataAccessor()
            uploadTransferDataAccessor.store(uploadTransfers: [uploadTransfer])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                guard let sSelf = self else { return }
                Snackbar.display(with: LocalizationConstants.Approved.uploadDocument,
                                 type: .approve,
                                 presentationHostViewOverride: sSelf.presenter.viewControllers.last?.view,
                                 finish: nil)
            })
            triggerUpload()
            navigateBack()
        }
    }
    
    func triggerUpload() {
        let connectivityService = coordinatorServices.connectivityService
        let syncTriggersService = coordinatorServices.syncTriggersService
        syncTriggersService?.triggerSync(for: .userDidInitiateUploadTransfer)

        if connectivityService?.status == .cellular &&
            UserProfile.allowSyncOverCellularData == false {
            syncTriggersService?.showOverrideSyncOnCellularDataDialog(for: .userDidInitiateUploadTransfer)
        }
    }
}
