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

typealias FolderChildrenDataSource = (folderDrillDownViewModel: FolderDrillViewModel,
                                      resultsViewModel: ResultsViewModel,
                                      contextualSearchViewModel: ContextualSearchViewModel)

class FolderChildrenViewModelFactory {
    var services: CoordinatorServices

    init(services: CoordinatorServices) {
        self.services = services
    }

    func folderChildrenDataSource(for listNode: ListNode) -> FolderChildrenDataSource {
        let eventBusService = services.eventBusService

        let folderDrillModel = FolderDrillModel(listNode: listNode,
                                                services: services)
        let folderDrillViewModel = FolderDrillViewModel(model: folderDrillModel)

        let resultViewModel = ResultsViewModel(with: services)
        let contextualSearchViewModel =
            ContextualSearchViewModel(accountService: services.accountService)
        let chipNode = SearchChipItem(name: LocalizationConstants.Search.searchIn + listNode.title,
                                      type: .node, selected: true,
                                      nodeID: listNode.guid)
        contextualSearchViewModel.delegate = resultViewModel
        contextualSearchViewModel.searchChipNode = chipNode
        resultViewModel.delegate = contextualSearchViewModel

        eventBusService?.register(observer: folderDrillModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: folderDrillModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: folderDrillModel,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: folderDrillModel,
                                  for: SyncStatusEvent.self,
                                  nodeTypes: [.file, .folder])

        eventBusService?.register(observer: resultViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: resultViewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: resultViewModel,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])

        return (folderDrillViewModel, resultViewModel, contextualSearchViewModel)
    }
}
