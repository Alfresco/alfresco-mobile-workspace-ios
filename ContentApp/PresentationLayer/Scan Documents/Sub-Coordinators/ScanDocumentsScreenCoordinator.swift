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
import AVFoundation

class ScanDocumentsScreenCoordinator: PresentingCoordinator {
    private let presenter: UINavigationController
    private let parentListNode: ListNode
    private var fileManagerDataSource: FileManagerDataSource?
    private var mediaFilesFolderPath: String?

    init(with presenter: UINavigationController,
         parentListNode: ListNode) {
        self.parentListNode = parentListNode
        self.presenter = presenter
    }
    
    override func start() {
        let viewController = ScanDocumentsViewController.instantiateViewController()
        viewController.fileManagerDelegate = self
        viewController.modalPresentationStyle = .fullScreen
        
        let accountIdentifier = self.coordinatorServices.accountService?.activeAccount?.identifier ?? ""
        let uploadFilePath = DiskService.uploadFolderPath(for: accountIdentifier)
        self.fileManagerDataSource = FileManagerDataSource(folderToSavePath: uploadFilePath)
        viewController.fileManagerDataSource = self.fileManagerDataSource
       
        requestAuthorizationForCameraUsage { [weak self] (granted) in
            if granted {
                DispatchQueue.main.async {
                    guard let sSelf = self else { return }
                    sSelf.presenter.present(viewController,
                                            animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    guard let sSelf = self else { return }
                    sSelf.presentCameraPrivacyNotice()
                }
            }
        }
    }
    
    // MARK: - Private Methods
        
    private func requestAuthorizationForCameraUsage(completion: @escaping ((_ granted: Bool) -> Void)) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        default:
            completion(false)
        }
    }
    
    private func presentCameraPrivacyNotice() {
        let privacyVC = PrivacyNoticeViewController.instantiateViewController()
        privacyVC.viewModel = PrivacyNoticeCameraModel()
        privacyVC.coordinatorServices = coordinatorServices
        presenter.present(privacyVC,
                          animated: true,
                          completion: nil)
    }
}

// MARK: - File manager Delegate
extension ScanDocumentsScreenCoordinator: FileManagerAssetDelegate {
    func didEndFileManager(for selectedAssets: [FileAsset], isScannedDocument: Bool) {
        
        guard let accountIdentifier = coordinatorServices.accountService?.activeAccount?.identifier
        else { return }
        
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
                                                localFilenamePath: assetURL.lastPathComponent)
            uploadTransfers.append(uploadTransfer)
        }

        if let listNode = uploadTransfers.first?.listNode() {
            DispatchQueue.main.async {
                self.showPreview(for: listNode)
            }
        }
    }
}

// MARK: - List Item Action Delegate
extension ScanDocumentsScreenCoordinator {
    func showPreview(for node: ListNode) {
        startFileCoordinator(for: node,
                             presenter: self.presenter)
    }
}
