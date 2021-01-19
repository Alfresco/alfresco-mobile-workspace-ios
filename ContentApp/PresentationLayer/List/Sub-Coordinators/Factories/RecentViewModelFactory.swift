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

typealias RecentDataSource = (recentViewModel: RecentViewModel,
                              resultsViewModel: ResultsViewModel,
                              globalSearchViewModel: GlobalSearchViewModel)

class RecentViewModelFactory {
    var coordinatorServices: CoordinatorServices?

    func recentDataSource() -> RecentDataSource {
        let eventBusService = coordinatorServices?.eventBusService

        let recentViewModel = RecentViewModel(with: coordinatorServices,
                                            listRequest: nil)
        let resultViewModel = ResultsViewModel(with: coordinatorServices)
        let globalSearchViewModel =
            GlobalSearchViewModel(accountService: coordinatorServices?.accountService)
        globalSearchViewModel.delegate = resultViewModel
        resultViewModel.delegate = globalSearchViewModel

        eventBusService?.register(observer: resultViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: recentViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file])

        eventBusService?.register(observer: resultViewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: recentViewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])

        eventBusService?.register(observer: resultViewModel,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: recentViewModel,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])

        return (recentViewModel, resultViewModel, globalSearchViewModel)
    }
}
