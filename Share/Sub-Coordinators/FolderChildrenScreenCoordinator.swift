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

protocol FolderChildrenScreenCoordinatorDelegate: AnyObject {
    func updateListNode(with node: ListNode)
}

class FolderChildrenScreenCoordinator: PresentingCoordinator {
    private let presenter: UINavigationController
    private var listNode: ListNode
    private var model: FolderDrillModel?
    private var fileManagerDataSource: FileManagerDataSource?
    var listController: ListViewController?

    init(with presenter: UINavigationController, listNode: ListNode) {
        self.presenter = presenter
        self.listNode = listNode
    }

    override func start() {
        let viewModelFactory = FolderChildrenViewModelFactory(services: coordinatorServices)
        let folderChildrenDataSource = viewModelFactory.folderChildrenDataSource(for: listNode)
        self.model = viewModelFactory.model
        self.model?.folderChildrenDelegate = self

        let viewController = ListViewController()
        viewController.title = listNode.title
        viewController.fileManagerDelegate = self
        viewController.isChildFolder = true

        let accountIdentifier = self.coordinatorServices.accountService?.activeAccount?.identifier ?? ""
        let uploadFilePath = DiskService.uploadFolderPath(for: accountIdentifier)
        self.fileManagerDataSource = FileManagerDataSource(folderToSavePath: uploadFilePath)
        viewController.fileManagerDataSource = self.fileManagerDataSource

        let viewModel = folderChildrenDataSource.folderDrillDownViewModel
        let pageController = ListPageController(dataSource: viewModel.model,
                                                services: coordinatorServices)

        let searchViewModel = folderChildrenDataSource.contextualSearchViewModel
        let searchPageController = ListPageController(dataSource: searchViewModel.searchModel,
                                                      services: coordinatorServices)

        viewController.pageController = pageController
        viewController.searchPageController = searchPageController
        viewController.viewModel = viewModel
        viewController.searchViewModel = searchViewModel

        viewController.coordinatorServices = coordinatorServices
        viewController.listItemActionDelegate = self
        self.listController = viewController
        presenter.pushViewController(viewController, animated: true)
    }
}

extension FolderChildrenScreenCoordinator: ListItemActionDelegate {
    func showPreview(for node: ListNode,
                     from dataSource: ListComponentModelProtocol) {
        if node.isAFolderType() || node.nodeType == .site {
            startFolderCoordinator(for: node,
                                   presenter: self.presenter)
        } else {
            AlfrescoLog.error("Unable to show preview for unknown node type")
        }
    }
}

extension FolderChildrenScreenCoordinator: FolderChildrenScreenCoordinatorDelegate {
    func updateListNode(with node: ListNode) {
        self.listNode = node
    }
}

// MARK: - File manager delegate
extension FolderChildrenScreenCoordinator: FileManagerAssetDelegate {
    func didEndFileManager(for selectedAssets: [FileAsset]) {
        
        guard let accountIdentifier = coordinatorServices.accountService?.activeAccount?.identifier
        else { return }
        var uploadTransfers: [UploadTransfer] = []
        for fileAsset in selectedAssets {
            let assetURL = URL(fileURLWithPath: fileAsset.path)
            _ = DiskService.uploadFolderPath(for: accountIdentifier) +
                "/" + assetURL.lastPathComponent
            
            let uploadTransfer = UploadTransfer(parentNodeId: listNode.guid,
                                                nodeName: fileAsset.fileName ?? "",
                                                extensionType: fileAsset.fileExtension ?? "",
                                                mimetype: assetURL.mimeType(),
                                                nodeDescription: fileAsset.description,
                                                localFilenamePath: assetURL.lastPathComponent,
                                                fullFilePath: fileAsset.path)
            uploadTransfers.append(uploadTransfer)
        }

        let uploadTransferDataAccessor = UploadTransferDataAccessor()
        uploadTransferDataAccessor.store(uploadTransfers: uploadTransfers)
        
        // --- save data ------
        SyncSharedNodes.store(uploadTransfers: uploadTransfers)
        
        // ---  trigger upload ----
        triggerUpload()
    }
    
    func triggerUpload() {
        let syncTriggersService = coordinatorServices.syncTriggersService
        syncTriggersService?.showOverrideSyncOnAlfrescoMobileAppDialog(for: .userDidInitiateUploadTransfer, on: self.listController)
    }
}
