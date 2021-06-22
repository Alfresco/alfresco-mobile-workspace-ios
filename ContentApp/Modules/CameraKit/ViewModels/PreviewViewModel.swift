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

class PreviewViewModel {
    private let capturedAsset: CapturedAsset
    
    // MARK: - Init
    
    init(capturedAsset: CapturedAsset) {
        self.capturedAsset = capturedAsset
    }
    
    // MARK: - Public Methods
    
    func isAssetVideo() -> Bool {
        return capturedAsset.type == .video
    }
    
    func videoUrl() -> URL {
        return URL(fileURLWithPath: capturedAsset.path)
    }
    
    func asset() -> CapturedAsset {
        return capturedAsset
    }
    
    func assetFilename() -> String {
        return capturedAsset.fileName
    }
    
    func assetDescription() -> String? {
        return capturedAsset.description
    }
    
    func assetThumbnailImage() -> UIImage? {
        return capturedAsset.thumbnailImage()
    }
    
    func updateMetadata(filename: String, description: String?) {
        capturedAsset.fileName = filename
        capturedAsset.description = description
    }
}
