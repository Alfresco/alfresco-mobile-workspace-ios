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

class DiskServices {
    static var repository = ApplicationBootstrap.shared().repository
    static var accountService = repository.service(of: AccountService.identifier) as? AccountService

    // MARK: - Avatar

    static func saveAvatar(_ image: UIImage) {
        let identifier = accountService?.activeAccount?.identifier ?? ""
        let fileManager = FileManager.default
        if let newDirectoryPath = create(directory: identifier) {
            fileManager.createFile(atPath: "\(newDirectoryPath)/\(kProfileAvatarImageFileName)",
                contents: image.pngData(), attributes: nil)
        }
    }

    static func getAvatar() -> UIImage? {
        let identifier = accountService?.activeAccount?.identifier ?? ""
        let fileManager = FileManager.default
        let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(identifier) + "/" + kProfileAvatarImageFileName
        if fileManager.fileExists(atPath: imagePAth) {
            return UIImage(contentsOfFile: imagePAth)
        }
        return nil
    }

    // MARK: - Create user folder

    static func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    static func create(directory: String) -> String? {
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(directory)
        if !fileManager.fileExists(atPath: paths) {
            do {
                try fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
            } catch {
                AlfrescoLog.error("Failed to create \(directory) directory in path \(paths).")
                return nil
            }
        }
        return paths
    }

    static func delete(directory: String) {
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(directory)
        if fileManager.fileExists(atPath: paths) {
            do {
                try fileManager.removeItem(atPath: paths)
            } catch {
                AlfrescoLog.error("Failed to delete \(directory) directory in path \(paths).")
            }
        } else {
            AlfrescoLog.error("Something wrong when deleted \(directory) directory in path \(paths).")
        }
    }
}
