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

class FileManagerDataSource {
    var folderToSavePath: String
    private var selectedFiles = [URL]()

    // MARK: - Init
    init(folderToSavePath: String) {
        self.folderToSavePath = folderToSavePath
    }
    
    func fetchSelectedAssets(for urls: [URL], and delegate: FileManagerAssetDelegate?) {
        let fetchGroup = DispatchGroup()
        var fileAssets: [FileAsset] = []
        for url in urls {
            fetchGroup.enter()

            let fileName = fileName(for: url)
            let pathExtention = url.pathExtension
            self.handleFetchedFiles(with: url, fileName: fileName, fileType: pathExtention) { fileAsset in
                fileAssets.append(fileAsset)
                fetchGroup.leave()
            }
        }
        
        fetchGroup.notify(queue: CameraKit.cameraWorkerQueue) {
            delegate?.didEndFileManager(for: fileAssets)
        }
    }
    
    private func fileName(for url: URL?) -> String {
        if let originalName = url?.lastPathComponent, let splitName = originalName.split(separator: ".").first {
            return String(splitName)
        }
        return ""
    }
    
    private func handleFetchedFiles(with url: URL,
                                    fileName: String,
                                    fileType: String,
                                    completionHandler: @escaping (FileAsset ) -> Void) {
        let workerQueue = CameraKit.cameraWorkerQueue

        workerQueue.async { [weak self] in
            guard let sSelf = self else { return }
            
            if let fileData = try? Data(contentsOf: url) {
                let fileAsset = FileAsset(type: fileType,
                                          fileName: fileName,
                                          data: fileData,
                                          fileExtension: fileType,
                                          saveIn: sSelf.folderToSavePath
                                          )
                completionHandler(fileAsset)
            }
        }
    }
}
