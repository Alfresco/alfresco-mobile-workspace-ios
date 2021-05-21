//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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
import Photos

class PhotoLibraryScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private let parentListNode: ListNode
    private var galleryDataSource: PhotoGalleryDataSource?

    init(with presenter: UINavigationController,
         parentListNode: ListNode) {
        self.parentListNode = parentListNode
        self.presenter = presenter
    }
    
    func start() {
        let viewController = PhotoGalleryViewController.instantiateViewController()
        viewController.cameraDelegate = self
        viewController.modalPresentationStyle = .fullScreen

        requestAuthorizationPhotoLibraryUsage { [weak self] (granted) in
            if granted {
                DispatchQueue.main.async {
                    guard let sSelf = self else { return }
                    let accountIdentifier = sSelf.coordinatorServices.accountService?.activeAccount?.identifier ?? ""
                    let uploadFilePath = DiskService.uploadFolderPath(for: accountIdentifier)
                    sSelf.galleryDataSource = PhotoGalleryDataSource(folderToSavePath: uploadFilePath)
                    viewController.photoGalleryDataSource = sSelf.galleryDataSource
                    sSelf.presenter.present(viewController,
                                            animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    guard let sSelf = self else { return }
                    let privacyVC = PrivacyNoticeViewController.instantiateViewController()
                    privacyVC.viewModel = PrivacyNoticePhotosModel()
                    privacyVC.coordinatorServices = sSelf.coordinatorServices
                    sSelf.presenter.present(privacyVC,
                                            animated: true)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func requestAuthorizationPhotoLibraryUsage(completion: @escaping ((_ granted: Bool) -> Void)) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                completion(status == .authorized)
            }
        default:
            completion(false)
        }
    }
}

extension PhotoLibraryScreenCoordinator: CameraKitCaptureDelegate {
    func didEndReview(for capturedAssets: [CapturedAsset]) {

        if !capturedAssets.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                guard let sSelf = self else { return }
                Snackbar.display(with: LocalizationConstants.Approved.uploadMedia,
                                 type: .approve,
                                 presentationHostViewOverride: sSelf.presenter.viewControllers.last?.view,
                                 finish: nil)
            })
        }
        
        var uploadTransfers: [UploadTransfer] = []
        
        for capturedAsset in capturedAssets {
            let assetURL = URL(fileURLWithPath: capturedAsset.path)
            let accountIdentifier = coordinatorServices.accountService?.activeAccount?.identifier ?? ""

            _ = DiskService.uploadFolderPath(for: accountIdentifier) +
                "/" + assetURL.lastPathComponent

            let uploadTransfer = UploadTransfer(parentNodeId: parentListNode.guid,
                                                nodeName: capturedAsset.fileName,
                                                extensionType: capturedAsset.type.ext,
                                                mimetype: capturedAsset.type.mimetype,
                                                nodeDescription: capturedAsset.description,
                                                localFilenamePath: assetURL.lastPathComponent)
            uploadTransfers.append(uploadTransfer)
        }

        let uploadTransferDataAccessor = UploadTransferDataAccessor()
        uploadTransferDataAccessor.store(uploadTransfers: uploadTransfers)

        triggerUpload()
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
