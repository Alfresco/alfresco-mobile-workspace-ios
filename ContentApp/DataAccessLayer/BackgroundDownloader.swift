//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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
import AlfrescoCore

typealias DownloadHandler = (URL?, APIError?) -> Void

class BackgroundDownloader: NSObject {
    private lazy var urlSession: URLSession = {
        let identifier = Bundle.main.bundleIdentifier! + ".background"
        let config = URLSessionConfiguration.background(withIdentifier: identifier)
//        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true

        return URLSession(configuration: config,
                          delegate: self,
                          delegateQueue: nil)
    }()

    private let destinationURL: URL
    private let originURL: URL
    private let completionHandler: DownloadHandler
    private var backgroundTask: URLSessionDownloadTask?
    private let headers: [String: String]

    deinit {
        urlSession.finishTasksAndInvalidate()
    }

    init(from url: URL,
         downloadTo destinationURL: URL,
         headers: [String: String],
         completionHandler: @escaping DownloadHandler) {
        originURL = url
        self.destinationURL = destinationURL
        self.completionHandler = completionHandler
        self.headers = headers
    }

    func download() -> URLSessionDownloadTask? {
        do {
            let request = try URLRequest(url: originURL,
                                     method: .get,
                                     headers: headers)
            backgroundTask = urlSession.downloadTask(with: request)

            let resourceValues = try originURL.resourceValues(forKeys: [.fileSizeKey])
            if let fileSize = resourceValues.fileSize {
                backgroundTask?.countOfBytesClientExpectsToSend = 200
                backgroundTask?.countOfBytesClientExpectsToReceive = Int64(fileSize)
            }
        } catch _ { }

        backgroundTask?.resume()
        return backgroundTask
    }
}

extension BackgroundDownloader: URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                  let backgroundCompletionHandler =
                    appDelegate.backgroundCompletionHandler else {
                return
            }
            backgroundCompletionHandler()
        }
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        if let httpURLResponse = task.response as? HTTPURLResponse {
            if error?.code == NSURLErrorNetworkConnectionLost ||
                error?.code == NSURLErrorCancelled {
                completionHandler(nil, nil)
            } else {
                let error = APIError(domain: "",
                                     code: httpURLResponse.statusCode)
                completionHandler(nil, error)
            }
        }
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        let fileManager = FileManager.default
        do {
            let parentDir = destinationURL.deletingLastPathComponent()
            try fileManager.createDirectory(atPath: parentDir.path,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            _ = try fileManager.replaceItemAt(location,
                                          withItemAt: destinationURL,
                                          backupItemName: location.lastPathComponent)
            completionHandler(destinationURL, nil)
        } catch _ {
            let error = APIError(domain: "")
            completionHandler(nil, error)
        }
    }
}
