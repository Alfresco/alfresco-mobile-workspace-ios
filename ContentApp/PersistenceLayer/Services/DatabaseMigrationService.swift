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

    override init() {
//        do {
//            let appSupport = try FileManager.default.url(for: .documentDirectory,
//                                                         in: .userDomainMask,
//                                                         appropriateFor: nil,
//                                                         create: true)
//                                                         .appendingPathComponent(Bundle.main.bundleIdentifier!)
//            let directory = appSupport.appendingPathComponent(databaseName)
//            try? FileManager.default.createDirectory(at: directory,
//                                                     withIntermediateDirectories: true,
//                                                     attributes: nil)
//        } catch let error {
//            AlfrescoLog.error("Unable to initialize persistence store: \(error)")
//        }
    }
    
    func migrateDatabase() {
        migrateFilesInLocalDirectory()
        UserDefaultsModel.set(value: true, for: KeyConstants.AppGroup.dataMigration)
    }
    
    func migrateFilesInLocalDirectory() {
        let oldDirectoryPath = oldDocumentDirectoryPath()
        let newDirectoryPath = DiskService.documentsDirectoryPath()
        if let files = try? FileManager.default.contentsOfDirectory(atPath: oldDirectoryPath) {
            for file in files {
                do {
                    try FileManager.default.moveItem(atPath: "\(oldDirectoryPath)/\(file)", toPath: "\(newDirectoryPath)/\(file)")
                } catch {
                    AlfrescoLog.error("Error ----->>>> \(error)")
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
