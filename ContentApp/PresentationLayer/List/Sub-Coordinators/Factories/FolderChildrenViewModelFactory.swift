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
    var coordinatorServices: CoordinatorServices?

    func folderChildrenDataSource(for listNode: ListNode) -> FolderChildrenDataSource {
        let accountService = coordinatorServices?.accountService
        let eventBusService = coordinatorServices?.eventBusService

        let folderDrillViewModel = FolderDrillViewModel(with: accountService,
                                                        listRequest: nil)
        folderDrillViewModel.listNodeGuid = listNode.guid
        folderDrillViewModel.listNodeIsFolder = (listNode.kind.rawValue == ElementKindType.folder.rawValue)

        let resultViewModel = ResultsViewModel()
        let contextualSearchViewModel = ContextualSearchViewModel(accountService: accountService)
        let chipNode = SearchChipItem(name: LocalizationConstants.Search.searchIn + listNode.title,
                                      type: .node, selected: true,
                                      nodeID: listNode.guid)
        contextualSearchViewModel.delegate = resultViewModel
        contextualSearchViewModel.searchChipNode = chipNode
        resultViewModel.delegate = contextualSearchViewModel

        eventBusService?.register(observer: folderDrillViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: folderDrillViewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])

        eventBusService?.register(observer: resultViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: resultViewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])

        return (folderDrillViewModel, resultViewModel, contextualSearchViewModel)
    }
}
