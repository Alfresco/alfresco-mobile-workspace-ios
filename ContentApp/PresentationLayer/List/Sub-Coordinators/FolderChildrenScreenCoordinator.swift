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
import MaterialComponents.MaterialDialogs

protocol FolderChildrenScreenCoordinatorDelegate: AnyObject {
    func updateListNode(with node: ListNode)
}

class FolderChildrenScreenCoordinator: PresentingCoordinator {
    private let presenter: UINavigationController
    private var listNode: ListNode
    private var actionMenuCoordinator: ActionMenuScreenCoordinator?
    private var createNodeSheetCoordinator: CreateNodeSheetCoordinator?
    private var cameraCoordinator: CameraScreenCoordinator?
    private var photoLibraryCoordinator: PhotoLibraryScreenCoordinator?
    private var model: FolderDrillModel?
    private var fileManagerCoordinator: FileManagerScreenCoordinator?
    private var scanDocumentsCoordinator: ScanDocumentsScreenCoordinator?
    var sourceNodeToMove: ListNode?
    var nodeActionsModel: NodeActionsViewModel?

    init(with presenter: UINavigationController, listNode: ListNode) {
        self.presenter = presenter
        self.listNode = listNode
    }

    override func start() {
        let viewModelFactory = FolderChildrenViewModelFactory(services: coordinatorServices)
        let folderChildrenDataSource = viewModelFactory.folderChildrenDataSource(for: listNode)
        self.model = viewModelFactory.model
        self.model?.folderChildrenDelegate = self

        let viewController = ListViewController()
        viewController.title = listNode.title
        AnalyticsManager.shared.pageViewEvent(for: Event.Page.personalFiles)
        viewController.sourceNodeToMove = sourceNodeToMove
        viewController.destinationNodeToMove = listNode

        let viewModel = folderChildrenDataSource.folderDrillDownViewModel
        let pageController = ListPageController(dataSource: viewModel.model,
                                                services: coordinatorServices)

        let searchViewModel = folderChildrenDataSource.contextualSearchViewModel
        let searchPageController = ListPageController(dataSource: searchViewModel.searchModel,
                                                      services: coordinatorServices)

        viewController.pageController = pageController
        viewController.searchPageController = searchPageController
        viewController.viewModel = viewModel
        viewController.searchViewModel = searchViewModel
        viewController.isChildFolder = true

        viewController.coordinatorServices = coordinatorServices
        viewController.listItemActionDelegate = self

        presenter.pushViewController(viewController, animated: true)
    }
}

extension FolderChildrenScreenCoordinator: ListItemActionDelegate {
    func showPreview(for node: ListNode,
                     from dataSource: ListComponentModelProtocol) {
        if node.isAFolderType() || node.nodeType == .site {
            startFolderCoordinator(for: node,
                                   presenter: self.presenter,
                                   sourceNodeToMove: sourceNodeToMove)
        } else if node.isAFileType() {
            startFileCoordinator(for: node,
                                 presenter: self.presenter)
        } else {
            AlfrescoLog.error("Unable to show preview for unknown node type")
        }
    }

    func showActionSheetForListItem(for node: ListNode,
                                    from dataSource: ListComponentModelProtocol,
                                    delegate: NodeActionsViewModelDelegate) {
        let actionMenuViewModel = ActionMenuViewModel(node: node,
                                                      coordinatorServices: coordinatorServices)
        let nodeActionsModel = NodeActionsViewModel(node: node,
                                                    delegate: delegate,
                                                    coordinatorServices: coordinatorServices)
        nodeActionsModel.moveDelegate = self
        let coordinator = ActionMenuScreenCoordinator(with: self.presenter,
                                                      actionMenuViewModel: actionMenuViewModel,
                                                      nodeActionViewModel: nodeActionsModel)
        coordinator.start()
        actionMenuCoordinator = coordinator
    }

