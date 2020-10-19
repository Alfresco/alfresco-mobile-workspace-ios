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
        let accountService = serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService
        let themingService =  serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        let viewController = ListViewController()

        let listViewModel = self.listViewModel(from: browseNode.type, with: accountService)
        let resultViewModel = ResultsViewModel()
        let globalSearchViewModel = searchViewModel(from: browseNode.type, with: browseNode.title, with: accountService, with: resultViewModel)

        viewController.title = browseNode.title
        viewController.themingService = themingService
        viewController.listItemActionDelegate = self
        viewController.listViewModel = listViewModel
        viewController.searchViewModel = globalSearchViewModel
        viewController.resultViewModel = resultViewModel
        listViewController = viewController
        presenter.pushViewController(viewController, animated: true)
    }

    private func listViewModel(from type: BrowseType?, with accountService: AccountService?) -> ListViewModelProtocol {
        switch type {
        case .personalFiles:
            return FolderDrillViewModel(with: accountService, listRequest: nil)
        case .myLibraries:
            return MyLibrariesViewModel(with: accountService, listRequest: nil)
        case .shared:
            return SharedViewModel(with: accountService, listRequest: nil)
        case .trash:
            return TrashViewModel(with: accountService, listRequest: nil)
        default: return FolderDrillViewModel(with: accountService, listRequest: nil)
        }
    }

    private func searchViewModel(from type: BrowseType?, with title: String?, with accountService: AccountService?, with resultViewModel: ResultsViewModel) -> SearchViewModelProtocol {
        var searchChip: SearchChipItem?
        switch type {
        case .personalFiles:
            if let nodeID = UserProfile.getPersonalFilesID() {
                searchChip = SearchChipItem(name: LocalizationConstants.Search.searchIn + (title ?? ""), type: .node, selected: true, nodeID: nodeID)
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
            let folderDrillDownCoordinator = FolderChildrenScreenCoordinator(with: self.presenter, listNode: node)
            folderDrillDownCoordinator.start()
            self.folderDrillDownCoordinator = folderDrillDownCoordinator
        case .file:
            let filePreviewCoordinator = FilePreviewScreenCoordinator(with: self.presenter, listNode: node)
            filePreviewCoordinator.start()
            self.filePreviewCoordinator = filePreviewCoordinator
        }
    }
    
    func showActionSheetForListItem(node: ListNode,
                                    listComponent: ListComponentViewController) {
        let menu = ActionsMenuGenericMoreButton(with: node)
        let accountService = serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService
        let actionMenuViewModel = ActionMenuViewModel(with: menu,
                                                      node: node,
                                                      accountService: accountService,
                                                      delegate: listComponent)
        let actionMenuCoordinator = ActionMenuScreenCoordinator(with: self.presenter,
                                                                model: actionMenuViewModel)
        actionMenuCoordinator.start()
    }
}
