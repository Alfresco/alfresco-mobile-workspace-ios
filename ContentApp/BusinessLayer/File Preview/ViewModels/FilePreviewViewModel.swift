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

import UIKit
import AlfrescoAuth
import AlfrescoContent
import Firebase

protocol FilePreviewViewModelDelegate: class {
    func display(view: FilePreviewProtocol)
    func display(doneRequesting: Bool, error: Error?)
    func enableFullscreenContentExperience()
    func requestFileUnlock(retry: Bool)
}

struct RenditionServiceConfiguration {
    static let maxRetries = 10
    static let retryDelay: TimeInterval = 5
}

enum RenditionType: String {
    case pdf = "pdf", imagePreview = "imgpreview"
}

class FilePreviewViewModel {
    var node: ListNode
    var accountService: AccountService?
    var apiClient: APIClientProtocol?

    weak var viewModelDelegate: FilePreviewViewModelDelegate?

    var pdfRenderer: PDFRenderer?
    var filePreview: FilePreviewProtocol?

    private var renditionTimer: Timer?

    // MARK: - Public interface

    init(node: ListNode, with accountService: AccountService?) {
        self.node = node
        self.accountService = accountService
    }

    func requestFilePreview(with size: CGSize?) {
        guard var size = size else { return }
        let filePreviewType = FilePreview.preview(mimetype: node.mimeType)

        switch filePreviewType {
        case .video, .image, .gif:
            viewModelDelegate?.enableFullscreenContentExperience()
            size = kWindow.bounds.size
        default: break
        }

        // Fetch or generate a rendition preview
        if filePreviewType == .rendition {
            fetchRenditionURL(for: node.guid) { [weak self] url, isImageRendition in
                guard let sSelf = self else { return }

                sSelf.previewFile(type: (isImageRendition ? .image : .rendition), at: url, with: size)
            }

        } else if filePreviewType == .text { // Show text content
            contentText { [weak self] (text, error) in
                guard let sSelf = self else { return }
                if let text = text {
                    let preview = FilePreviewFactory.getPlainTextPreview(with: text, on: size)
                    sSelf.filePreview = preview
                    sSelf.viewModelDelegate?.display(view: preview)
                    sSelf.viewModelDelegate?.display(doneRequesting: true, error: nil)
                } else {
                    let noPreview = FilePreviewFactory.getPreview(for: .noPreview, on: size)
                    sSelf.filePreview = noPreview
                    sSelf.viewModelDelegate?.display(view: noPreview)
                    sSelf.viewModelDelegate?.display(doneRequesting: true, error: error)
                }
            }
        } else { // Show the actual content from URL
            if let contentURL = contentURL(for: accountService?.activeAccount?.getTicket()) {
                previewFile(type: filePreviewType, at: contentURL, with: size)
            }
        }
    }

    func unlockFile(with password: String) {
        pdfRenderer?.unlockPDF(password: password)
    }

    func cancelOngoingOperations() {
        filePreview?.cancel()
        filePreview?.removeFromSuperview()
        filePreview = nil
        pdfRenderer = nil
        renditionTimer?.invalidate()
    }

    func sendAnalyticsForPreviewFile(success: Bool) {
        let fileExtension = node.title.split(separator: ".").last
        Analytics.logEvent(AnalyticsConstants.Events.filePreview,
                           parameters: [AnalyticsConstants.Parameters.fileMimetype: node.mimeType ?? "",
                                        AnalyticsConstants.Parameters.fileExtension: fileExtension ?? "",
                                        AnalyticsConstants.Parameters.previewSuccess: success])
    }

    // MARK: - Private interface

    private func contentText(_ completionHandler: @escaping (Data?, Error?) -> Void) {
        NodesAPI.getNodeContent(nodeId: node.guid) { (data, error) in
            if let error = error {
                AlfrescoLog.error(error)
            }
            completionHandler(data, error)
        }
    }

    private func contentURL(for ticket: String?) -> URL? {
        guard let ticket = ticket, let basePathURL = accountService?.activeAccount?.apiBasePath,
            let previewURL = URL(string: basePathURL + "/" + String(format: kAPIPathGetNodeContent, node.guid, ticket))
            else { return nil }
        return previewURL
    }

