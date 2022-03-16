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
import ObjectBox

class DatabaseMigrationService: NSObject {
    
    func migrateDatabase() {
        migrateFilesInLocalDirectory()
        UserDefaultsModel.set(value: true, for: KeyConstants.AppGroup.dataMigration)
    }
    
    func migrateFilesInLocalDirectory() {
        let oldDirectoryPath = oldDocumentDirectoryPath()
        
        if let files = try? FileManager.default.contentsOfDirectory(atPath: oldDirectoryPath) {
            let newDirectoryPath = DiskService.documentsDirectoryPath()
            for file in files where file != "com.alfresco.contentapp" {
                do {
                    try FileManager.default.moveItem(atPath: "\(oldDirectoryPath)/\(file)", toPath: "\(newDirectoryPath)/\(file)")
                } catch let error {
                    AlfrescoLog.error("Error ----->>>> \(error.localizedDescription)")
                }
            }
        }
    }
    
    func oldDocumentDirectoryPath() -> String {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                          in: .userDomainMask)[0]
        return documentsDirectory.path
    }
}
