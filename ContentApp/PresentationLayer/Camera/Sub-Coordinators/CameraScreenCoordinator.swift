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

class CameraScreenCoordinator: NSObject, Coordinator {
    private let presenter: UINavigationController
    private var navigationViewController: UINavigationController?
    private let parentListNode: ListNode
    private var mediaFilesFolderPath: String?
    var attachmentType: AttachmentType
    var didSelectAttachment: (([UploadTransfer]) -> Void)?

    init(with presenter: UINavigationController,
         parentListNode: ListNode,
         attachmentType: AttachmentType) {
        self.presenter = presenter
        self.parentListNode = parentListNode
        self.attachmentType = attachmentType
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
            guard let sSelf = self else { return }
            if granted {
                sSelf.requestAuthorizationForMicrophone { granted in
                    sSelf.coordinatorServices.locationService?.requestAuhtorizationForLocatioInUse()
                    DispatchQueue.main.async {
                        guard let sSelf = self else { return }
                        sSelf.presenter.present(navigationViewController,
                                                animated: true)
                    }
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
    
    private func requestAuthorizationForMicrophone(completion: @escaping ((_ granted: Bool) -> Void)) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            completion(granted)
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

// MARK: - CameraKitCapture Delegate

extension CameraScreenCoordinator: CameraKitCaptureDelegate {
    func didEndReview(for capturedAssets: [CapturedAsset]) {
        coordinatorServices.locationService?.stopUpdatingLocation()
        
        var isFileSizeExcceds = false
        
        if attachmentType == .task || attachmentType == .workflow {
            let fileLimit = attachmentType == .task ? KeyConstants.FileSize.taskFileSize : KeyConstants.FileSize.workflowFileSize
            for capturedAsset in capturedAssets {
                let assetURL = URL(fileURLWithPath: capturedAsset.path)
                if assetURL.fileSizeInMB() > fileLimit {
                    isFileSizeExcceds = true
                    break
                }
            }
            if isFileSizeExcceds { // show error about maximum file size
                DispatchQueue.main.async {
                    self.showErrorMaximumFileSizeExcceds(fileLimit: fileLimit)
                }
                return
            }
        }
        
        guard let accountIdentifier = coordinatorServices.accountService?.activeAccount?.identifier,
              let mediaPath = mediaFilesFolderPath else { return }
        
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
        if let capturedAsset = capturedAssets.first {
            let assetURL = URL(fileURLWithPath: capturedAsset.path)
            let uploadFilePath = DiskService.uploadFolderPath(for: accountIdentifier) +
                "/" + assetURL.lastPathComponent
            _ = DiskService.copy(itemAtPath: capturedAsset.path, to: uploadFilePath)
            
            let uploadTransfer = UploadTransfer(parentNodeId: parentListNode.guid,
                                                nodeName: capturedAsset.fileName,
                                                extensionType: capturedAsset.type.ext,
                                                mimetype: capturedAsset.type.mimetype,
                                                nodeDescription: capturedAsset.description,
                                                localFilenamePath: assetURL.lastPathComponent,
                                                attachmentType: self.attachmentType)
            let uploadTransferDataAccessor = UploadTransferDataAccessor()
            uploadTransferDataAccessor.store(uploadTransfer: uploadTransfer)
            uploadTransfers.append(uploadTransfer)
        }

        _ = DiskService.delete(itemAtPath: mediaPath)
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
    
    private func showErrorMaximumFileSizeExcceds(fileLimit: Double) {
        let errorMessage = String(format: LocalizationConstants.EditTask.errorFileSizeExceeds, fileLimit)
        Snackbar.display(with: errorMessage,
                         type: .error,
                         presentationHostViewOverride: self.presenter.viewControllers.last?.view,
                         finish: nil)
    }
}
