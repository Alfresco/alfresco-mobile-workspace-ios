//
// Copyright (C) 2005-2020 Alfresco Software Limited.
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
import UIKit

class DiskService {

    // MARK: - Avatar

    static func saveAvatar(_ image: UIImage, for accountIdentifier: String) {
        let fileManager = FileManager.default
        let path = documentsDirectoryPath(for: accountIdentifier)
        if create(directoryPath: path) {
            fileManager.createFile(atPath: "\(path)/\(kProfileAvatarImageFileName)",
                                   contents: image.pngData(), attributes: nil)
        }
    }

    static func getAvatar(for accountIdentifier: String) -> UIImage? {
        let fileManager = FileManager.default
        let imagePath = documentsDirectoryPath(for: accountIdentifier) + "/" + kProfileAvatarImageFileName

        if fileManager.fileExists(atPath: imagePath) {
            let avatar = UIImage(contentsOfFile: imagePath)
            if avatar == nil {
                return UIImage(named: "account-circle")
            }
        }

        return nil
    }

    // MARK: - Create user folder

    static func documentsDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    static func documentsDirectoryPath(for accountIdentifier: String) -> String {
        let documentsPath = self.documentsDirectoryPath() as NSString
        let accountDocumentsPath = documentsPath.appendingPathComponent(accountIdentifier)

        return accountDocumentsPath
    }

    static func create(directoryPath: String) -> Bool {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directoryPath) {
            do {
                try fileManager.createDirectory(atPath: directoryPath,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
                return true
            } catch {
                AlfrescoLog.error("Failed to create path: \(directoryPath).")
                return false
            }
        }

        return false
    }

    static func delete(directoryPath: String) -> Bool {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: directoryPath) {
            do {
                try fileManager.removeItem(atPath: directoryPath)
            } catch {
                AlfrescoLog.error("Failed to delete item at path: \(directoryPath).")
            }
        }

        return false
    }
}
