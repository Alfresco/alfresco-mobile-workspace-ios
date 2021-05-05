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
                    let mediaFolderPath = DiskService.mediaFolderPath(for: accountIdentifier)
                    sSelf.galleryDataSource = PhotoGalleryDataSource(mediaFilesFolderPath: mediaFolderPath)
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
    func didEndReview(for capturedAsset: CapturedAsset) {
        let assetURL = URL(fileURLWithPath: capturedAsset.path)
        let accountIdentifier = coordinatorServices.accountService?.activeAccount?.identifier ?? ""

        let uploadFilePath = DiskService.uploadFolderPath(for: accountIdentifier) +
            "/" + assetURL.lastPathComponent
        _ = DiskService.copy(itemAtPath: capturedAsset.path, to: uploadFilePath)

        let uploadTransfer = UploadTransfer(parentNodeId: parentListNode.guid,
                                            nodeName: capturedAsset.fileName,
                                            nodeDescription: capturedAsset.description,
                                            filePath: uploadFilePath)
        let uploadTransferDataAccessor = UploadTransferDataAccessor()
        uploadTransferDataAccessor.store(uploadTransfer: uploadTransfer)

        let syncTriggersService = coordinatorServices.syncTriggersService
        syncTriggersService?.triggerSync(for: .userDidInitiateUploadTransfer)
    }
}