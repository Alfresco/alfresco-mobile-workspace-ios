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

class CapturedAsset {
    private(set) var path: String?
    
    init(image: UIImage) {
        self.path = cacheToDisk(image: image)
    }
    
    init(data: Data) {
        self.path = cacheToDisk(data: data)
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
    
    private func cacheToDisk(data: Data) -> String? {
        guard let mediaFolder = createMediaFolder()
        else {
            return nil
        }
        let timestamp = String(Date().timeIntervalSince1970)
        let imagePath = mediaFolder.appendingPathComponent("\(timestamp).jpeg")
        let fileManager = FileManager.default
        fileManager.createFile(atPath: imagePath,
                               contents: data, attributes: nil)
        return imagePath
    }
    
    private func cacheToDisk(image: UIImage) -> String? {
        guard let mediaFolder = createMediaFolder(),
              let data = image.jpegData(compressionQuality: 1)
        else {
            return nil
        }
        let timestamp = String(Date().timeIntervalSince1970)
        let imagePath = mediaFolder.appendingPathComponent("\(timestamp).jpeg")
        let fileManager = FileManager.default
        fileManager.createFile(atPath: imagePath,
                               contents: data, attributes: nil)
        return imagePath
    }
    
    private func createMediaFolder() -> NSString? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory,
                                                  in: .userDomainMask)[0]
        let documentsDirectoryPath = documentsDirectory.path as NSString
        let mediaFolder = documentsDirectoryPath.appendingPathComponent("Media Folder")
        if !fileManager.fileExists(atPath: mediaFolder) {
            do {
                try fileManager.createDirectory(atPath: mediaFolder,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                AlfrescoLog.error("Failed to create path: \(mediaFolder).")
                return nil
            }
        }
        return mediaFolder as NSString
    }
}
