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

import Foundation

typealias TopLevelBrowseDataSource = (topLevelBrowseViewModel: ListComponentViewModel,
                                     globalSearchViewModel: SearchViewModel)

class TopLevelBrowseViewModelFactory {
    let services: CoordinatorServices

    init(services: CoordinatorServices) {
        self.services = services
    }

    func topLevelBrowseDataSource(browseNode: BrowseNode) -> TopLevelBrowseDataSource {
        let topLevelBrowseViewModel = listViewModel(from: browseNode.type)
        let globalSearchViewModel = self.globalSearchViewModel(from: browseNode.type,
                                                               with: browseNode.title)
        return (topLevelBrowseViewModel, globalSearchViewModel)
    }

    func listViewModel(from type: BrowseType?) -> ListComponentViewModel {
        switch type {
        case .personalFiles:
            return personalFilesViewModel()
        case .myLibraries:
            return myLibrariesViewModel()
        case .shared:
            return sharedViewModel()
        case .trash:
            return trashViewModel()
        default:
            return defaultViewModel()
        }
    }

    func globalSearchViewModel(from type: BrowseType?,
                               with title: String?) -> SearchViewModel {
        var searchChip: SearchChipItem?

        switch type {
        case .personalFiles:
            if let nodeID = UserProfile.personalFilesID {
                searchChip = SearchChipItem(name: LocalizationConstants.Search.searchIn + (title ?? ""),
                                            type: .node,
                                            selected: true,
                                            nodeID: nodeID)
            } else {
                ProfileService.featchPersonalFilesID()
            }
        default:
            let searchModel = GlobalSearchModel(with: services)
            let globalSearchViewModel = GlobalSearchViewModel(model: searchModel)
        
            return globalSearchViewModel
        }

        let searchModel = ContextualSearchModel(with: services)
        searchModel.searchChipNode = searchChip
        let contextualSearchViewModel = ContextualSearchViewModel(model: searchModel)

        return contextualSearchViewModel
    }

    // MARK: - Private builders

    private func personalFilesViewModel() -> ListComponentViewModel {
        let model = FolderDrillModel(listNode: nil,
                                     services: services)
        let viewModel = FolderDrillViewModel(model: model)
        return viewModel
    }

    private func myLibrariesViewModel() -> ListComponentViewModel {

        let model = MyLibrariesModel(services: services)
        let viewModel = ListComponentViewModel(model: model)
        return viewModel
    }

    private func sharedViewModel() -> ListComponentViewModel {
        let model = SharedModel(services: services)
        let viewModel = ListComponentViewModel(model: model)
        return viewModel
    }

    private func trashViewModel() -> ListComponentViewModel {
        let model = TrashModel(services: services)
        let viewModel = TrashViewModel(model: model)
        return viewModel
    }

    private func defaultViewModel() -> ListComponentViewModel {
        let model = FolderDrillModel(listNode: nil,
                                     services: services)
        let viewModel = FolderDrillViewModel(model: model)
        return viewModel
    }
}
