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
    private var listNode: ListNode
    private var model: FolderDrillModel?

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
                                   presenter: self.presenter)
        } else {
            AlfrescoLog.error("Unable to show preview for unknown node type")
        }
    }
}

extension FolderChildrenScreenCoordinator: FolderChildrenScreenCoordinatorDelegate {
    func updateListNode(with node: ListNode) {
        self.listNode = node
    }
}
