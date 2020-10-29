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

protocol ListItemActionDelegate: class {
    func showPreview(from node: ListNode)
    func showActionSheetForListItem(node: ListNode, delegate: NodeActionsViewModelDelegate)
}

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
        let accountService = repository.service(of: AccountService.identifier) as? AccountService
        let themingService = repository.service(of: MaterialDesignThemingService.identifier) as? MaterialDesignThemingService
        let eventBusService = repository.service(of: EventBusService.identifier) as? EventBusService
        let viewController = ListViewController()

        let listViewModel = self.listViewModel(with: listNode.guid,
                                               and: listNode.kind.rawValue,
                                               and: accountService,
                                               and: eventBusService)
        let resultViewModel = ResultsViewModel()
        let contextualSearchViewModel = ContextualSearchViewModel(accountService: accountService)
        let chipNode = SearchChipItem(name: LocalizationConstants.Search.searchIn + listNode.title,
                                      type: .node, selected: true,
                                      nodeID: listNode.guid)
        contextualSearchViewModel.delegate = resultViewModel
        contextualSearchViewModel.searchChipNode = chipNode
        resultViewModel.delegate = contextualSearchViewModel

        viewController.title = listNode.title
        viewController.themingService = themingService
        viewController.eventBusService = eventBusService
        viewController.listItemActionDelegate = self
        viewController.listViewModel = listViewModel
        viewController.searchViewModel = contextualSearchViewModel
        viewController.resultViewModel = resultViewModel

        eventBusService?.register(observer: resultViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder, .site])

        listViewController = viewController
        presenter.pushViewController(viewController, animated: true)
    }

    private func listViewModel(with nodeID: String?,
                               and nodeKind: String?,
                               and accountService: AccountService?,
                               and eventBusService: EventBusService?) -> ListViewModelProtocol {
        let listViewModel = FolderDrillViewModel(with: accountService,
                                                 listRequest: nil)
        eventBusService?.register(observer: listViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder])
        if let nodeID = nodeID, let nodeKind = nodeKind {
            listViewModel.listNodeGuid = nodeID
            listViewModel.listNodeIsFolder = (nodeKind == ElementKindType.folder.rawValue)
        }
        return listViewModel
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

    func showActionSheetForListItem(node: ListNode, delegate: NodeActionsViewModelDelegate) {
        let menu = ActionsMenuGenericMoreButton(with: node)
        let accountService = repository.service(of: AccountService.identifier) as? AccountService
        let eventBusService = repository.service(of: EventBusService.identifier) as? EventBusService
        let actionMenuViewModel = ActionMenuViewModel(with: menu)
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
