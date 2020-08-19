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
    func display(pdf data: Data)
    func display(text: String)
    func display(image: UIImage)
    func display(video: URL)
    func display(error: Error)
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

    func request() {
        switch FilePreview.preview(mimetype: node.mimeType) {
        case .pdf:
            requestPDFContent()
        case .text:
            requestTextContent()
        case .image:
            requestImageContent()
        case .renditionPdf:
            requestRenditionPDFContent()
        case .video, .audio:
            requestVideoContent()
        default:
            break
        }
    }

    func requestVideoContent() {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            NodesAPI.getNodeContent(nodeId: sSelf.node.guid) { (data, error) in
                if let error = error {
                    AlfrescoLog.error(error)
                    DispatchQueue.main.async {
                        sSelf.viewModelDelegate?.display(error: error)
                    }
                } else if let data = data {
                    if let url = DiskServices.saveVideo(named: sSelf.node.guid + "_" + sSelf.node.title, data: data) {
                        DispatchQueue.main.async {
                            sSelf.viewModelDelegate?.display(video: url)
                        }
                    }
                }
            }
        })
    }

    func requestPDFContent() {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            NodesAPI.getNodeContent(nodeId: sSelf.node.guid) { (data, error) in
                if let error = error {
                    AlfrescoLog.error(error)
                    DispatchQueue.main.async {
                        sSelf.viewModelDelegate?.display(error: error)
                    }
                } else if let data = data {
                    DispatchQueue.main.async {
                        sSelf.viewModelDelegate?.display(pdf: data)
                    }
                }
            }
        })
    }

    func requestRenditionPDFContent() {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            RenditionsAPI.getRenditionContent(nodeId: sSelf.node.guid, renditionId: "pdf") { (data, error) in
                if let error = error {
                    AlfrescoLog.error(error)
                    DispatchQueue.main.async {
                        sSelf.viewModelDelegate?.display(error: error)
                    }
                } else if let data = data {
                    DispatchQueue.main.async {
                        sSelf.viewModelDelegate?.display(pdf: data)
                    }
                }
            }
        })
    }

    func requestTextContent() {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            NodesAPI.getNodeContent(nodeId: sSelf.node.guid) { (data, error) in
                if let error = error {
                    AlfrescoLog.error(error)
                    DispatchQueue.main.async {
                        sSelf.viewModelDelegate?.display(error: error)
                    }
                } else if let data = data {
                    if let text = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            sSelf.viewModelDelegate?.display(text: text)
                        }
                    } else {
                        AlfrescoLog.error("String(data: data, encoding: .utf8)")
                    }
                }
            }
        })
    }

    func requestImageContent() {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            NodesAPI.getNodeContent(nodeId: sSelf.node.guid) { (data, error) in
                if let error = error {
                    AlfrescoLog.error(error)
                    DispatchQueue.main.async {
                        sSelf.viewModelDelegate?.display(error: error)
                    }
                } else if let data = data {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            sSelf.viewModelDelegate?.display(image: image)
                        }
                    } else {
                        AlfrescoLog.error("UIImage(data: data)")
                    }
                }
            }
        })
    }
}
