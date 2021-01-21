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
    func display(previewContainer: FilePreviewProtocol)
    func didFinishLoadingPreview(error: Error?)
    func willPreparePreview()
    func enableFullscreenContentExperience()
    func requestFileUnlock(retry: Bool)
    func update(listNode: ListNode)
    func didFinishNodeDetails(error: Error?)
}

struct RenditionServiceConfiguration {
    static let maxRetries = 10
    static let retryDelay: TimeInterval = 5
}

enum RenditionType: String {
    case pdf = "pdf", imagePreview = "imgpreview"
}

enum FilePreviewError: Error {
    case invalidRenditionURL(String)
}

typealias RenditionCompletionHandler = (URL?) -> Void

class FilePreviewViewModel {
    var listNode: ListNode?
    var supportedNodeTypes: [NodeType]?
    var coordinatorServices: CoordinatorServices?
    let nodeOperations: NodeOperations
    let listNodeDataAccessor: ListNodeDataAccessor = ListNodeDataAccessor()

    private weak var viewModelDelegate: FilePreviewViewModelDelegate?
    var actionMenuViewModel: ActionMenuViewModel?
    var nodeActionsViewModel: NodeActionsViewModel?

    var pdfRenderer: PDFRenderer?
    var filePreview: FilePreviewProtocol?

    // MARK: - Public interface

    init(with listNode: ListNode,
         delegate: FilePreviewViewModelDelegate?,
         coordinatorServices: CoordinatorServices) {

        self.listNode = listNode
        self.viewModelDelegate = delegate
        self.coordinatorServices = coordinatorServices
        self.nodeOperations = NodeOperations(accountService: coordinatorServices.accountService)
    }

    func requestUpdateNodeDetails() {
        guard let listNode = self.listNode, shouldUpdateNode() == true else { return }
        let guid = (listNode.nodeType == .fileLink) ? listNode.destination ?? listNode.guid : listNode.guid

        nodeOperations.fetchNodeDetails(for: guid) {[weak self] (result, error) in
            guard let sSelf = self else { return }
            if let error = error {
                sSelf.viewModelDelegate?.didFinishNodeDetails(error: error)
            } else if let entry = result?.entry {
                let listNode = NodeChildMapper.create(from: entry)
                sSelf.listNode = listNode
                sSelf.actionMenuViewModel =
                    ActionMenuViewModel(node: listNode,
                                        toolbarDisplayed: true,
                                        coordinatorServices: sSelf.coordinatorServices)
                sSelf.nodeActionsViewModel =
                    NodeActionsViewModel(node: listNode,
                                         delegate: nil,
                                         coordinatorServices: sSelf.coordinatorServices)
                sSelf.viewModelDelegate?.didFinishNodeDetails(error: nil)
            }
        }
    }

