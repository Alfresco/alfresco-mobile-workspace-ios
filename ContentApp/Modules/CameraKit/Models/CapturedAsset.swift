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

let prefixImageFileName = "IMG"
let prefixVideoFileName = "VIDEO"
let extPhoto = "JPG"
let extVideo = "MOV"
let mimetypePhoto = "image/jpeg"
let mimetypeVideo = "video/quicktime"

enum CapturedAssetType {
    case image
    case video
    
    var ext: String {
        switch self {
        case .image: return extPhoto
        case .video: return extVideo
        }
    }
    
    var mimetype: String {
        switch self {
        case .image: return mimetypePhoto
        case .video: return mimetypeVideo
        }
    }
}

class CapturedAsset {
    let type: CapturedAssetType
    var description: String?
    var fileName: String
    var thumbnailPath: String?

    private(set) var path = ""
    
    init(type: CapturedAssetType,
         fileName: String,
         data: Data,
         saveIn folderPath: String) {
        self.type = type
        self.fileName = fileName
        self.path = cacheToDisk(data: data,
                                at: folderPath)
    }

    init(type: CapturedAssetType,
         fileName: String,
         path: String,
         saveIn folderPath: String) {
        self.type = type
        self.fileName = fileName
        
        let locaFilePath = composeLocalFilePath(in: folderPath as NSString)
        _ = DiskService.copy(itemAtPath: path, to: locaFilePath)
        
        self.path = locaFilePath
    }
    
    init(type: CapturedAssetType,
         fileName: String,
         path: String) {
        self.type = type
        self.fileName = fileName
        self.path = path
        if let thumbnail = self.videoThumbnail() {
            let filename = defaultFileName(with: prefixImageFileName)
            self.thumbnailPath = DiskService.saveVideoThumbnail(thumbnail, fileName: filename)
        }
    }
    
    // MARK: - Public Helpers
    
    func thumbnailImage() -> UIImage? {
        switch type {
        case .image:
            if FileManager.default.fileExists(atPath: path) {
                return UIImage(contentsOfFile: path)
            }
        case .video:
            if let thumbnailPath = thumbnailPath {
                if FileManager.default.fileExists(atPath: thumbnailPath) {
                    return UIImage(contentsOfFile: thumbnailPath)
                }
            }
        }
        
        return nil
    }
    
    func videoThumbnail() -> UIImage? {
        let asset = AVAsset(url: URL(fileURLWithPath: path))
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let cgimage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 30),
                                                         actualTime: nil)
            let assetOrientation = orientation(for: asset)
            return UIImage(cgImage: cgimage, scale: 1.0, orientation: assetOrientation)
        } catch {
            return nil
        }
    }
        
    func deleteAsset() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
                AlfrescoLog.error("Failed to delete item at path: \(path).")
            }
        }
        deleteVideoThumbnail()
    }
    
    private func deleteVideoThumbnail() {
        let fileManager = FileManager.default
        if let thumbnailPath = thumbnailPath {
            if fileManager.fileExists(atPath: thumbnailPath) {
                do {
                    try fileManager.removeItem(atPath: thumbnailPath)
                } catch {
                    AlfrescoLog.error("Failed to delete item at path: \(thumbnailPath).")
                }
            }
        }
    }
    
    func filePath() -> String {
        let url = URL(fileURLWithPath: self.path)
        return url.lastPathComponent
    }
    
    // MARK: - Private Helpers
    
    private func cacheToDisk(data: Data, at folderPath: String) -> String {
        let locaFilePath = composeLocalFilePath(in: folderPath as NSString)
        FileManager.default.createFile(atPath: locaFilePath,
                                       contents: data, attributes: nil)
        return locaFilePath
    }
    
    private func composeLocalFilePath(in folderPath: NSString) -> String {
        return folderPath.appendingPathComponent("\(fileName)_\(uniqueIdentifier()).\(type.ext)")
    }

    private func uniqueIdentifier() -> String {
        return UUID().uuidString
    }
    
    private func orientation(for asset: AVAsset) -> UIImage.Orientation {
        guard let transform = asset.tracks(withMediaType: AVMediaType.video).first?.preferredTransform else {
            return .right
        }
        
        let size = asset.tracks(withMediaType: AVMediaType.video).first?.naturalSize ?? .zero
        
        switch (transform.tx, transform.ty) {
        case (0, 0):
            return .up
        case (size.width, size.height):
            return .down
        case (0, size.width):
            return .left
        default:
            return .right
        }
    }
    
    private func defaultFileName(with prefix: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmssSS"
        return "\(prefix)_\(dateFormatter.string(from: Date()))"
    }
}
