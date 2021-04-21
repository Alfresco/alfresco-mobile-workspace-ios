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
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

class DiskService {

    // MARK: - Avatar

    static func saveAvatar(_ image: UIImage, for accountIdentifier: String) {
        let fileManager = FileManager.default
        let path = documentsDirectoryPath(for: accountIdentifier)
        if create(directoryPath: path) {
            fileManager.createFile(atPath: "\(path)/\(KeyConstants.Disk.avatar)",
                                   contents: image.pngData(), attributes: nil)
        }
    }

    static func getAvatar(for accountIdentifier: String) -> UIImage? {
        let fileManager = FileManager.default
        let imagePath = documentsDirectoryPath(for: accountIdentifier) + "/" + KeyConstants.Disk.avatar

        var avatar: UIImage?
        if fileManager.fileExists(atPath: imagePath) {
            avatar = UIImage(contentsOfFile: imagePath)
        }
        return avatar
    }

    // MARK: - Disk operations

    static func create(directoryPath: String) -> Bool {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directoryPath) {
            do {
                try fileManager.createDirectory(atPath: directoryPath,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
                createMediaFilesFolder(directoryPath: directoryPath)
                return true
            } catch {
                AlfrescoLog.error("Failed to create path: \(directoryPath).")
                return false
            }
        }
        return true
    }

    static func delete(itemAtPath: String) -> Bool {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: itemAtPath) {
            do {
                try fileManager.removeItem(atPath: itemAtPath)
            } catch {
                AlfrescoLog.error("Failed to delete item at path: \(itemAtPath).")
                return false
            }
        }
        return true
    }

    // MARK: - Path creation
    
    static func createMediaFilesFolder(directoryPath: String) {
        let fileManager = FileManager.default
        let mediaFolder = directoryPath + "/" + KeyConstants.Disk.mediaFilesFolder
        if !fileManager.fileExists(atPath: mediaFolder) {
            do {
                try fileManager.createDirectory(atPath: mediaFolder,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                AlfrescoLog.error("Failed to create path: \(mediaFolder).")
            }
        }
    }

    static func documentsDirectoryPath() -> String {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                          in: .userDomainMask)[0]
        return documentsDirectory.path
    }
    
    static func mediaFilesFolderPath(for accountIdentifier: String) -> String {
        return documentsDirectoryPath(for: accountIdentifier) + "/" + KeyConstants.Disk.mediaFilesFolder
    }

    static func documentsDirectoryPath(for accountIdentifier: String) -> String {
        let documentsPath = self.documentsDirectoryPath() as NSString
        let md5Path = MD5Path(path: accountIdentifier)
        let accountDocumentsPath = documentsPath.appendingPathComponent(md5Path)

        return accountDocumentsPath
    }

    static func MD5(string: String) -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using: .utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress,
                   let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }

    static func MD5Path(path: String) -> String {
        let md5Data = MD5(string: path)
        let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
        return md5Hex
    }
}
