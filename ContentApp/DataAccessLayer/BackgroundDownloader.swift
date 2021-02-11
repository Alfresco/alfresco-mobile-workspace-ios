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

typealias DownloadHandler = (URL?, Error?) -> Void
typealias BackgroundCompletionHandler = (() -> Void)

protocol BackgroundDownloaderProtocol {
    /// Initializez background downloader class with request related information.
    /// - Parameters:
    ///   - url: URL from where to download the file
    ///   - destinationURL: URL where the downloaded file will be saved
    ///   - headers: Request headers, usually reserved for authentication parameters
    ///   - completionHandler: Handler executed when the request finishes successfully or
    ///                        encounters an error
    init(from url: URL,
         downloadTo destinationURL: URL,
         headers: [String: String],
         completionHandler: @escaping DownloadHandler)

    /// Starts a download and returns the associated task for further control over it.
    func download() -> URLSessionDownloadTask?
}

class BackgroundDownloader: NSObject, BackgroundDownloaderProtocol {
    public var isDiscretionary = false {
        didSet {
            // Need to recreate session object with new setting
            BackgroundDownloader.urlSession = createSession()
        }
    }
    private let destinationURL: URL
    private let originURL: URL
    private let completionHandler: DownloadHandler
    private var backgroundTask: URLSessionDownloadTask?
    private let headers: [String: String]

    static var urlSession: URLSession = URLSession(configuration: .default)
    static var backgroundCompletionHandler: BackgroundCompletionHandler?

    // MARK: - Public interface

    required init(from url: URL,
                  downloadTo destinationURL: URL,
                  headers: [String: String],
                  completionHandler: @escaping DownloadHandler) {
        originURL = url
        self.destinationURL = destinationURL
        self.completionHandler = completionHandler
        self.headers = headers
        super.init()

        BackgroundDownloader.urlSession = createSession()
    }

    func download() -> URLSessionDownloadTask? {
        do {
            let request = try URLRequest(url: originURL,
                                         method: .get,
                                         headers: headers)
            backgroundTask = BackgroundDownloader.urlSession.downloadTask(with: request)

            let resourceValues = try originURL.resourceValues(forKeys: [.totalFileSizeKey])
            if let fileSize = resourceValues.totalFileSize {
                backgroundTask?.countOfBytesClientExpectsToSend = 200
                backgroundTask?.countOfBytesClientExpectsToReceive = Int64(fileSize)
            }
        } catch _ { }

        backgroundTask?.resume()
        return backgroundTask
    }

    // MARK: - Private interface

    private func createSession() -> URLSession {
        let identifier = Bundle.main.bundleIdentifier! + ".background" + randomString(numberOfDigits: 10)
        let config = URLSessionConfiguration.background(withIdentifier: identifier)
        config.isDiscretionary = isDiscretionary
        config.sessionSendsLaunchEvents = true

        return URLSession(configuration: config,
                          delegate: self,
                          delegateQueue: nil)
    }

    private func randomString(numberOfDigits: Int) -> String {
        let digits = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        return String(Array(0..<numberOfDigits).map { _ in digits.randomElement()! })
    }
}

extension BackgroundDownloader: URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            guard let backgroundCompletionHandler = BackgroundDownloader.backgroundCompletionHandler
                     else {
                return
            }
            backgroundCompletionHandler()
        }
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        if error != nil {
            completionHandler(nil, error)
        } else {
            completionHandler(destinationURL, nil)
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
            _ = try fileManager.replaceItemAt(destinationURL,
                                              withItemAt: location,
                                              backupItemName: location.lastPathComponent)
        } catch _ {
            let error = APIError(domain: "")
            completionHandler(nil, error)
        }
    }
}
