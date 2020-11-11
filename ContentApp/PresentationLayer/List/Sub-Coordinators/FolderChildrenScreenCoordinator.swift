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

class FolderChildrenScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var listViewController: ListViewController?
    private var listNode: ListNode
    private var folderDrillDownCoordinator: FolderChildrenScreenCoordinator?
    private var filePreviewCoordinator: FilePreviewScreenCoordinator?

    init(with presenter: UINavigationController, listNode: ListNode) {
        self.presenter = presenter
        self.listNode = listNode
    }

    func start() {
        let viewModelFactory = FolderChildrenViewModelFactory()
        viewModelFactory.coordinatorServices = coordinatorServices

        let folderChildrenDataSource = viewModelFactory.folderChildrenDataSource(for: listNode)

        let viewController = ListViewController()
        viewController.title = listNode.title
        viewController.coordinatorServices = coordinatorServices
        viewController.listItemActionDelegate = self
        viewController.listViewModel = folderChildrenDataSource.folderDrillDownViewModel
        viewController.searchViewModel = folderChildrenDataSource.contextualSearchViewModel
        viewController.resultViewModel = folderChildrenDataSource.resultsViewModel

        listViewController = viewController
        presenter.pushViewController(viewController, animated: true)
    }
}

extension FolderChildrenScreenCoordinator: ListItemActionDelegate {
    func showPreview(from node: ListNode) {
        switch node.kind {
        case .folder, .site:
            let folderDrillDownCoordinator = FolderChildrenScreenCoordinator(with: self.presenter,
                                                                             listNode: node)
            folderDrillDownCoordinator.start()
            self.folderDrillDownCoordinator = folderDrillDownCoordinator
        case .file:
            let filePreviewCoordinator = FilePreviewScreenCoordinator(with: self.presenter,
                                                                      listNode: node)
            filePreviewCoordinator.start()
            self.filePreviewCoordinator = filePreviewCoordinator
        }
    }

    func showActionSheetForListItem(for node: ListNode,
                                    delegate: NodeActionsViewModelDelegate) {
        let actionMenuViewModel = ActionMenuViewModel(with: accountService, listNode: node)
        let nodeActionsModel = NodeActionsViewModel(node: node,
                                                    delegate: delegate,
                                                    nodeActionServices: coordinatorServices)
        let coordinator = ActionMenuScreenCoordinator(with: self.presenter,
                                                      actionMenuViewModel: actionMenuViewModel,
                                                      nodeActionViewModel: nodeActionsModel)
        coordinator.start()
    }
}
