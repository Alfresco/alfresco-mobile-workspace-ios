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

class PDCache: NSObject {
    static let shared = PDCache()
    
    func saveData(obj: Data, fileName: String) {
        
        let filename = getDocumentsDirectory().appendingPathComponent("\(fileName).pdf")
        do {
            try obj.write(to: filename, options: .atomic)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getData(fileName: String) -> URL? {
        let fileManager = FileManager.default
        let filename = getDocumentsDirectory().appendingPathComponent("\(fileName).pdf")
        if fileManager.fileExists(atPath: filename.path) {
            return URL(fileURLWithPath: filename.path)
        }
        return nil
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
