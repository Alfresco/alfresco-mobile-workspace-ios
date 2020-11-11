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
    var nodeServices: NodeServices?

    func recentDataSource() -> RecentDataSource {
        let accountService = nodeServices?.accountService
        let eventBusService = nodeServices?.eventBusService

        let recentViewModel = RecentViewModel(with: accountService,
                                            listRequest: nil)
        let resultViewModel = ResultsViewModel()
        let globalSearchViewModel =
            GlobalSearchViewModel(accountService: accountService)
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

        return (recentViewModel, resultViewModel, globalSearchViewModel)
    }
}
