//
// Copyright (C) 2005-2022 Alfresco Software Limited.
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
import MobileCoreServices

class FileManagerScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private let parentListNode: ListNode
    private var fileManagerDataSource: FileManagerDataSource?
    var attachmentType: AttachmentType
    var didSelectAttachment: (([UploadTransfer]) -> Void)?
    var multiSelection = true

    init(with presenter: UINavigationController,
         parentListNode: ListNode,
         attachmentType: AttachmentType) {
        self.parentListNode = parentListNode
        self.presenter = presenter
        self.attachmentType = attachmentType
    }
    
    func start() {
        let viewController = FileManagerViewController.instantiateViewController()
        viewController.fileManagerDelegate = self
        viewController.multiSelection = multiSelection
        viewController.modalPresentationStyle = .fullScreen
        viewController.attachmentType = self.attachmentType
        
        let accountIdentifier = self.coordinatorServices.accountService?.activeAccount?.identifier ?? ""
        let uploadFilePath = DiskService.uploadFolderPath(for: accountIdentifier)
        self.fileManagerDataSource = FileManagerDataSource(folderToSavePath: uploadFilePath)
        viewController.fileManagerDataSource = self.fileManagerDataSource
        self.presenter.present(viewController, animated: true)
    }
}

extension FileManagerScreenCoordinator: FileManagerAssetDelegate {
    func didEndFileManager(for selectedAssets: [FileAsset]) {
        
        guard let accountIdentifier = coordinatorServices.accountService?.activeAccount?.identifier
        else { return }

        if !selectedAssets.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                guard let sSelf = self else { return }
                Snackbar.display(with: LocalizationConstants.Approved.uploadMedia,
                                 type: .approve,
                                 presentationHostViewOverride: sSelf.presenter.viewControllers.last?.view,
                                 finish: nil)
            })
        }
        
        var uploadTransfers: [UploadTransfer] = []
        for fileAsset in selectedAssets {
            let assetURL = URL(fileURLWithPath: fileAsset.path)
            _ = DiskService.uploadFolderPath(for: accountIdentifier) +
                "/" + assetURL.lastPathComponent
            
            let uploadTransfer = UploadTransfer(parentNodeId: parentListNode.guid,
                                                nodeName: fileAsset.fileName ?? "",
                                                extensionType: fileAsset.fileExtension ?? "",
                                                mimetype: assetURL.mimeType(),
                                                nodeDescription: fileAsset.description,
                                                localFilenamePath: assetURL.lastPathComponent,
                                                attachmentType: self.attachmentType)
            uploadTransfers.append(uploadTransfer)
        }

        let uploadTransferDataAccessor = UploadTransferDataAccessor()
        uploadTransferDataAccessor.store(uploadTransfers: uploadTransfers)

        if attachmentType != .workflow {
            triggerUpload()
        } else {
            didSelectAttachment?(uploadTransfers)
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
