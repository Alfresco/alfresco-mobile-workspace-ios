//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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

class OfflineFolderChildrenScreenCoordinator: Coordinator {

    private let presenter: UINavigationController
    private var listNode: ListNode
    private var offlineFolderChildrenScreenCoordinator: OfflineFolderChildrenScreenCoordinator?
    private var actionMenuCoordinator: ActionMenuScreenCoordinator?
    private var filePreviewCoordinator: FilePreviewScreenCoordinator?

    init(with presenter: UINavigationController, listNode: ListNode) {
        self.presenter = presenter
        self.listNode = listNode
    }

    func start() {
        let offlineViewModelFactory = OfflineFolderChildrenViewModelFactory()
        offlineViewModelFactory.coordinatorServices = coordinatorServices

        let offlineDataSource = offlineViewModelFactory.offlineDataSource(for: listNode)

        let viewController = ListViewController()
        viewController.isPaginationEnabled = false
        viewController.title = listNode.title
        viewController.coordinatorServices = coordinatorServices
        viewController.listViewModel = offlineDataSource.offlineViewModel
        viewController.listItemActionDelegate = self
        viewController.searchViewModel = offlineDataSource.globalSearchViewModel
        viewController.resultViewModel = offlineDataSource.resultsViewModel

        presenter.pushViewController(viewController, animated: true)
    }
}

extension OfflineFolderChildrenScreenCoordinator: ListItemActionDelegate {
    func showPreview(from node: ListNode) {
        switch node.nodeType {
        case .folder:
            let coordinator = OfflineFolderChildrenScreenCoordinator(with: presenter,
                                                                     listNode: node)
            coordinator.start()
            self.offlineFolderChildrenScreenCoordinator = coordinator
        case .file, .fileLink:
            let coordinator = FilePreviewScreenCoordinator(with: presenter,
                                                           listNode: node,
                                                           excludedActions: [.markOffline])
            coordinator.start()
            self.filePreviewCoordinator = coordinator

        default:
            AlfrescoLog.error("Unable to show preview for unknown node type")
        }
    }

    func showActionSheetForListItem(for node: ListNode, delegate: NodeActionsViewModelDelegate) {
        let actionMenuViewModel = ActionMenuViewModel(node: node,
                                                      coordinatorServices: coordinatorServices,
                                                      excludedActionTypes: [.markOffline])
        let nodeActionsModel = NodeActionsViewModel(node: node,
                                                    delegate: delegate,
                                                    coordinatorServices: coordinatorServices)
        let coordinator = ActionMenuScreenCoordinator(with: presenter,
                                                      actionMenuViewModel: actionMenuViewModel,
                                                      nodeActionViewModel: nodeActionsModel)
        coordinator.start()
        actionMenuCoordinator = coordinator
    }

    func showNodeCreationSheet(delegate: NodeActionsViewModelDelegate) {
        // Do nothing
    }

    func showNodeCreationDialog(with actionMenu: ActionMenu,
                                delegate: CreateNodeViewModelDelegate?) {
        // Do nothing
    }
}
