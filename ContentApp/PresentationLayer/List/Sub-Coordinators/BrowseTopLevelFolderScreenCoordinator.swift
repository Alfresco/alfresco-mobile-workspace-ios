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

class BrowseTopLevelFolderScreenCoordinator: PresentingCoordinator {
    private let presenter: UINavigationController
    private var browseNode: BrowseNode
    private var actionMenuCoordinator: ActionMenuScreenCoordinator?
    private var createNodeSheetCoordinator: CreateNodeSheetCoordinator?
    private var cameraCoordinator: CameraScreenCoordinator?
    private var photoLibraryCoordinator: PhotoLibraryScreenCoordinator?
    
    init(with presenter: UINavigationController, browseNode: BrowseNode) {
        self.presenter = presenter
        self.browseNode = browseNode
    }
    
    override func start() {
        #warning("Uncomment")
//        let viewModelFactory = TopLevelBrowseViewModelFactory(services: coordinatorServices)
//        let topLevelBrowseDataSource = viewModelFactory.topLevelBrowseDataSource(browseNode: browseNode)
//
//        let viewModel = topLevelBrowseDataSource.topLevelBrowseViewModel
//        let pageController = ListPageController(dataSource: viewModel.model,
//                                                services: coordinatorServices)
//
//        let viewController = ListViewController()
//        viewController.title = browseNode.title
//
//        viewController.pageController = pageController
//        viewController.viewModel = viewModel
//        viewController.searchViewModel = topLevelBrowseDataSource.globalSearchViewModel
//        viewController.resultViewModel = topLevelBrowseDataSource.resultsViewModel
//
//        viewController.coordinatorServices = coordinatorServices
//        viewController.listItemActionDelegate = self
//
//        presenter.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Private interface
    
    func personalFilesNode () -> ListNode {
        return ListNode(guid: APIConstants.my,
                        title: "Personal files",
                        path: "",
                        nodeType: .folder)
    }
}

extension BrowseTopLevelFolderScreenCoordinator: ListItemActionDelegate {
    func showPreview(for node: ListNode,
                     from dataSource: ListModelProtocol) {
        if node.isAFolderType() || node.nodeType == .site {
            startFolderCoordinator(for: node,
                                   presenter: self.presenter)
        } else if node.isAFileType() {
            startFileCoordinator(for: node,
                                 presenter: self.presenter)
        } else {
            AlfrescoLog.error("Unable to show preview for unknown node type")
        }
    }
    
    func showActionSheetForListItem(for node: ListNode,
                                    from dataSource: ListModelProtocol,
                                    delegate: NodeActionsViewModelDelegate) {
        let actionMenuViewModel = ActionMenuViewModel(node: node,
                                                      coordinatorServices: coordinatorServices)
        let nodeActionsModel = NodeActionsViewModel(node: node,
                                                    delegate: delegate,
                                                    coordinatorServices: coordinatorServices)
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
        let coordinator = ActionMenuScreenCoordinator(with: presenter,
                                                      actionMenuViewModel: actionMenuViewModel,
                                                      nodeActionViewModel: nodeActionsModel)
        coordinator.start()
        actionMenuCoordinator = coordinator
    }
    
    func showNodeCreationDialog(with actionMenu: ActionMenu,
                                delegate: CreateNodeViewModelDelegate?) {
        let coordinator = CreateNodeSheetCoordinator(with: presenter,
                                                     actionMenu: actionMenu,
                                                     parentListNode: personalFilesNode(),
                                                     createNodeViewModelDelegate: delegate)
        coordinator.start()
        createNodeSheetCoordinator = coordinator
    }
    
    func showCamera() {
        let coordinator = CameraScreenCoordinator(with: presenter,
                                                  parentListNode: personalFilesNode())
        coordinator.start()
        cameraCoordinator = coordinator
    }
    
    func showPhotoLibrary() {
        let coordinator = PhotoLibraryScreenCoordinator(with: presenter,
                                                        parentListNode: personalFilesNode())
        coordinator.start()
        photoLibraryCoordinator = coordinator
    }
    
}
