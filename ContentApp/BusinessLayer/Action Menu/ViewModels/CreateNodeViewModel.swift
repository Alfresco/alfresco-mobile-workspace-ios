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

import Foundation
import AlfrescoContent
import Alamofire
import MaterialComponents.MaterialDialogs

protocol CreateNodeViewModelDelegate: class {
    func createNode(node: ListNode?, error: Error?)
}

class CreateNodeViewModel {
    private var coordinatorServices: CoordinatorServices?
    private var actionMenu: ActionMenu
    private var parentListNode: ListNode
    private var nodeName: String?
    private var nodeDescription: String?
    private weak var delegate: CreateNodeViewModelDelegate?

    // MARK: - Init

    init(with actionMenu: ActionMenu,
         parentListNode: ListNode,
         coordinatorServices: CoordinatorServices?,
         delegate: CreateNodeViewModelDelegate?) {

        self.coordinatorServices = coordinatorServices
        self.actionMenu = actionMenu
        self.parentListNode = parentListNode
        self.delegate = delegate
    }

    // MARK: - Public

    func requestUploadNode(with name: String, description: String?) {
        var uploadDialog: MDCAlertController?

        self.nodeName = name
        self.nodeDescription = description

        guard let nodeBody = self.nodeBody() else { return }

        uploadDialog = showUploadDialog(actionHandler: { _ in
        })
        let requestBuilder = NodesAPI.createNodeWithRequestBuilder(nodeId: parentListNode.guid,
                                                                   nodeBodyCreate: nodeBody,
                                                                   autoRename: true,
                                                                   include: nil,
                                                                   fields: nil)
        guard let url = URL(string: requestBuilder.URLString) else { return }
        Alamofire.upload(multipartFormData: { [weak self] (formData) in
            guard let sSelf = self else { return }
            if let dataTemplate = sSelf.dataFromTemplateFile() {
                formData.append(dataTemplate, withName: "filedata", fileName: nodeBody.name, mimeType: "")
            }
            if let data = nodeBody.nodeType.data(using: .utf8) {
                formData.append(data, withName: "nodeType")
            }
        }, to: url, headers: AlfrescoContentAPI.customHeaders) { [weak self] (result) in
            guard let sSelf = self else { return }
            uploadDialog?.dismiss(animated: true, completion: nil)
            switch result {
            case .failure(let error):
                sSelf.delegate?.createNode(node: nil, error: error)
                AlfrescoLog.error(error)
            case .success(request: _, streamingFromDisk: _, streamFileURL: _):
                let listNode = ListNode(guid: "", title: nodeBody.name, path: "", kind: .file)
                sSelf.delegate?.createNode(node: listNode, error: nil)
                let moveEvent = MoveEvent(node: sSelf.parentListNode, eventType: .created)
                let eventBusService = sSelf.coordinatorServices?.eventBusService
                eventBusService?.publish(event: moveEvent, on: .mainQueue)
            }
        }
    }

    // MARK: - Private

    private func dataFromTemplateFile() -> Data? {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: actionMenu.getTemplateBundlePath()))
            return data
        } catch {
        }
        return nil
    }

    private func showUploadDialog(actionHandler: @escaping (MDCAlertAction) -> Void) -> MDCAlertController? {
        if let uploadDialogView: DownloadDialog = DownloadDialog.fromNib() {
            let themingService = coordinatorServices?.themingService
            let nodeNameWithExtension = ( nodeName ?? "" ) + "." + actionMenu.getExtension()
            uploadDialogView.messageLabel.text =
                String(format: LocalizationConstants.NodeActionsDialog.uploadMessage,
                       nodeNameWithExtension)
            uploadDialogView.activityIndicator.startAnimating()
            uploadDialogView.applyTheme(themingService?.activeTheme)

            let cancelAction =
                MDCAlertAction(title: LocalizationConstants.Buttons.cancel) { action in
                    actionHandler(action)
            }

            if let presentationContext = UIViewController.applicationTopMostPresented {
                let downloadDialog = presentationContext.showDialog(title: nil,
                                                                    message: nil,
                                                                    actions: [cancelAction],
                                                                    accesoryView: uploadDialogView,
                                                                    completionHandler: {})
                return downloadDialog
            }
        }
        return nil
    }

    private func nodeBody() -> NodeBodyCreate? {
        guard let name = self.nodeName else { return nil }
        return NodeBodyCreate(name: name + "."  + actionMenu.getExtension(),
                              nodeType: actionMenu.getNodeType(),
                              aspectNames: nil,
                              properties: nil,
                              permissions: nil,
                              relativePath: nil,
                              association: nil,
                              secondaryChildren: nil,
                              targets: nil)
    }
}