    func requestFilePreview(with size: CGSize?) {
        guard var size = size, let listNode = listNode else { return }

        if listNodeDataAccessor.isContentDownloaded(for: listNode) {
            previewOffline(with: size)
            return
        }
        let filePreviewType = FilePreview.preview(mimetype: listNode.mimeType)

        switch filePreviewType {
        case .video, .image, .gif, .audio:
            size = requestFullScreenExperience()
            if let contentURL =
                contentURL(for: coordinatorServices?.accountService?.activeAccount?.getTicket()) {
                previewFile(type: filePreviewType, at: contentURL, with: size)
            }
        case .rendition:
            viewModelDelegate?.willPreparePreview()
            nodeOperations.fetchRenditionURL(for: listNode.guid) { [weak self] url, isImageRendition in
                guard let sSelf = self else { return }
                if isImageRendition {
                    size = sSelf.requestFullScreenExperience()
                }
                sSelf.previewFile(type: (isImageRendition ? .image : .rendition),
                                  at: url,
                                  with: size)
            }
        case .text:
            previewContentFileText(with: size)
        default:
            if let contentURL =
                contentURL(for: coordinatorServices?.accountService?.activeAccount?.getTicket()) {
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
        nodeOperations.renditionTimer?.invalidate()
    }

    // MARK: - Analytics

    func sendAnalyticsForPreviewFile(success: Bool) {
        guard let listNode = listNode else { return }
        let fileExtension = listNode.title.split(separator: ".").last
        Analytics.logEvent(AnalyticsConstants.Events.filePreview,
                           parameters: [AnalyticsConstants.Parameters.fileMimetype: listNode.mimeType ?? "",
                                        AnalyticsConstants.Parameters.fileExtension: fileExtension ?? "",
                                        AnalyticsConstants.Parameters.previewSuccess: success])
    }

    // MARK: - Private Helpers

    private func shouldUpdateNode() -> Bool {
        guard let listNode = self.listNode else { return false }

        if listNode.shouldUpdate() == false &&
            listNode.nodeType != .fileLink ||
            listNodeDataAccessor.isContentDownloaded(for: listNode) {

            actionMenuViewModel = ActionMenuViewModel(node: listNode,
                                                      toolbarDisplayed: true,
                                                      coordinatorServices: coordinatorServices)
            nodeActionsViewModel = NodeActionsViewModel(node: listNode,
                                                        delegate: nil,
                                                        coordinatorServices: coordinatorServices)
            viewModelDelegate?.didFinishNodeDetails(error: nil)
            return false
        }
        return true
    }

    private func requestFullScreenExperience() -> CGSize {
        viewModelDelegate?.enableFullscreenContentExperience()
        return kWindow.bounds.size
    }

    // MARK: - Preview

    private func previewOffline(with size: CGSize) {
        guard let listNode = listNode else { return }
        var size = size

        let filePreviewType = FilePreview.preview(mimetype: listNode.mimeType)
        var previewURL = listNodeDataAccessor.fileLocalPath(for: listNode)

        switch filePreviewType {
        case .video, .image, .gif, .audio:
            size = requestFullScreenExperience()
        case .rendition:
            let renditionType = listNodeDataAccessor.localRenditionType(for: listNode)

            if renditionType == .imagePreview {
                size = requestFullScreenExperience()
            }

            let isImageRendition = renditionType == .imagePreview ? true : false
            previewURL = listNodeDataAccessor.renditionLocalPath(for: listNode,
                                                                 isImageRendition: isImageRendition)
        default: break
        }

        let preview = FilePreviewFactory.getPreview(for: filePreviewType,
                                                    node: listNode,
                                                    url: previewURL,
                                                    size: size) { [weak self] (error) in
            guard let sSelf = self else { return }
            sSelf.viewModelDelegate?.didFinishLoadingPreview(error: nil)
        }

        filePreview = preview
        viewModelDelegate?.display(previewContainer: preview)

        // Set delegate for password requesting PDF renditions
        if let filePreview = preview as? PDFRenderer {
            filePreview.passwordDelegate = self
            pdfRenderer = filePreview
        }
    }

    private func previewFile(type: FilePreviewType, at url: URL?, with size: CGSize) {
        guard let renditionURL = url else {
            viewModelDelegate?.enableFullscreenContentExperience()
            let noPreview = FilePreviewFactory.getPreview(for: .noPreview,
                                                          node: listNode,
                                                          size: size)
            filePreview = noPreview
            viewModelDelegate?.display(previewContainer: noPreview)
            let error = FilePreviewError.invalidRenditionURL("No rendition URL provided")
            viewModelDelegate?.didFinishLoadingPreview(error: error)

            return
        }

        let preview = FilePreviewFactory.getPreview(for: type,
                                                    node: listNode,
                                                    url: renditionURL,
                                                    size: size) { [weak self] (error) in
            guard let sSelf = self, let listNode = sSelf.listNode else { return }

            if let error = error {
                if type != .pdf || type != .rendition {
                    sSelf.nodeOperations.fetchRenditionURL(for: listNode.guid) { url, isImageRendition in
                        sSelf.previewFile(type: (isImageRendition ? .image : .rendition),
                                          at: url,
                                          with: size)
                    }
                } else {
                    sSelf.viewModelDelegate?.enableFullscreenContentExperience()
                    let noPreview = FilePreviewFactory.getPreview(for: .noPreview,
                                                                  node: sSelf.listNode,
                                                                  size: size)
                    sSelf.filePreview = noPreview
                    sSelf.viewModelDelegate?.display(previewContainer: noPreview)
                    sSelf.viewModelDelegate?.didFinishLoadingPreview(error: error)
                }
            } else {
                sSelf.viewModelDelegate?.didFinishLoadingPreview(error: nil)
            }
        }

        filePreview = preview
        viewModelDelegate?.display(previewContainer: preview)

        // Set delegate for password requesting PDF renditions
        if let filePreview = preview as? PDFRenderer {
            filePreview.passwordDelegate = self
            pdfRenderer = filePreview
        }
    }

    // MARK: - Content

    private func previewContentFileText(with size: CGSize) {
        guard let listNode = listNode else { return }
        nodeOperations.sessionForCurrentAccount { [weak self] _ in
            guard let sSelf = self else { return }

            NodesAPI.getNodeContent(nodeId: listNode.guid) { (data, error) in
                if let text = data {
                    let preview = FilePreviewFactory.getPlainTextPreview(with: text, on: size)
                    sSelf.filePreview = preview
                    sSelf.viewModelDelegate?.display(previewContainer: preview)
                    sSelf.viewModelDelegate?.didFinishLoadingPreview(error: nil)
                } else if let error = error {
                    AlfrescoLog.error(error)
                    sSelf.viewModelDelegate?.enableFullscreenContentExperience()
                    let noPreview = FilePreviewFactory.getPreview(for: .noPreview,
                                                                  node: sSelf.listNode,
                                                                  size: size)
                    sSelf.filePreview = noPreview
                    sSelf.viewModelDelegate?.display(previewContainer: noPreview)
                    sSelf.viewModelDelegate?.didFinishLoadingPreview(error: error)
                }
            }
        }
    }

    private func contentURL(for ticket: String?) -> URL? {
        guard let ticket = ticket,
              let basePathURL = coordinatorServices?.accountService?.activeAccount?.apiBasePath,
              let listNode = listNode,
              let previewURL = URL(string: basePathURL + "/" +
                                    String(format: kAPIPathGetNodeContent, listNode.guid, ticket))
        else { return nil }
        return previewURL
    }
}

extension FilePreviewViewModel: EventObservable {
    func handle(event: BaseNodeEvent, on queue: EventQueueType) {
        if let publishedEvent = event as? FavouriteEvent {
            guard let listNode = listNode else { return }
            let node = publishedEvent.node
            listNode.favorite = node.favorite
            self.viewModelDelegate?.update(listNode: listNode)
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
