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
        let accountService = repository.service(of: AccountService.identifier) as? AccountService
        let themingService =  repository.service(of: MaterialDesignThemingService.identifier) as? MaterialDesignThemingService
        let eventBusService = repository.service(of: EventBusService.identifier) as? EventBusService
        let viewController = ListViewController()

        let listViewModel = self.listViewModel(from: browseNode.type,
                                               with: accountService,
                                               eventBusService: eventBusService)
        let resultViewModel = ResultsViewModel()
        let globalSearchViewModel = searchViewModel(from: browseNode.type,
                                                    with: browseNode.title,
                                                    with: accountService,
                                                    with: resultViewModel)

        viewController.title = browseNode.title
        viewController.themingService = themingService
        viewController.eventBusService = eventBusService
        viewController.listItemActionDelegate = self
        viewController.listViewModel = listViewModel
        viewController.searchViewModel = globalSearchViewModel
        viewController.resultViewModel = resultViewModel

        eventBusService?.register(observer: resultViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder, .site])

        listViewController = viewController
        presenter.pushViewController(viewController, animated: true)
    }

    private func listViewModel(from type: BrowseType?,
                               with accountService: AccountService?,
                               eventBusService: EventBusService?) -> ListViewModelProtocol {
        switch type {
        case .personalFiles:
            let viewModel = FolderDrillViewModel(with: accountService,
                                                 listRequest: nil)
            eventBusService?.register(observer: viewModel,
                                      for: FavouriteEvent.self,
                                      nodeTypes: [.file, .folder])
            return viewModel
        case .myLibraries:
            let viewModel = MyLibrariesViewModel(with: accountService,
                                                 listRequest: nil)
            return viewModel
        case .shared:
            let viewModel = SharedViewModel(with: accountService,
                                            listRequest: nil)
            eventBusService?.register(observer: viewModel,
                                      for: FavouriteEvent.self,
                                      nodeTypes: [.file])
            return viewModel

        case .trash:
            return TrashViewModel(with: accountService,
                                  listRequest: nil)
        default:
            let viewModel = FolderDrillViewModel(with: accountService,
                                                 listRequest: nil)
            eventBusService?.register(observer: viewModel,
                                      for: FavouriteEvent.self,
                                      nodeTypes: [.file, .folder])
            return viewModel
        }
    }

    private func searchViewModel(from type: BrowseType?,
                                 with title: String?,
                                 with accountService: AccountService?,
                                 with resultViewModel: ResultsViewModel) -> SearchViewModelProtocol {
        var searchChip: SearchChipItem?
        switch type {
        case .personalFiles:
            if let nodeID = UserProfile.getPersonalFilesID() {
                searchChip = SearchChipItem(name: LocalizationConstants.Search.searchIn + (title ?? ""),
                                            type: .node,
                                            selected: true,
                                            nodeID: nodeID)
            } else {
                ProfileService.featchPersonalFilesID()
            }
        default:
            let globalSearchViewModel = GlobalSearchViewModel(accountService: accountService)
            resultViewModel.delegate = globalSearchViewModel
            globalSearchViewModel.delegate = resultViewModel
            globalSearchViewModel.displaySearchBar = false
            globalSearchViewModel.displaySearchButton = false
            return globalSearchViewModel
        }

        let contextualSearchViewModel = ContextualSearchViewModel(accountService: accountService)

        contextualSearchViewModel.searchChipNode = searchChip
        resultViewModel.delegate = contextualSearchViewModel
        contextualSearchViewModel.delegate = resultViewModel
        return contextualSearchViewModel
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
                                             guidListNode: node.guid)
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
