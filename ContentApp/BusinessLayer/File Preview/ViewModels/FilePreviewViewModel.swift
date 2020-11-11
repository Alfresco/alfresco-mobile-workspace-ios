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

class FilePreviewViewModel: EventObservable {
    var listNode: ListNode?
    var supportedNodeTypes: [ElementKindType]?
    var coordinatorServices: CoordinatorServices?

    private weak var viewModelDelegate: FilePreviewViewModelDelegate?
    var actionMenuViewModel: ActionMenuViewModel?
    var nodeActionsViewModel: NodeActionsViewModel?

    var pdfRenderer: PDFRenderer?
    var filePreview: FilePreviewProtocol?

    private var renditionTimer: Timer?

    // MARK: - Public interface

    init(with listNode: ListNode,
         delegate: FilePreviewViewModelDelegate?,
         coordinatorServices: CoordinatorServices) {
        self.listNode = listNode
        self.viewModelDelegate = delegate
        self.coordinatorServices = coordinatorServices
    }

    func requestFilePreview(with size: CGSize?) {
        guard var size = size, let listNode = listNode else { return }
        let filePreviewType = FilePreview.preview(mimetype: listNode.mimeType)

        switch filePreviewType {
        case .video, .image, .gif, .audio:
            viewModelDelegate?.enableFullscreenContentExperience()
            size = kWindow.bounds.size
        default: break
        }

        // Fetch or generate a rendition preview
        if filePreviewType == .rendition {
            fetchRenditionURL(for: listNode.guid) { [weak self] url, isImageRendition in
                guard let sSelf = self else { return }

                sSelf.previewFile(type: (isImageRendition ? .image : .rendition), at: url, with: size)
            }
        } else if filePreviewType == .text { // Show text content
            contentText { [weak self] (text, error) in
                guard let sSelf = self else { return }
                if let text = text {
                    let preview = FilePreviewFactory.getPlainTextPreview(with: text, on: size)
                    sSelf.filePreview = preview
                    sSelf.viewModelDelegate?.display(previewContainer: preview)
                    sSelf.viewModelDelegate?.didFinishLoadingPreview(error: nil)
                } else {
                    sSelf.viewModelDelegate?.enableFullscreenContentExperience()
                    let noPreview = FilePreviewFactory.getPreview(for: .noPreview,
                                                                  node: sSelf.listNode,
                                                                  size: size)
                    sSelf.filePreview = noPreview
                    sSelf.viewModelDelegate?.display(previewContainer: noPreview)
                    sSelf.viewModelDelegate?.didFinishLoadingPreview(error: error)
                }
            }
        } else { // Show the actual content from URL
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
        renditionTimer?.invalidate()
    }

    func sendAnalyticsForPreviewFile(success: Bool) {
        guard let listNode = listNode else { return }
        let fileExtension = listNode.title.split(separator: ".").last
        Analytics.logEvent(AnalyticsConstants.Events.filePreview,
                           parameters: [AnalyticsConstants.Parameters.fileMimetype: listNode.mimeType ?? "",
                                        AnalyticsConstants.Parameters.fileExtension: fileExtension ?? "",
                                        AnalyticsConstants.Parameters.previewSuccess: success])
    }

    func updateNodeDetails() {
        guard let listNode = self.listNode else { return }
        if listNode.shouldUpdateNode() == false {
            actionMenuViewModel = ActionMenuViewModel(with: coordinatorServices?.accountService,
                                                      listNode: listNode,
                                                      toolbarDivide: true)
            nodeActionsViewModel = NodeActionsViewModel(node: listNode,
                                                        delegate: nil,
                                                        nodeActionServices: coordinatorServices)
            viewModelDelegate?.didFinishNodeDetails(error: nil)
            return
        }
        coordinatorServices?.accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            NodesAPI.getNode(nodeId: listNode.guid,
                             include: [kAPIIncludePathNode,
                                       kAPIIncludeIsFavoriteNode,
                                       kAPIIncludeAllowableOperationsNode]) { (result, error) in
                if let error = error {
                    sSelf.viewModelDelegate?.didFinishNodeDetails(error: error)
                } else if let entry = result?.entry {
                    let listNode = NodeChildMapper.create(from: entry)
                    sSelf.listNode = listNode
                    sSelf.actionMenuViewModel =
                        ActionMenuViewModel(with: sSelf.coordinatorServices?.accountService,
                                            listNode: listNode,
                                            toolbarDivide: true)
                    sSelf.nodeActionsViewModel =
                        NodeActionsViewModel(node: listNode,
                                             delegate: nil,
                                             nodeActionServices: sSelf.coordinatorServices)
                    sSelf.viewModelDelegate?.didFinishNodeDetails(error: nil)
                }
            }
        })
    }

    // MARK: - Private interface

    private func contentText(_ completionHandler: @escaping (Data?, Error?) -> Void) {
        guard let listNode = listNode else { return }
        NodesAPI.getNodeContent(nodeId: listNode.guid) { (data, error) in
            if let error = error {
                AlfrescoLog.error(error)
            }
            completionHandler(data, error)
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

    private func renditionURL(for renditionId: String, ticket: String?) -> URL? {
        guard let ticket = ticket,
              let basePathURL = coordinatorServices?.accountService?.activeAccount?.apiBasePath,
              let listNode = listNode,
              let renditionURL = URL(string: basePathURL + "/" +
                                        String(format: kAPIPathGetRenditionContent,
                                               listNode.guid,
                                               renditionId,
                                               ticket))
        else { return nil }
        return renditionURL
    }

    private func fetchRenditionURL(for nodeId: String,
                                   completionHandler: @escaping (URL?, _ isImageRendition: Bool) -> Void) {
        viewModelDelegate?.willPreparePreview()

        coordinatorServices?.accountService?.activeAccount?.getSession(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            RenditionsAPI.listRenditions(nodeId: nodeId) { [weak self] (renditionPaging, _) in
                guard let sSelf = self, let renditionEntries = renditionPaging?.list?.entries else {
                    completionHandler(nil, false)
                    return
                }

                sSelf.getRenditionURL(from: renditionEntries,
                                      renditionId: RenditionType.pdf.rawValue) { url in
                    if url != nil {
                        completionHandler(url, false)
                    } else {
                        sSelf.getRenditionURL(from: renditionEntries,
                                              renditionId: RenditionType.imagePreview.rawValue) { url in
                            completionHandler(url, true)
                        }
                    }
                }
            }
        })
    }

    private func getRenditionURL(from list: [RenditionEntry],
                                 renditionId: String,
                                 completionHandler: @escaping RenditionCompletionHandler) {
        let rendition = list.filter { (rendition) -> Bool in
            rendition.entry._id == renditionId
        }.first

        if let rendition = rendition {
            let ticket = coordinatorServices?.accountService?.activeAccount?.getTicket()
            if rendition.entry.status == .created {
                completionHandler(renditionURL(for: renditionId, ticket: ticket))
            } else {
                let renditiontype = RenditionBodyCreate(_id: renditionId)

                let activeAccount = coordinatorServices?.accountService?.activeAccount
                activeAccount?.getSession(completionHandler: { [weak self] authenticationProvider in
                    AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

                    guard let sSelf = self, let listNode = sSelf.listNode else { return }

                    RenditionsAPI.createRendition(nodeId: listNode.guid,
                                                  renditionBodyCreate: renditiontype) {  (_, error) in
                        if error != nil {
                            AlfrescoLog.error("Unexpected error while creating rendition for node: \(listNode.guid)")
                        } else {
                            sSelf.retryRenditionCall(for: renditionId,
                                                     ticket: ticket,
                                                     completionHandler: completionHandler)
                        }
                    }
                })
            }
        } else {
            completionHandler(nil)
        }
    }

    private func retryRenditionCall(for renditionId: String,
                                    ticket: String?,
                                    completionHandler: @escaping RenditionCompletionHandler) {
        var retries = RenditionServiceConfiguration.maxRetries

        renditionTimer =
            Timer.scheduledTimer(withTimeInterval: RenditionServiceConfiguration.retryDelay,
                                 repeats: true) { [weak self] (timer) in
                guard let sSelf = self else { return }

                retries -= 1

                if retries == 0 {
                    timer.invalidate()
                    completionHandler(nil)
                }

                let activeAccount = sSelf.coordinatorServices?.accountService?.activeAccount
                activeAccount?.getSession(completionHandler: { authenticationProvider in
                    AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
                    guard let listNode = sSelf.listNode else { return }
                    RenditionsAPI.getRendition(nodeId: listNode.guid,
                                               renditionId: renditionId) { (rendition, _) in
                        if rendition?.entry.status == .created {
                            timer.invalidate()
                            completionHandler(sSelf.renditionURL(for: renditionId,
                                                                 ticket: ticket))
                        }
                    }
                })
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
                    sSelf.fetchRenditionURL(for: listNode.guid) { url, isImageRendition in
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

    // MARK: - Event observable

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
