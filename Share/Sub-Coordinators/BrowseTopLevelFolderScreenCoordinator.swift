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

class BrowseTopLevelFolderScreenCoordinator: PresentingCoordinator {
    private let presenter: UINavigationController
    private var browseNode: BrowseNode
    private var fileManagerDataSource: FileManagerDataSource?
    private var createNodeSheetCoordinator: CreateNodeSheetCoordinator?
    var listController: ListViewController?

    init(with presenter: UINavigationController, browseNode: BrowseNode) {
        self.presenter = presenter
        self.browseNode = browseNode
    }
    
    override func start() {
        let viewModelFactory = TopLevelBrowseViewModelFactory(services: coordinatorServices)
        let topLevelBrowseDataSource = viewModelFactory.topLevelBrowseDataSource(browseNode: browseNode)

        let viewController = ListViewController()
        viewController.title = browseNode.title
        viewController.fileManagerDelegate = self
        viewController.isChildFolder = true
        
        let accountIdentifier = self.coordinatorServices.accountService?.activeAccount?.identifier ?? ""
        let uploadFilePath = DiskService.uploadFolderPath(for: accountIdentifier)
        self.fileManagerDataSource = FileManagerDataSource(folderToSavePath: uploadFilePath)
        viewController.fileManagerDataSource = self.fileManagerDataSource

        let viewModel = topLevelBrowseDataSource.topLevelBrowseViewModel
        let pageController = ListPageController(dataSource: viewModel.model,
                                                services: coordinatorServices)

        let searchViewModel = topLevelBrowseDataSource.globalSearchViewModel
        let searchPageController = ListPageController(dataSource: searchViewModel.searchModel,
                                                      services: coordinatorServices)
        viewController.pageController = pageController
        viewController.searchPageController = searchPageController
        viewController.viewModel = viewModel
        viewController.searchViewModel = searchViewModel
        viewController.coordinatorServices = coordinatorServices
        viewController.listItemActionDelegate = self
        self.listController = viewController
        presenter.pushViewController(viewController, animated: false)
    }
    
    // MARK: - Private interface
    
    func personalFilesNode () -> ListNode {
        return ListNode(guid: APIConstants.my,
                        title: "Personal files",
                        path: "",
                        nodeType: .folder)
    }
}

extension BrowseTopLevelFolderScreenCoordinator: ListItemActionDelegate {
    func showPreview(for node: ListNode,
                     from dataSource: ListComponentModelProtocol) {
        if node.isAFolderType() || node.nodeType == .site {
            startFolderCoordinator(for: node,
                                   presenter: self.presenter)
        } else {
            AlfrescoLog.error("Unable to show preview for unknown node type")
        }
    }

    func showNodeCreationDialog(with actionMenu: ActionMenu,
                                delegate: CreateNodeViewModelDelegate?) {
        let coordinator = CreateNodeSheetCoordinator(with: presenter,
                                                     actionMenu: actionMenu,
                                                     parentListNode: personalFilesNode(),
                                                     createNodeViewModelDelegate: delegate)
        coordinator.start()
        createNodeSheetCoordinator = coordinator
    }
}

// MARK: - File manager delegate
extension BrowseTopLevelFolderScreenCoordinator: FileManagerAssetDelegate {
    func didEndFileManager(for selectedAssets: [FileAsset], isScannedDocument: Bool) {
        
        guard let accountIdentifier = coordinatorServices.accountService?.activeAccount?.identifier
        else { return }
        var uploadTransfers: [UploadTransfer] = []
        for fileAsset in selectedAssets {
            let assetURL = URL(fileURLWithPath: fileAsset.path)
            _ = DiskService.uploadFolderPath(for: accountIdentifier) +
                "/" + assetURL.lastPathComponent
            
            let uploadTransfer = UploadTransfer(parentNodeId: self.personalFilesNode().guid,
                                                nodeName: fileAsset.fileName ?? "",
                                                extensionType: fileAsset.fileExtension ?? "",
                                                mimetype: assetURL.mimeType(),
                                                nodeDescription: fileAsset.description,
                                                localFilenamePath: assetURL.lastPathComponent,
                                                attachmentType: .content)
            uploadTransfers.append(uploadTransfer)
        }

        let uploadTransferDataAccessor = UploadTransferDataAccessor()
        uploadTransferDataAccessor.store(uploadTransfers: uploadTransfers)
        
        // --- save data ------
        SyncSharedNodes.store(uploadTransfers: uploadTransfers)

        // --- trigger upload ----
        triggerUpload()
    }
    
    func triggerUpload() {
        let syncTriggersService = coordinatorServices.syncTriggersService
        syncTriggersService?.showOverrideSyncOnAlfrescoMobileAppDialog(for: .userDidInitiateUploadTransfer, on: self.listController)
    }
}
