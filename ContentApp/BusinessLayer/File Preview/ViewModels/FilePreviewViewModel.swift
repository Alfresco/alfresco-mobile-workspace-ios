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

protocol FilePreviewViewModelDelegate: class {
    func display(view: FilePreviewProtocol)
    func display(doneRequesting: Bool, error: Error?)
    func calculateViewForFullscreen()
}

class FilePreviewViewModel {
    var node: ListNode
    var accountService: AccountService?
    var apiClient: APIClientProtocol?
    weak var viewModelDelegate: FilePreviewViewModelDelegate?

    init(node: ListNode, with accountService: AccountService?) {
        self.node = node
        self.accountService = accountService
    }

    func requestFilePreview(with size: CGSize?) {
        let filePreviewType = FilePreview.preview(mimetype: node.mimeType)
        accountService?.activeAccount?.getTicket(completionHandler: { [weak self] (ticket, _) in
            guard let sSelf = self, let urlPreview = sSelf.getURLPreview(with: ticket), var size = size else { return }

            switch filePreviewType {
            case .video, .image, .gif:
                sSelf.viewModelDelegate?.calculateViewForFullscreen()
                size = kWindow.bounds.size
            default: break
            }

            let preview = FilePreviewFactory.getPreview(for: filePreviewType, and: urlPreview, on: size) { (done, error) in
                if error != nil {
                    let noPreview = FilePreviewFactory.getPreview(for: .noPreview, on: size)
                    sSelf.viewModelDelegate?.display(view: noPreview)
                }
                sSelf.viewModelDelegate?.display(doneRequesting: done, error: error)
            }
            sSelf.viewModelDelegate?.display(view: preview)
        })
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
