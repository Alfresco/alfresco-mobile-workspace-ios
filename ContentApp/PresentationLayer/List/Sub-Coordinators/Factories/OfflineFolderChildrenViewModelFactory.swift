//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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

typealias OfflineFolderChildrenDataSource = (offlineViewModel: OfflineFoldreDrillViewModel,
                                             resultsViewModel: ResultsViewModel,
                                             globalSearchViewModel: GlobalSearchViewModel)

class OfflineFolderChildrenViewModelFactory {
    var coordinatorServices: CoordinatorServices?

    func offlineDataSource(for listNode: ListNode) -> OfflineFolderChildrenDataSource {
        let accountService = coordinatorServices?.accountService
        let eventBusService = coordinatorServices?.eventBusService

        let offlineFoldreDrillViewModel = OfflineFoldreDrillViewModel(with: accountService,
                                                           listRequest: nil)
        offlineFoldreDrillViewModel.parentListNode = listNode
        let resultViewModel = ResultsViewModel()
        let globalSearchViewModel =
            GlobalSearchViewModel(accountService: accountService)
        globalSearchViewModel.delegate = resultViewModel
        globalSearchViewModel.displaySearchBar = false
        globalSearchViewModel.displaySearchButton = false
        resultViewModel.delegate = globalSearchViewModel

        eventBusService?.register(observer: resultViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: offlineFoldreDrillViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file])

        eventBusService?.register(observer: resultViewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: offlineFoldreDrillViewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])

        eventBusService?.register(observer: resultViewModel,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: offlineFoldreDrillViewModel,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])

        return (offlineFoldreDrillViewModel, resultViewModel, globalSearchViewModel)
    }
}