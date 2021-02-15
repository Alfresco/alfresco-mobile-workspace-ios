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

class BrowseTopLevelFolderScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var browseNode: BrowseNode
    private var folderDrillDownCoordinator: FolderChildrenScreenCoordinator?
    private var filePreviewCoordinator: FilePreviewScreenCoordinator?
    private var actionMenuCoordinator: ActionMenuScreenCoordinator?
    private var createNodeSheetCoordinator: CreateNodeSheetCoordinator?

    init(with presenter: UINavigationController, browseNode: BrowseNode) {
        self.presenter = presenter
        self.browseNode = browseNode
    }

    func start() {
        let viewModelFactory = TopLevelBrowseViewModelFactory()
        viewModelFactory.coordinatorServices = coordinatorServices

        let topLevelBrowseDataSource = viewModelFactory.topLevelBrowseDataSource(browseNode: browseNode)

        let viewController = ListViewController()
        viewController.title = browseNode.title
        viewController.coordinatorServices = coordinatorServices
        viewController.listItemActionDelegate = self
        viewController.listViewModel = topLevelBrowseDataSource.topLevelBrowseViewModel
        viewController.searchViewModel = topLevelBrowseDataSource.globalSearchViewModel
        viewController.resultViewModel = topLevelBrowseDataSource.resultsViewModel

        presenter.pushViewController(viewController, animated: true)
    }
}

extension BrowseTopLevelFolderScreenCoordinator: ListItemActionDelegate {
    func showPreview(for node: ListNode,
                     from dataSource: ListComponentDataSourceProtocol) {
        switch node.nodeType {
        case .folder, .folderLink, .site:
            let folderDrillDownCoordinator =
                FolderChildrenScreenCoordinator(with: self.presenter,
                                                listNode: node)
            folderDrillDownCoordinator.start()
            self.folderDrillDownCoordinator = folderDrillDownCoordinator
        case .file, .fileLink:
            let filePreviewCoordinator =
                FilePreviewScreenCoordinator(with: self.presenter,
                                             listNode: node)
            filePreviewCoordinator.start()
            self.filePreviewCoordinator = filePreviewCoordinator
        default:
            AlfrescoLog.error("Unable to show preview for unknown node type")
        }
    }

    func showActionSheetForListItem(for node: ListNode,
                                    from dataSource: ListComponentDataSourceProtocol,
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
        let personalFilesNode = ListNode(guid: APIConstants.my,
                                         title: "Personal files",
                                         path: "",
                                         nodeType: .folder)
        let coordinator = CreateNodeSheetCoordinator(with: presenter,
                                                     actionMenu: actionMenu,
                                                     parentListNode: personalFilesNode,
                                                     createNodeViewModelDelegate: delegate)
        coordinator.start()
        createNodeSheetCoordinator = coordinator
    }
}
