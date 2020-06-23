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

    static func save(image: UIImage, named imageNamed: String, inDirectory directory: String) {
        let fileManager = FileManager.default
        if let newDirectoryPath = create(directory: directory) {
            fileManager.createFile(atPath: "\(newDirectoryPath)/\(imageNamed)",
                contents: image.jpegData(compressionQuality: 0.5), attributes: nil)
        }
    }

    static func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    static func get(image imageNamed: String, from directory: String) -> UIImage? {
        let fileManager = FileManager.default
        let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(directory) + "/" + imageNamed
        if fileManager.fileExists(atPath: imagePAth) {
            return UIImage(contentsOfFile: imagePAth)
        }
        return nil
    }

    static func create(directory: String) -> String? {
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(directory)
        if !fileManager.fileExists(atPath: paths) {
            do {
                try fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
            } catch {
                AlfrescoLog.error("Failed to create directory.")
                return nil
            }
        } else {
            AlfrescoLog.error("Already dictionary created.")
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
                AlfrescoLog.error("Failed to delete directory.")
            }
        } else {
            AlfrescoLog.error("Something wrong.")
        }
    }
}
