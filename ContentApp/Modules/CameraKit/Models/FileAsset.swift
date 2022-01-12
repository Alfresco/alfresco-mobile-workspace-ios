//
// Copyright (C) 2005-2022 Alfresco Software Limited.
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

import Foundation

class FileAsset {
    let type: String?
    var description: String?
    var fileName: String?
    var fileExtension: String?
    
    private(set) var path = ""
    
    init(type: String?,
         fileName: String?,
         data: Data,
         fileExtension: String?,
         saveIn folderPath: String) {
        self.type = type
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.path = cacheToDisk(data: data,
                                at: folderPath)
    }

    init(type: String?,
         fileName: String,
         path: String,
         saveIn folderPath: String,
         fileExtension: String?) {
        self.type = type
        self.fileName = fileName
        
        let locaFilePath = composeLocalFilePath(in: folderPath as NSString)
        _ = DiskService.copy(itemAtPath: path, to: locaFilePath)
        
        self.path = locaFilePath
        self.fileExtension = fileExtension
    }
    
    init(type: String?,
         fileName: String,
         path: String,
         fileExtension: String?) {
        self.type = type
        self.fileName = fileName
        self.path = path
        self.fileExtension = fileExtension
    }
    
    // MARK: - Public Helpers
    func deleteFileAsset() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
                AlfrescoLog.error("Failed to delete item at path: \(path).")
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
        if let fileName = fileName, let fileExtension = fileExtension {
            return folderPath.appendingPathComponent("\(fileName)_\(uniqueIdentifier()).\(fileExtension)")
        }
        return ""
    }

    private func uniqueIdentifier() -> String {
        return String(Date().timeIntervalSince1970)
    }
}
