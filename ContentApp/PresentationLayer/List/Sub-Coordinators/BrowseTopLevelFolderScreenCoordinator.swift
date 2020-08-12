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

    init(with presenter: UINavigationController, browseNode: BrowseNode) {
        self.presenter = presenter
        self.browseNode = browseNode
    }

    func start() {
        let router = self.serviceRepository.service(of: Router.serviceIdentifier) as? Router
        let routerPath = NavigationRoutes.browseScreen.path + "/<nodeTitle>" + "/<nodeID>"
        router?.register(route: routerPath, factory: { [weak self] (_, parameters) -> UIViewController? in
            guard let sSelf = self else { return nil }

            let browseType = BrowseType(rawValue: parameters["nodeID"] as? String ?? "PersonalFiles")
            let title = parameters["nodeTitle"] as? String ?? ""
            let accountService = sSelf.serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService
            let themingService =  sSelf.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
            let viewController = ListViewController()

            let listViewModel = sSelf.listViewModel(from: browseType, with: accountService)
            let resultViewModel = ResultsViewModel()
            let globalSearchViewModel = sSelf.searchViewModel(from: browseType, with: title, with: accountService, with: resultViewModel)

            viewController.title = title
            viewController.themingService = themingService
            viewController.folderDrillDownScreenCoordinatorDelegate = self
            viewController.listViewModel = listViewModel
            viewController.searchViewModel = globalSearchViewModel
            viewController.resultViewModel = resultViewModel
            sSelf.listViewController = viewController

            return viewController
        })
        let routerPathValues = NavigationRoutes.browseScreen.path + "/\(browseNode.title)" + "/\(browseNode.type.rawValue)"
        router?.push(route: routerPathValues, from: presenter)
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

extension BrowseTopLevelFolderScreenCoordinator: FolderDrilDownScreenCoordinatorDelegate {
    func showFolderScreen(from node: ListNode) {
        let folderDrillDownCoordinatorDelegate = FolderChildrenScreenCoordinator(with: self.presenter, listNode: node)
        folderDrillDownCoordinatorDelegate.start()
        self.folderDrillDownCoordinator = folderDrillDownCoordinatorDelegate
    }
}
