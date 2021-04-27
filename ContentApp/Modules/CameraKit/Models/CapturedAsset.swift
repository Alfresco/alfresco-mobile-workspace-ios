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

let prefixFileName = "IMG"
let extPhoto = "jpg"
let extVideo = "mov"

enum CapturedAssetType {
    case image
    case video
    
    var ext: String {
        switch self {
        case .image: return extPhoto
        case .video: return extVideo
        }
    }
}

class CapturedAsset {
    private(set) var path: String?
    private let type: CapturedAssetType
    var description: String?
    var filename = ""
    private let folderPath: String?
    private var phAsset: PHAsset?
    
    init(type: CapturedAssetType, data: Data, saveIn folderPath: String?) {
        self.type = type
        self.folderPath = folderPath
        self.phAsset = nil
        self.filename = provideFileName()
        self.path = cacheToDisk(data: data)
    }
    
    init(phAsset: PHAsset) {
        self.type = (phAsset.mediaType == .video) ? .video : .image
        self.folderPath = ""
        self.phAsset = phAsset
        self.filename = provideFileName()
        self.path = ""
    }
    
    func providePath(completion: @escaping (String?) -> Void) {
        guard let phAsset = self.phAsset else {
            completion(nil)
            return
        }
        if type == .image {
            let options = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true
            phAsset.requestContentEditingInput(with: options) { [weak self] (input, _) in
                guard let sSelf = self else { return }
                if let imageURL = input?.fullSizeImageURL {
                    sSelf.path = imageURL.path
                }
                completion(sSelf.path)
            }
        } else {
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.version = .original
            PHImageManager.default()
                .requestAVAsset(forVideo: phAsset,
                                options: options, resultHandler: { (asset, audioMix, info) in
                                    if let url = asset as? AVURLAsset {
                                        completion(url.url.path)
                                    }
                                })
        }
    }
    
    // MARK: - Public Helpers
    
    func image() -> UIImage? {
        guard let path = path else { return nil }
        if FileManager.default.fileExists(atPath: path) {
            return UIImage(contentsOfFile: path)
        }
        return nil
    }
    
    func deleteAsset() {
        guard let path = path else { return }
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
                AlfrescoLog.error("Failed to delete item at path: \(path).")
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func provideFileName() -> String {
        if let phAsset = self.phAsset,
           let originalName = PHAssetResource.assetResources(for: phAsset).first?.originalFilename,
           let splitName = originalName.split(separator: ".").first {
            return String(splitName)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
            return "\(prefixFileName)_\(dateFormatter.string(from: Date()))"
        }
    }
    
    private func cacheToDisk(data: Data) -> String? {
        guard let mediaFolder = folderPath as NSString? else { return nil }
        let imagePath = mediaFolder.appendingPathComponent("\(filename).\(type.ext)")
        FileManager.default.createFile(atPath: imagePath,
                                       contents: data, attributes: nil)
        return imagePath
    }

}
