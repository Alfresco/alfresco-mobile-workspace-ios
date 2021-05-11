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

let prefixFileName = "IMG"
let extPhoto = "JPG"
let extVideo = "MOV"

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
    let type: CapturedAssetType
    var description: String?
    var fileName: String

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
        
        let locaFilePath = (folderPath as NSString).appendingPathComponent("\(timestamp()).\(type.ext)")
        _ = DiskService.copy(itemAtPath: path, to: locaFilePath)
        self.path = locaFilePath
    }
    
    // MARK: - Public Helpers
    
    func image() -> UIImage? {
        if FileManager.default.fileExists(atPath: path) {
            return UIImage(contentsOfFile: path)
        }
        return nil
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
    }
    
    // MARK: - Private Helpers
    
    private func cacheToDisk(data: Data, at folderPath: String) -> String {
        let mediaFolder = folderPath as NSString
        let imagePath = mediaFolder.appendingPathComponent("\(timestamp()).\(type.ext)")
        FileManager.default.createFile(atPath: imagePath,
                                       contents: data, attributes: nil)
        return imagePath
    }

    private func timestamp() -> String {
        return String(Date().timeIntervalSinceNow)
    }
}
