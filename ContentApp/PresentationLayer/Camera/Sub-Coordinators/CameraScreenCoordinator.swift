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
import AVFoundation

class CameraScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var navigationViewController: UINavigationController?
    private let parentListNode: ListNode
    private var mediaFilesFolderPath: String?
    
    init(with presenter: UINavigationController,
         parentListNode: ListNode) {
        self.presenter = presenter
        self.parentListNode = parentListNode
    }
    
    func start() {
        let viewController = CameraViewController.instantiateViewController()
        let accountIdentifier = coordinatorServices.accountService?.activeAccount?.identifier ?? ""
        let folderPath = DiskService.mediaFolderPath(for: accountIdentifier)
        let cameraViewModel = CameraViewModel(folderToSavePath: folderPath)
        mediaFilesFolderPath = folderPath
        
        viewController.cameraViewModel = cameraViewModel
        viewController.cameraDelegate = self
        
        let navigationViewController = UINavigationController(rootViewController: viewController)
        navigationViewController.modalPresentationStyle = .fullScreen
        
        self.navigationViewController = navigationViewController
        
        requestAuthorizationForCameraUsage { [weak self] (granted) in
            if granted {
                DispatchQueue.main.async {
                    guard let sSelf = self else { return }
                    sSelf.presenter.present(navigationViewController,
                                            animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    guard let sSelf = self else { return }
                    let privacyVC = PrivacyNoticeViewController.instantiateViewController()
                    privacyVC.viewModel = PrivacyNoticeCameraModel()
                    privacyVC.coordinatorServices = sSelf.coordinatorServices
                    sSelf.presenter.present(privacyVC,
                                            animated: true,
                                            completion: nil)
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
}

extension CameraScreenCoordinator: CameraKitCaptureDelegate {
    func didEndReview(for capturedAsset: CapturedAsset) {
        if let mediaPath = mediaFilesFolderPath {
            let assetURL = URL(fileURLWithPath: capturedAsset.path)
            let accountIdentifier = coordinatorServices.accountService?.activeAccount?.identifier ?? ""

            let uploadFilePath = DiskService.uploadFolderPath(for: accountIdentifier) +
                "/" + assetURL.lastPathComponent
            _ = DiskService.copy(itemAtPath: capturedAsset.path, to: uploadFilePath)
            _ = DiskService.delete(itemAtPath: mediaPath)

            let uploadTransfer = UploadTransfer(parentNodeId: parentListNode.guid,
                                                nodeName: capturedAsset.fileName,
                                                extensionType: capturedAsset.type.ext,
                                                mimetype: capturedAsset.type.mimetype,
                                                nodeDescription: capturedAsset.description,
                                                localFilenamePath: assetURL.lastPathComponent)
            let uploadTransferDataAccessor = UploadTransferDataAccessor()
            uploadTransferDataAccessor.store(uploadTransfer: uploadTransfer)

            triggerUpload()
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
