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
    
    init(with presenter: UINavigationController,
         parentListNode: ListNode) {
        self.presenter = presenter
        self.parentListNode = parentListNode
    }
    
    func start() {
        let viewController = CameraViewController.instantiateViewController()
        viewController.theme = configurationLayout()
        viewController.localization = cameraLocalization()
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
                    privacyVC.viewModel = PrivacyNotiveCameraModel()
                    privacyVC.coordinatorServices = sSelf.coordinatorServices
                    sSelf.presenter.present(privacyVC,
                                            animated: true,
                                            completion: nil)
                }
            }
        }
    }
    
    // MARK: - Private Methods
        
    func requestAuthorizationForCameraUsage(completion: @escaping ((_ granted: Bool) -> Void)) {
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

    func configurationLayout() -> CameraConfigurationLayout? {
        guard let currentTheme = themingService?.activeTheme,
              let textFieldScheme = themingService?.containerScheming(for: .loginTextField),
              let buttonScheme = themingService?.containerScheming(for: .dialogButton)
        else { return  nil}

        return
            CameraConfigurationLayout(onSurfaceColor: currentTheme.onSurfaceColor,
                                      onSurface60Color: currentTheme.onSurface60Color,
                                      onSurface5Color: currentTheme.onSurface5Color,
                                      surfaceColor: currentTheme.surfaceColor,
                                      subtitle2Font: currentTheme.subtitle2TextStyle.font,
                                      headline6Font: currentTheme.headline6TextStyle.font,
                                      textFieldScheme: textFieldScheme,
                                      buttonScheme: buttonScheme)
    }
    
    func cameraLocalization() -> CameraLocalization {
        return
            CameraLocalization(sliderPhoto:
                                LocalizationConstants.Camera.sliderCameraPhoto,
                               saveButton:
                                LocalizationConstants.General.save,
                               previewScreenTitle:
                                LocalizationConstants.ScreenTitles.previewCaptureAsset,
                               fileNameTextField:
                                LocalizationConstants.TextFieldPlaceholders.filename,
                               descriptionTextField:
                                LocalizationConstants.TextFieldPlaceholders.description,
                               errorNodeNameSpecialCharacters:
                                LocalizationConstants.Errors.errorNodeNameSpecialCharacters)
    }
}

extension CameraScreenCoordinator: CameraKitCaptureDelegate {
    func didEndReview(for capturedAsset: CapturedAsset) {
//        let uploadTransfer = UploadTransfer(parentNodeId: capturedAsset., nodeName: <#T##String#>, nodeDescription: <#T##String?#>, filePath: <#T##String#>)
    }
}
