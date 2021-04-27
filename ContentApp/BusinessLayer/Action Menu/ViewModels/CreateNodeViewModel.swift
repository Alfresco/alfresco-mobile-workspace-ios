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

protocol CreateNodeViewModelDelegate: AnyObject {
    func handleCreatedNode(node: ListNode?, error: Error?)
}

class CreateNodeViewModel {
    private var coordinatorServices: CoordinatorServices?
    private let nodeOperations: NodeOperations
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
        self.nodeOperations = NodeOperations(accountService: coordinatorServices?.accountService)
        self.actionMenu = actionMenu
        self.parentListNode = parentListNode
        self.delegate = delegate
    }

    // MARK: - Public

    func createNode(with name: String, description: String?) {
        self.nodeName = name
        self.nodeDescription = description

        if actionMenu.type != .createFolder {
            uploadDialog = showUploadDialog(actionHandler: { [weak self] _ in
                guard let sSelf = self else { return }
                sSelf.uploadRequest?.cancel()
            })
        }
        updateNodeDetails { [weak self] (listNode, _) in
            guard let sSelf = self, let listNode = listNode else { return }
            let shouldAutorename = (ListNode.getExtension(from: sSelf.actionMenu.type) != nil)

            switch sSelf.actionMenu.type {
            case .createFolder:
                sSelf.createNewFolder(nodeId: listNode.guid,
                                      autoRename: shouldAutorename)
            case .createMSWord, .createMSExcel, .createMSPowerPoint:
                sSelf.createMSOfficeNode(nodeId: listNode.guid,
                                         autoRename: shouldAutorename)
            case .createMedia, .uploadMedia: break
            default: break
            }
        }
    }

    func creatingNewFolder() -> Bool {
        return actionMenu.type == .createFolder
    }

    func createAction() -> String {
        return actionMenu.title
    }

    // MARK: - Create Nodes

    private func createNewFolder(nodeId: String,
                                 autoRename: Bool) {
        if let name = nodeName {
            nodeOperations.createNode(nodeId: nodeId,
                                      name: name,
                                      description: nodeDescription,
                                      autoRename: autoRename) { [weak self] (result, error) in
                guard let sSelf = self else { return }

                if let error = error {
                    sSelf.delegate?.handleCreatedNode(node: nil,
                                                      error: error)
                    AlfrescoLog.error(error)
                } else if let listNode = result {
                    sSelf.delegate?.handleCreatedNode(node: listNode, error: nil)
                    sSelf.publishEventBus(with: listNode)
                }
            }
        }
    }

    private func createMSOfficeNode(nodeId: String,
                                    autoRename: Bool) {
        if let dataTemplate = dataFromTemplateFile(),
           let name = nodeName,
           let nodeExtension = ListNode.getExtension(from: actionMenu.type) {
            nodeOperations.createNode(nodeId: nodeId,
                                      name: name,
                                      description: nodeDescription,
                                      nodeExtension: nodeExtension,
                                      fileData: dataTemplate,
                                      autoRename: autoRename) { [weak self] (result, error) in
                guard let sSelf = self else { return }

                sSelf.uploadDialog?.dismiss(animated: true)
                
                if let transferError = error {
                    sSelf.handle(error: transferError)
                } else if let listNode = result {
                    sSelf.delegate?.handleCreatedNode(node: listNode, error: nil)
                    sSelf.publishEventBus(with: listNode)
                }
            }
        }
    }

    // MARK: - Private Utils

    private func updateNodeDetails(handle: @escaping (ListNode?, Error?) -> Void) {
        guard parentListNode.nodeType == .site else { return handle(parentListNode, nil)}
        nodeOperations.fetchNodeDetails(for: parentListNode.guid,
                                        relativePath: APIConstants.Path.relativeSites) { (result, error) in
            var listNode: ListNode?
            if let error = error {
                AlfrescoLog.error(error)
            } else if let entry = result?.entry {
                listNode = NodeChildMapper.create(from: entry)
            }
            handle(listNode, error)
        }
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
        if let uploadDialogView: DownloadDialog = .fromNib() {
            let themingService = coordinatorServices?.themingService
            let nodeExtension = ListNode.getExtension(from: actionMenu.type) ?? ""
            let nodeNameWithExtension = ( nodeName ?? "" ) + nodeExtension
            uploadDialogView.messageLabel.text =
                String(format: LocalizationConstants.Dialog.uploadMessage,
                       nodeNameWithExtension)
            uploadDialogView.activityIndicator.startAnimating()
            uploadDialogView.applyTheme(themingService?.activeTheme)

            let cancelAction =
                MDCAlertAction(title: LocalizationConstants.General.cancel) { action in
                    actionHandler(action)
                }
            cancelAction.accessibilityIdentifier = "cancelActionButton"

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

    private func handle(error: Error) {
        if error.code == NSURLErrorNetworkConnectionLost ||
            error.code == NSURLErrorCancelled {
            delegate?.handleCreatedNode(node: nil, error: nil)
            return
        }
        delegate?.handleCreatedNode(node: nil, error: error)
        AlfrescoLog.error(error)
    }
}
