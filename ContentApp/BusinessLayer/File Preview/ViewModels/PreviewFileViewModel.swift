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
import MaterialComponents.MDCAlertController

protocol PreviewFileViewModelDelegate: class {
    func display(view: FilePreviewProtocol)
    func display(error: Error)
    func display(doneRequesting: Bool)
    func requestFileUnlock(retry: Bool)
}

class PreviewFileViewModel {
    var node: ListNode
    var accountService: AccountService?
    var apiClient: APIClientProtocol?
    weak var viewModelDelegate: PreviewFileViewModelDelegate?
    var pdfRenderer: PDFRenderer?

    init(node: ListNode, with accountService: AccountService?) {
        self.node = node
        self.accountService = accountService
    }

    func requestFilePreview(with size: CGSize?) {
        let filePreviewType = FilePreview.preview(mimetype: node.mimeType)
        accountService?.activeAccount?.getTicket(completionHandler: { [weak self] (ticket, _) in
            guard let sSelf = self, let urlPreview = sSelf.getURLPreview(with: ticket), let size = size else { return }
            let preview = FilePreviewFactory.getPreview(for: filePreviewType, and: urlPreview, on: size) { (done, error) in
                if let error = error {
                    sSelf.viewModelDelegate?.display(error: error)
                    let noPreview = FilePreviewFactory.getPreview(for: .noPreview, on: size)
                    sSelf.viewModelDelegate?.display(view: noPreview)
                }
                sSelf.viewModelDelegate?.display(doneRequesting: done)
            }
            sSelf.viewModelDelegate?.display(view: preview)

            // Set delegate for password requesting PDF renditions
            if let filePreview = preview as? PDFRenderer {
                filePreview.delegate = self
                sSelf.pdfRenderer = filePreview
            }
        })
    }

    func unlockFile(with password: String) {
        pdfRenderer?.unlockPDF(password: password)
    }

    private func getURLPreview(with ticket: String?) -> URL? {
        guard let ticket = ticket, let baseStringURL = accountService?.activeAccount?.apiBasePath,
            let urlPreview = URL(string: baseStringURL + "/" + String(format: kAPIPathGetContentNode, node.guid, ticket))
            else {
                return nil
        }
        return urlPreview
    }
}

// MARK: - PDFRendererPasswordDelegate

extension PreviewFileViewModel: PDFRendererPasswordDelegate {
    func providePDFPassword(for pdf: URL) {
        viewModelDelegate?.requestFileUnlock(retry: false)
    }

    func invalidPasswordProvided(for pdf: URL) {
        viewModelDelegate?.requestFileUnlock(retry: true)
    }
}
