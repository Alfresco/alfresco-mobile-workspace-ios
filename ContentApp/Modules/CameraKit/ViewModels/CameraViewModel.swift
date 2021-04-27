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

protocol CameraViewModelDelegate: AnyObject {
    func finishProcess(capturedAsset: CapturedAsset?, error: Error?)
}

class CameraViewModel {
    weak var delegate: CameraViewModelDelegate?
    var capturedAsset: CapturedAsset?
    var mediaFilesFolderPath: String
    
    init(mediaFilesFolderPath: String) {
        self.mediaFilesFolderPath = mediaFilesFolderPath
    }
    
    // MARK: - Public Methods
    
    func deletePreviousCapture() {
        capturedAsset?.deleteAsset()
    }
}

extension CameraViewModel: CaptureSessionDelegate {
    func captured(asset: CapturedAsset?, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.capturedAsset = asset
            sSelf.delegate?.finishProcess(capturedAsset: asset, error: error)
        }
    }
}
