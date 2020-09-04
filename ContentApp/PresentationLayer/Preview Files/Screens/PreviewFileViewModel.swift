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

protocol PreviewFileViewModelDelegate: class {
    func displayPDF(from url: URL)
    func displayImage(from url: URL)
    func display(error: Error)
    func displayNoPreview()
}

class PreviewFileViewModel {
    var node: ListNode
    var accountService: AccountService?
    var apiClient: APIClientProtocol?
    weak var viewModelDelegate: PreviewFileViewModelDelegate?

    init(node: ListNode, with accountService: AccountService?) {
        self.node = node
        self.accountService = accountService
    }

    func requestFilePreview() {
        let previewFileType = FilePreview.preview(mimetype: node.mimeType)
        let ticket = "TICKET_611f66fd17a19e382e859d646dcc4df66ac19639"
        // get/create auth TICKET
        guard let baseStringURL = accountService?.activeAccount?.apiBasePath,
            let urlPreview = URL(string: baseStringURL + "/" + String(format: kAPIPathGetContentNode, node.guid, ticket)) else {
            return
        }
        switch previewFileType {
        case .pdf:
            self.viewModelDelegate?.displayPDF(from: urlPreview)
        case .image:
            self.viewModelDelegate?.displayImage(from: urlPreview)
        default:
            self.viewModelDelegate?.displayNoPreview()
        }
    }
}
