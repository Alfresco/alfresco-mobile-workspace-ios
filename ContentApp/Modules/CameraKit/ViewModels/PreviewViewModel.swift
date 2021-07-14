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
    let capturedAssets: [CapturedAsset]
    
    // MARK: - Init
    
    init(capturedAssets: [CapturedAsset]) {
        self.capturedAssets = capturedAssets
    }
    
    // MARK: - Public Methods
    
    func isAssetVideo(at index: Int) -> Bool {
        return capturedAssets[index].type == .video
    }
    
    func videoUrl(for index: Int) -> URL {
        return URL(fileURLWithPath: capturedAssets[index].path)
    }
    
    func asset(at index: Int) -> CapturedAsset {
        return capturedAssets[index]
    }
    
    func assetFilename(at index: Int) -> String {
        return capturedAssets[index].fileName
    }
    
    func assetDescription(at index: Int) -> String? {
        return capturedAssets[index].description
    }
    
    func assetThumbnailImage(at index: Int) -> UIImage? {
        return capturedAssets[index].thumbnailImage()
    }
    
    func updateMetadata(filename: String, description: String?) {
        for (index, capturedAsset) in capturedAssets.enumerated() {
            capturedAsset.fileName = filename + "-\(String(index + 1))"
            capturedAsset.description = description
        }
    }
}
