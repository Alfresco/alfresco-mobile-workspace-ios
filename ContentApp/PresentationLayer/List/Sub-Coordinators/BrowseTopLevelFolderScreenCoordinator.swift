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
    private var listViewController: ListViewController?
    private var browseNode: BrowseNode
    private var folderDrillDownCoordinator: FolderChildrenScreenCoordinator?
    private var filePreviewCoordinator: FilePreviewScreenCoordinator?

    init(with presenter: UINavigationController, browseNode: BrowseNode) {
        self.presenter = presenter
        self.browseNode = browseNode
    }

    func start() {
        let viewModelFactory = TopLevelBrowseViewModelFactory()
        viewModelFactory.accountService = accountService
        viewModelFactory.eventBusService = eventBusService

        let topLevelBrowseDataSource = viewModelFactory.topLevelBrowseDataSource(browseNode: browseNode)

        let viewController = ListViewController()
        viewController.title = browseNode.title
        viewController.themingService = themingService
        viewController.listItemActionDelegate = self
        viewController.listViewModel = topLevelBrowseDataSource.topLevelBrowseViewModel
        viewController.searchViewModel = topLevelBrowseDataSource.globalSearchViewModel
        viewController.resultViewModel = topLevelBrowseDataSource.resultsViewModel

        listViewController = viewController
        presenter.pushViewController(viewController, animated: true)
    }
}

extension BrowseTopLevelFolderScreenCoordinator: ListItemActionDelegate {
    func showPreview(from node: ListNode) {
        switch node.kind {
        case .folder, .site:
            let folderDrillDownCoordinator =
                FolderChildrenScreenCoordinator(with: self.presenter,
                                                listNode: node)
            folderDrillDownCoordinator.start()
            self.folderDrillDownCoordinator = folderDrillDownCoordinator
        case .file:
            let filePreviewCoordinator =
                FilePreviewScreenCoordinator(with: self.presenter,
                                             listNode: node)
            filePreviewCoordinator.start()
            self.filePreviewCoordinator = filePreviewCoordinator
        }
    }

    func showActionSheetForListItem(for node: ListNode,
                                    delegate: NodeActionsViewModelDelegate) {
        let actionMenuViewModel = ActionMenuViewModel(with: accountService,
                                                      listNode: node)
        let nodeActionsModel = NodeActionsViewModel(node: node,
                                                    accountService: accountService,
                                                    eventBusService: eventBusService,
                                                    delegate: delegate)
        let coordinator = ActionMenuScreenCoordinator(with: self.presenter,
                                                      actionMenuViewModel: actionMenuViewModel,
                                                      nodeActionViewModel: nodeActionsModel)
        coordinator.start()
    }
}