    private func renditionURL(for renditionId: String, ticket: String?) -> URL? {
        guard let ticket = ticket, let basePathURL = accountService?.activeAccount?.apiBasePath,
            let renditionURL = URL(string: basePathURL + "/" + String(format: kAPIPathGetRenditionContent, node.guid, renditionId, ticket))
            else { return nil }
        return renditionURL
    }

    private func fetchRenditionURL(for nodeId: String, completionHandler: @escaping (URL?, _ isImageRendition: Bool) -> Void) {
        accountService?.activeAccount?.getSession(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            RenditionsAPI.listRenditions(nodeId: nodeId) { [weak self] (renditionPaging, _) in
                guard let sSelf = self, let renditionEntries = renditionPaging?.list?.entries else {
                    completionHandler(nil, false)
                    return
                }

                sSelf.getRenditionURL(from: renditionEntries, renditionId: RenditionType.pdf.rawValue) { url in
                    if url != nil {
                        completionHandler(url, false)
                    } else {
                        sSelf.getRenditionURL(from: renditionEntries, renditionId: RenditionType.imagePreview.rawValue) { url in
                            completionHandler(url, true)
                        }
                    }
                }
            }
        })
    }

    private func getRenditionURL(from list: [RenditionEntry], renditionId: String, completionHandler: @escaping (URL?) -> Void) {
        let rendition = list.filter { (rendition) -> Bool in
            rendition.entry._id == renditionId
        }.first

        if let rendition = rendition {
            let ticket = accountService?.activeAccount?.getTicket()
            if rendition.entry.status == .created {
                completionHandler(renditionURL(for: renditionId, ticket: ticket))
            } else {
                let renditiontype = RenditionBodyCreate(_id: renditionId)
                RenditionsAPI.createRendition(nodeId: node.guid, renditionBodyCreate: renditiontype) { [weak self] (_, error) in
                    guard let sSelf = self else { return }

                    if error != nil {
                        AlfrescoLog.error("Unexpected error while creating rendition for node: \(sSelf.node.guid)")
                    } else {
                        var retries = RenditionServiceConfiguration.maxRetries

                        sSelf.renditionTimer = Timer.scheduledTimer(withTimeInterval: RenditionServiceConfiguration.retryDelay, repeats: true) { (timer) in
                            retries -= 1

                            if retries == 0 {
                                timer.invalidate()
                                completionHandler(nil)
                            }

                            RenditionsAPI.getRendition(nodeId: sSelf.node.guid, renditionId: renditionId) { (rendition, _) in
                                if rendition?.entry.status == .created {
                                    timer.invalidate()
                                    completionHandler(sSelf.renditionURL(for: renditionId, ticket: ticket))
                                }
                            }
                        }
                    }
                }
            }
        } else {
            completionHandler(nil)
        }
    }

    private func previewFile(type: FilePreviewType, at url: URL?, with size: CGSize) {
        guard let renditionURL = url else {
            let noPreview = FilePreviewFactory.getPreview(for: .noPreview, on: size)
            filePreview = noPreview
            viewModelDelegate?.display(view: noPreview)
            viewModelDelegate?.display(doneRequesting: true, error: NSError())

            return
        }

        let preview = FilePreviewFactory.getPreview(for: type, and: renditionURL, on: size) { [weak self] (done, error) in
            guard let sSelf = self else { return }

            if let error = error {
                sSelf.viewModelDelegate?.display(doneRequesting: true, error: error)

                let noPreview = FilePreviewFactory.getPreview(for: .noPreview, on: size)
                sSelf.filePreview = noPreview
                sSelf.viewModelDelegate?.display(view: noPreview)
            }

            sSelf.viewModelDelegate?.display(doneRequesting: done, error: nil)
        }

        filePreview = preview
        viewModelDelegate?.display(view: preview)

        // Set delegate for password requesting PDF renditions
        if let filePreview = preview as? PDFRenderer {
            filePreview.passwordDelegate = self
            pdfRenderer = filePreview
        }
    }
}

// MARK: - PDFRendererPasswordDelegate

extension FilePreviewViewModel: PDFRendererPasswordDelegate {
    func providePDFPassword(for pdf: URL) {
        viewModelDelegate?.requestFileUnlock(retry: false)
    }

    func invalidPasswordProvided(for pdf: URL) {
        viewModelDelegate?.requestFileUnlock(retry: true)
    }
}
