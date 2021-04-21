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

class PhotoGalleryViewModel {
    private var allPhotoAssets: PHFetchResult<PHAsset>
    private var selectedIndexAssets: Array<Bool>
    private var selectedAssets = [CapturedAsset]()
    
    private lazy var imageManager: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
    
    // MARK: - Init
    
    init() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                             ascending: false)]
        allPhotoAssets = PHAsset.fetchAssets(with: allPhotosOptions)
        selectedIndexAssets = Array(repeating: false, count: allPhotoAssets.count)
    }

    // MARK: - Public Methods
    
    func numberOfAssets() -> Int {
        return allPhotoAssets.count
    }
    
    func asset(at indexPath: IndexPath) -> PHAsset {
        return allPhotoAssets.object(at: indexPath.row)
    }
    
    func assetIsVideo(_ phAsset: PHAsset) -> Bool {
        return (phAsset.mediaType == .video)
    }
    
    func assetIsSelected(at indexPath: IndexPath) -> Bool {
        return selectedIndexAssets[indexPath.row]
    }
    
    func assets(selected: Bool, at indexPath: IndexPath) {
        selectedIndexAssets[indexPath.row] = selected
    }
    
    func anyAssetSelected() -> Bool {
        for select in selectedIndexAssets where select {
            return true
        }
        return false
    }
    
    func image(for phAsset: PHAsset,
               size: CGSize,
               completion: @escaping ((_ image: UIImage?) -> Void)) {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.resizeMode = .exact
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true

        imageManager.requestImage(for: phAsset,
                                  targetSize: size,
                                  contentMode: .aspectFill,
                                  options: options) { [weak self] (image, _) in
            guard let sSelf = self else { return }
            completion(image)
            sSelf.imageManager.startCachingImages(for: [phAsset],
                                                  targetSize: size,
                                                  contentMode: .aspectFill,
                                                  options: options)
        }
    }
    
    func fetchSelectedAssets(to delegate: CameraKitCaptureDelegate?) {
        for (index, select) in selectedIndexAssets.enumerated() where select {
            let phAsset = asset(at: IndexPath(row: index, section: 0))
            let capturedAsset = CapturedAsset(phAsset: phAsset)
            delegate?.didEndReview(for: capturedAsset)
//            selectedAssets.append(capturedAsset)
        }
    }
}
