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

    private var uploadDialog: MDCAlertController?
    private var uploadRequest: UploadRequest?

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

    func createNode(with name: String, description: String?) {
        self.nodeName = name
        self.nodeDescription = description

        guard let nodeBody = self.nodeBody() else { return }

        if actionMenu.type != .createFolder {
            uploadDialog = showUploadDialog(actionHandler: { [weak self] _ in
                guard let sSelf = self else { return }
                sSelf.uploadRequest?.cancel()
            })
        }
        updateNodeDetails { [weak self] (listNode, _) in
            guard let sSelf = self, let listNode = listNode else { return }
            let shouldAutorename = (ListNode.getExtension(from: sSelf.actionMenu.type) != nil)
            let requestBuilder = NodesAPI.createNodeWithRequestBuilder(nodeId: listNode.guid,
                                                                       nodeBodyCreate: nodeBody,
                                                                       autoRename: shouldAutorename,
                                                                       include: nil,
                                                                       fields: nil)
            switch sSelf.actionMenu.type {
            case .createMSWord, .createMSExcel, .createMSPowerPoint:
                sSelf.createMSOfficeNode(with: requestBuilder, nodeBody: nodeBody)
            case .createFolder:
                sSelf.createNewFolder(with: requestBuilder)
            default: break
            }
        }
    }

    func creatingNewFolder() -> Bool {
        return actionMenu.type == .createFolder
    }

    // MARK: - Create Nodes

    private func createNewFolder(with requestBuilder: RequestBuilder<NodeEntry>) {
        requestBuilder.execute { [weak self] (result, error) in
            guard let sSelf = self else { return }
            if let error = error {
                sSelf.delegate?.createNode(node: nil, error: error)
                AlfrescoLog.error(error)
            } else if let node = result?.body?.entry {
                let listNode = NodeChildMapper.create(from: node)
                sSelf.delegate?.createNode(node: listNode, error: nil)
                sSelf.publishEventBus(with: listNode)
            }
        }
    }

    private func createMSOfficeNode(with requestBuilder: RequestBuilder<NodeEntry>,
                                    nodeBody: NodeBodyCreate) {
        guard let url = URL(string: requestBuilder.URLString) else { return }

        Alamofire.upload(multipartFormData: { [weak self] (formData) in
            guard let sSelf = self else { return }

            if let dataTemplate = sSelf.dataFromTemplateFile(),
               let dataNodeType = nodeBody.nodeType.data(using: .utf8),
               let dataAutoRename = "true".data(using: .utf8) {

                formData.append(dataTemplate,
                                withName: "filedata",
                                fileName: nodeBody.name,
                                mimeType: "")
                formData.append(dataNodeType, withName: "nodeType")
                formData.append(dataAutoRename, withName: "autoRename")

            }
            if let description = sSelf.nodeDescription,
               let dataDescription = description.data(using: .utf8) {
                formData.append(dataDescription, withName: "cm:description")
            }
        }, to: url,
        headers: AlfrescoContentAPI.customHeaders,
        encodingCompletion: { [weak self] encodingResult in
            guard let sSelf = self else { return }

            switch encodingResult {
            case .success(let upload, _, _) :
                sSelf.uploadRequest = upload
                upload.responseJSON { response in
                    sSelf.uploadDialog?.dismiss(animated: true)

                    if let error = response.error {
                        sSelf.handle(error: error)
                    } else {
                        if let data = response.data {
                            let resultDecode = sSelf.decode(data: data)
                            if let nodeEntry = resultDecode.0 {
                                let listNode = NodeChildMapper.create(from: nodeEntry.entry)
                                sSelf.delegate?.createNode(node: listNode, error: nil)
                                sSelf.publishEventBus(with: listNode)
                            }
                            if let error = resultDecode.1 {
                                sSelf.delegate?.createNode(node: nil, error: error)
                                AlfrescoLog.error(error)
                            }
                        }
                    }
                }
            case .failure(let encodingError):
                sSelf.uploadDialog?.dismiss(animated: true)
                sSelf.handle(error: encodingError)
            }
        })
    }

    // MARK: - Private Utils

    private func updateNodeDetails(handle: @escaping (ListNode?, Error?) -> Void) {
        guard parentListNode.kind == .site else { return handle(parentListNode, nil)}
        coordinatorServices?.accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            NodesAPI.getNode(nodeId: sSelf.parentListNode.guid,
                             include: [kAPIIncludePathNode,
                                       kAPIIncludeIsFavoriteNode,
                                       kAPIIncludeAllowableOperationsNode],
                             relativePath: kAPIPathRelativeForSites) { (result, error) in
                var listNode: ListNode?
                if let error = error {
                    AlfrescoLog.error(error)
                } else if let entry = result?.entry {
                    listNode = NodeChildMapper.create(from: entry)
                }
                handle(listNode, error)
            }
        })
    }

    private func decode(data: Data) -> (NodeEntry?, Error?) {
        let decodeResult: (decodableObj: NodeEntry?, error: Error?)
        decodeResult = CodableHelper.decode(NodeEntry.self, from: data)
        if let error = decodeResult.error {
            return (nil, error)
        } else if let nodeEntry = decodeResult.decodableObj {
            return (nodeEntry, nil)
        }
        return (nil, nil)
    }

    private func publishEventBus(with listNode: ListNode) {
        let moveEvent = MoveEvent(node: parentListNode, eventType: .created)
        let eventBusService = coordinatorServices?.eventBusService
        eventBusService?.publish(event: moveEvent, on: .mainQueue)

    }

    private func dataFromTemplateFile() -> Data? {
        guard let stringPath = ListNode.templateFileBundlePath(from: actionMenu.type)
        else { return nil }
        do {
            return try Data(contentsOf: URL(fileURLWithPath: stringPath))
        } catch {}
        return nil
    }

    private func showUploadDialog(actionHandler: @escaping (MDCAlertAction) -> Void) -> MDCAlertController? {
        if let uploadDialogView: DownloadDialog = DownloadDialog.fromNib() {
            let themingService = coordinatorServices?.themingService
            let nodeExtension = ListNode.getExtension(from: actionMenu.type) ?? ""
            let nodeNameWithExtension = ( nodeName ?? "" ) + nodeExtension
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
        guard let name = self.nodeName,
              let nodeType = ListNode.nodeType(from: actionMenu.type)
        else { return nil }

        let nodeExtension = ListNode.getExtension(from: actionMenu.type) ?? ""
        return NodeBodyCreate(name: name + nodeExtension,
                              nodeType: nodeType,
                              aspectNames: nil,
                              properties: nodeProperties(),
                              permissions: nil,
                              relativePath: nil,
                              association: nil,
                              secondaryChildren: nil,
                              targets: nil)
    }

    private func handle(error: Error) {
        if error.code == NSURLErrorNetworkConnectionLost ||
            error.code == NSURLErrorCancelled {
            delegate?.createNode(node: nil, error: nil)
            return
        }
        delegate?.createNode(node: nil, error: error)
        AlfrescoLog.error(error)
    }

    private func nodeProperties() -> JSONValue? {
        guard let name = self.nodeName,
              let description = self.nodeDescription
              else { return nil }
        return JSONValue(dictionaryLiteral:
                            ("cm:title", JSONValue(stringLiteral: name)),
                         ("cm:description", JSONValue(stringLiteral: description)))
    }
}
