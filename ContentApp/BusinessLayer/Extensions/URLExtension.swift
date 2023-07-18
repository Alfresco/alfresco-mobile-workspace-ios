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

import UIKit

public extension URL {

    /// Returns a URL for the given app group and database pointing to the sqlite database.

    static func fileURL() -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: KeyConstants.AppGroup.name) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer
    }
}

extension URL {
    var attributes: [FileAttributeKey: Any] {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            AlfrescoLog.debug("FileAttribute error: \(error)")
        }
        return [FileAttributeKey: Any]()
    }

    var fileSize: Double {
        if let size = attributes[.size] as? NSNumber {
            return size.doubleValue / 1000000.0
        }
        return 0.0
    }
}

// MARK: - File Size
extension URL {
    func fileSizeInMB() -> Double {
        var fileSize: Double = 0.0
        var fileSizeValue = 0.0
        try? fileSizeValue = ((self.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as? Double?) ?? 0.0) ?? 0.0
        if fileSizeValue > 0.0 {
            fileSize = (Double(fileSizeValue) / (1024 * 1024))
        }
        return fileSize
    }
}
