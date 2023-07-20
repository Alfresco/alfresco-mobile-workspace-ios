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

protocol FolderChildrenScreenCoordinatorDelegate: AnyObject {
    func updateListNode(with node: ListNode)
}

class FolderChildrenScreenCoordinator: PresentingCoordinator {
    private let presenter: UINavigationController
    private var folderChildrenViewController: ListViewController?
    private var listNode: ListNode
    private var actionMenuCoordinator: ActionMenuScreenCoordinator?
    private var createNodeSheetCoordinator: CreateNodeSheetCoordinator?
    private var cameraCoordinator: CameraScreenCoordinator?
    private var photoLibraryCoordinator: PhotoLibraryScreenCoordinator?
    private var model: FolderDrillModel?
    private var fileManagerCoordinator: FileManagerScreenCoordinator?
    var sourceNodeToMove: [ListNode]?
    var nodeActionsModel: NodeActionsViewModel?
    private var multipleSelectionActionMenuCoordinator: MultipleFileActionMenuScreenCoordinator?
    private var filesAndFolderViewController: FilesandFolderListViewController?
    let refreshGroup = DispatchGroup()

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
        folderChildrenViewController = viewController
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
                                                      nodeActionViewModel: nodeActionsModel,
                                                      listNode: node)
        coordinator.start()
        actionMenuCoordinator = coordinator
    }

    func showActionSheetForMultiSelectListItem(for nodes: [ListNode],
                                               from dataSource: ListComponentModelProtocol,
                                               delegate: NodeActionsViewModelDelegate) {
        let actionMenuViewModel = MultipleSelectionActionMenuViewModel(nodes: nodes,
                                                      coordinatorServices: coordinatorServices)
        
        let nodeActionsModel = NodeActionsViewModel(node: nodes.first,
                                                    delegate: delegate,
                                                    coordinatorServices: coordinatorServices,
                                                    multipleNodes: nodes)
        nodeActionsModel.moveDelegate = self
        
        let coordinator = MultipleFileActionMenuScreenCoordinator(with: self.presenter,
                                                                  actionMenuViewModel: actionMenuViewModel,
                                                                  nodeActionViewModel: nodeActionsModel,
                                                                  listNodes: nodes)
        coordinator.start()
        multipleSelectionActionMenuCoordinator = coordinator
    }
    
    func didSelectMoveMultipleListItems(for nodes: [ListNode],
                                        from dataSource: ListComponentModelProtocol,
                                        delegate: NodeActionsViewModelDelegate) {
       
        let actionMenu = ActionMenu(title: LocalizationConstants.ActionMenu.moveToFolder, type: .moveToFolder)
        didSelectMoveFile(node: nodes, action: actionMenu)
    }
    
    
    func showNodeCreationSheet(delegate: NodeActionsViewModelDelegate) {
        let actions = ActionsMenuCreateFAB.actions()
        let actionMenuViewModel = ActionMenuViewModel(menuActions: actions,
                                                      coordinatorServices: coordinatorServices)
        let nodeActionsModel = NodeActionsViewModel(delegate: delegate,
                                                    coordinatorServices: coordinatorServices)
        let coordinator = ActionMenuScreenCoordinator(with: self.presenter,
                                                      actionMenuViewModel: actionMenuViewModel,
                                                      nodeActionViewModel: nodeActionsModel,
                                                      listNode: nil)
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
        let coordinator = CameraScreenCoordinator(with: presenter,
                                                  parentListNode: listNode,
                                                  attachmentType: .content)
        coordinator.start()
        cameraCoordinator = coordinator
    }
    
    func showPhotoLibrary() {
        let coordinator = PhotoLibraryScreenCoordinator(with: presenter,
                                                        parentListNode: listNode,
                                                        attachmentType: .content)
        coordinator.start()
        photoLibraryCoordinator = coordinator
    }
    
    func showFiles() {
        let coordinator = FileManagerScreenCoordinator(with: presenter,
                                                       parentListNode: listNode,
                                                       attachmentType: .content)
        coordinator.start()
        fileManagerCoordinator = coordinator
    }
    
    func moveNodeTapped(for sourceNode: [ListNode],
                        destinationNode: ListNode,
                        delegate: NodeActionsViewModelDelegate,
                        actionMenu: ActionMenu) {
        for node in sourceNode {
            refreshGroup.enter()
            let nodeActionsModel = NodeActionsViewModel(node: node,
                                                        delegate: delegate,
                                                        coordinatorServices: coordinatorServices,
                                                        multipleNodes: sourceNode)
            nodeActionsModel.moveFilesAndFolder(with: node, and: destinationNode, action: actionMenu)
            self.nodeActionsModel = nodeActionsModel
            self.refreshGroup.leave()
        }
        
        refreshGroup.notify(queue: CameraKit.cameraWorkerQueue) {[weak self] in
            guard let sSelf = self else { return }
            sSelf.nodeActionsModel?.updateResponseForMove(with: actionMenu)
        }
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
    func didSelectMoveFile(node: [ListNode], action: ActionMenu) {
        let navigationViewController = self.presenter
        let controller = FilesandFolderListViewController.instantiateViewController()
        controller.sourceNodeToMove = node
        let navController = UINavigationController(rootViewController: controller)
        navigationViewController.present(navController, animated: true)
        filesAndFolderViewController = controller
        filesAndFolderViewController?.didSelectDismissAction = {[weak self] in
            guard let sSelf = self else { return }
            sSelf.folderChildrenViewController?.listController?.resetMultipleSelectionView()
        }
    }
}