    func showNodeCreationSheet(delegate: NodeActionsViewModelDelegate) {
        let actions = ActionsMenuCreateFAB.actions()
        let actionMenuViewModel = ActionMenuViewModel(menuActions: actions,
                                                      coordinatorServices: coordinatorServices)
        let nodeActionsModel = NodeActionsViewModel(delegate: delegate,
                                                    coordinatorServices: coordinatorServices)
        let coordinator = ActionMenuScreenCoordinator(with: self.presenter,
                                                      actionMenuViewModel: actionMenuViewModel,
                                                      nodeActionViewModel: nodeActionsModel)
        coordinator.start()
        actionMenuCoordinator = coordinator
    }

    func showNodeCreationDialog(with actionMenu: ActionMenu,
                                delegate: CreateNodeViewModelDelegate?) {
        let coordinator = CreateNodeSheetCoordinator(with: presenter,
                                                     actionMenu: actionMenu,
                                                     parentListNode: listNode,
                                                     createNodeViewModelDelegate: delegate,
                                                     createNodeViewType: .create)
        coordinator.start()
        createNodeSheetCoordinator = coordinator
    }
    
    func showCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let coordinator = CameraScreenCoordinator(with: presenter,
                                                      parentListNode: listNode)
            coordinator.start()
            cameraCoordinator = coordinator
        } else {
            let title = LocalizationConstants.Alert.alertTitle
            let message = LocalizationConstants.Alert.cameraUnavailable
            self.showAlert(with: title, and: message)
        }
    }
    
    func showPhotoLibrary() {
        let coordinator = PhotoLibraryScreenCoordinator(with: presenter,
                                                        parentListNode: listNode)
        coordinator.start()
        photoLibraryCoordinator = coordinator
    }
    
    private func showAlert(with title: String,
                           and message: String) {
        let confirmAction = MDCAlertAction(title: LocalizationConstants.General.ok) {  _ in
        }
        confirmAction.accessibilityIdentifier = "confirmActionButton"
        _ = presenter.showDialog(title: title,
                                  message: message,
                                  actions: [confirmAction],
                                  completionHandler: {})
    }
    
    func showFiles() {
        let coordinator = FileManagerScreenCoordinator(with: presenter,
                                                        parentListNode: listNode)
        coordinator.start()
        fileManagerCoordinator = coordinator
    }
    
    func scanDocumentsAction() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let coordinator = ScanDocumentsScreenCoordinator(with: presenter,
                                                            parentListNode: listNode)
            coordinator.start()
            scanDocumentsCoordinator = coordinator
        } else {
            let title = LocalizationConstants.Alert.alertTitle
            let message = LocalizationConstants.Alert.cameraUnavailable
            self.showAlert(with: title, and: message)
        }
    }
    
    func moveNodeTapped(for sourceNode: ListNode,
                        destinationNode: ListNode,
                        delegate: NodeActionsViewModelDelegate,
                        actionMenu: ActionMenu) {
        let nodeActionsModel = NodeActionsViewModel(node: sourceNode,
                                                    delegate: delegate,
                                                    coordinatorServices: coordinatorServices)
        nodeActionsModel.moveFilesAndFolder(with: sourceNode, and: destinationNode, action: actionMenu)
        self.nodeActionsModel = nodeActionsModel
    }
    
    func renameNodeForListItem(for node: ListNode?, actionMenu: ActionMenu,
                               delegate: CreateNodeViewModelDelegate?) {
        if let node = node {
            let coordinator = CreateNodeSheetCoordinator(with: self.presenter,
                                                         actionMenu: actionMenu,
                                                         parentListNode: node,
                                                         createNodeViewModelDelegate: delegate,
                                                         createNodeViewType: .rename)
            coordinator.start()
            createNodeSheetCoordinator = coordinator
        }
    }
}

extension FolderChildrenScreenCoordinator: FolderChildrenScreenCoordinatorDelegate {
    func updateListNode(with node: ListNode) {
        self.listNode = node
    }
}

extension FolderChildrenScreenCoordinator: NodeActionMoveDelegate {
    func didSelectMoveFile(node: ListNode?, action: ActionMenu) {
        let navigationViewController = self.presenter
        let controller = FilesandFolderListViewController.instantiateViewController()
        controller.sourceNodeToMove = node
        let navController = UINavigationController(rootViewController: controller)
        navigationViewController.present(navController, animated: true)
    }
}
