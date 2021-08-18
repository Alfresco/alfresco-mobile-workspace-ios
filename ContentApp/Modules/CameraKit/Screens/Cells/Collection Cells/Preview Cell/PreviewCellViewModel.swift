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

class PreviewCellViewModel: RowViewModel {
    let capturedAsset: CapturedAsset?
    var didSelectTrash: ((CapturedAsset) -> Void)?
    var didSelectPlay: ((CapturedAsset) -> Void)?

    init(capturedAssets: CapturedAsset?) {
        self.capturedAsset = capturedAssets
    }
    
    func cellIdentifier() -> String {
        return "PreviewCollectionViewCell"
    }
    
    func isAssetVideo() -> Bool {
        return capturedAsset?.type == .video
    }
    
    func assetThumbnailImage() -> UIImage? {
        return capturedAsset?.thumbnailImage()
    }
    
    func isPlayButtonHidden() -> Bool {
        if self.isAssetVideo() == true {
            return false
        } else {
            return true
        }
    }
    
    func imageContentMode() -> UIView.ContentMode {
        if let image = assetThumbnailImage() {
            if image.imageOrientation == .down || image.imageOrientation == .up {
                return .scaleAspectFit
            }
        }
        return .scaleAspectFill
    }
    
    func selectOptionTrash() {
        guard let capturedAsset = self.capturedAsset else {
            return
        }
        self.didSelectTrash?(capturedAsset)
    }
    
    func selectOptionPlay() {
        guard let capturedAsset = self.capturedAsset else {
            return
        }
        self.didSelectPlay?(capturedAsset)
    }
}
