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
import MaterialComponents.MaterialDialogs

public typealias PreviewErrorDismissHandler = (_ index: Int) -> Void
public typealias DeleteCapturedAssetHandler = (_ index: Int) -> Void

class PreviewViewModel {
    var assets: [CapturedAsset]
    let capturedAssets = Observable<[CapturedAsset]>([])
    let visibleCellIndex = Observable<Int>(0)
    let enableSaveButton = Observable<Bool>(false)
    var callback: DeleteCapturedAssetHandler! = nil
    
    // MARK: - Init
    init(assets: [CapturedAsset]) {
        self.assets = assets
        self.capturedAssets.value = assets
    }
    
    // MARK: - Public Methods
    func isAssetVideo(for capturedAsset: CapturedAsset) -> Bool {
        return capturedAsset.type == .video
    }
    
    func videoUrl(for capturedAsset: CapturedAsset) -> URL {
        return URL(fileURLWithPath: capturedAsset.path)
    }
    
    func assetFilename(for capturedAsset: CapturedAsset) -> String {
        return capturedAsset.fileName
    }
    
    func assetDescription(for capturedAsset: CapturedAsset) -> String {
        return capturedAsset.description ?? ""
    }
    
    func assetThumbnailImage(for capturedAsset: CapturedAsset) -> UIImage? {
        return capturedAsset.thumbnailImage()
    }
    
    // MARK: - Validate File Names
    func validateFileNames(in viewController: UIViewController,
                           handler: @escaping PreviewErrorDismissHandler) {
        guard let localization = CameraKit.localization else {
            return
        }
        var errorMessage = ""
        var errorIndex: Int = -1
        for (index, capturedAsset) in self.capturedAssets.value.enumerated() {
            let fileName = capturedAsset.fileName
            if hasSpecialCharacters(fileName) == true {
                let message = String(format: localization.errorNodeNameSpecialCharacters,
                                     specialCharacters())
                errorMessage = message
                errorIndex = index
                break
            }
        }
        
        if errorIndex >= 0 && !errorMessage.isEmpty {
            self.showAlertForWrongFileName(in: viewController, and: errorMessage)
        }
        handler(errorIndex)
    }
    
    func hasSpecialCharacters(_ string: String) -> Bool {
        let characterset = CharacterSet(charactersIn: "*\"<>\\/?:|")
        if string.rangeOfCharacter(from: characterset) != nil {
            return true
        }
        return false
    }

    func specialCharacters() -> String {
        return "* \" < > \\ / ? : |"
    }
    
    func showAlertForWrongFileName(in viewController: UIViewController,
                                   and message: String) {
        let title = LocalizationConstants.Alert.alertTitle
        let confirmButtonTitle = LocalizationConstants.General.ok

        let confirmAction = MDCAlertAction(title: confirmButtonTitle) {  _ in
        }
        confirmAction.accessibilityIdentifier = "confirmActionButton"
    
        if let viewController = viewController as? PreviewViewController {
            _ = viewController.showDialog(title: title,
                                          message: message,
                                          actions: [confirmAction]) {}
        }
    }
}
