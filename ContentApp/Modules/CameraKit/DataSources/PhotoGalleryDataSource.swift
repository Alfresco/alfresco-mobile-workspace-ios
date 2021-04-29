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

class PhotoGalleryDataSource {
    var mediaFilesFolderPath: String

    var allPhotoAssets = PHFetchResult<PHAsset>() {
        didSet {
            selectedIndexAssets = Array(repeating: false, count: allPhotoAssets.count)
        }
    }
    private var selectedIndexAssets: Array<Bool>
    private lazy var imageManager: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
    
    // MARK: - Init
    
    init(mediaFilesFolderPath: String) {
        self.mediaFilesFolderPath = mediaFilesFolderPath

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
    
    func asset(for indexPath: IndexPath) -> PHAsset {
        return allPhotoAssets.object(at: indexPath.row)
    }
    
    func isVideoAsset(_ phAsset: PHAsset) -> Bool {
        return (phAsset.mediaType == .video)
    }
    
    func isAssetSelected(for indexPath: IndexPath) -> Bool {
        return selectedIndexAssets[indexPath.row]
    }
    
    func markAssetsAs(enabled: Bool, for indexPath: IndexPath) {
        selectedIndexAssets[indexPath.row] = enabled
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
    
    func fetchSelectedAssets(for delegate: CameraKitCaptureDelegate?) {
        for (index, select) in selectedIndexAssets.enumerated() where select {
            let galleryAsset = asset(for: IndexPath(row: index, section: 0))

            fetchPath(for: galleryAsset) { [weak self] assetPath in
                guard let sSelf = self else { return }

                if let path = assetPath {
                    let assetType = (galleryAsset.mediaType == .video ? CapturedAssetType.video : .image)
                    let fileName = sSelf.fileName(for: galleryAsset)

                    var capturedAsset: CapturedAsset?

                    switch assetType {
                    case .image:
                        let image = UIImage(contentsOfFile: path)
                        if let assetData = image?.jpegData(compressionQuality: 1.0) {
                            capturedAsset = CapturedAsset(type: assetType,
                                                          fileName: fileName,
                                                          data: assetData,
                                                          saveIn: sSelf.mediaFilesFolderPath)
                        }
                    case .video:
                        capturedAsset = CapturedAsset(type: assetType,
                                                      fileName: fileName,
                                                      path: path)
                    }

                    if let asset = capturedAsset {
                        delegate?.didEndReview(for: asset)
                    }
                }
            }
        }
    }

    private func fileName(for asset: PHAsset) -> String {
        if let originalName = PHAssetResource.assetResources(for: asset).first?.originalFilename,
           let splitName = originalName.split(separator: ".").first {
            return String(splitName)
        }

        return ""
    }

    private func fetchPath(for asset: PHAsset,
                           completionHandler: @escaping (String?) -> Void) {
        if asset.mediaType == .image {
            let options = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true
            asset.requestContentEditingInput(with: options) { (input, _) in
                completionHandler(input?.fullSizeImageURL?.path)
            }
        } else {
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: asset,
                                                    options: options,
                                                    resultHandler: { (asset, audioMix, info) in
                                                        if let assetURL = asset as? AVURLAsset {
                                                            completionHandler(assetURL.url.path)
                                                        } else {
                                                            completionHandler(nil)
                                                        }
                                                    })
        }
    }
}
