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

typealias FavoritesDataSource = (foldersAndFilesViewModel: FavoritesViewModel,
                                 librariesViewModel: FavoritesViewModel,
                                 globalSearchViewModel: GlobalSearchViewModel,
                                 resultsViewModel: ResultsViewModel)

class FavoritesViewModelFactory {
    var coordinatorServices: CoordinatorServices?

    func favoritesDataSource() -> FavoritesDataSource {

        let resultViewModel = ResultsViewModel(with: coordinatorServices)
        let foldersAndFilesViewModel = FavoritesViewModel.init(with: coordinatorServices,
                                                               listRequest: nil)
        let librariesViewModel = FavoritesViewModel.init(with: coordinatorServices,
                                                         listRequest: nil)
        let globalSearchViewModel =
            GlobalSearchViewModel(accountService: coordinatorServices?.accountService)

        foldersAndFilesViewModel.listCondition = APIConstants.QuerryConditions.whereFavoritesFileFolder
        librariesViewModel.listCondition = APIConstants.QuerryConditions.whereFavoritesSite
        globalSearchViewModel.delegate = resultViewModel
        resultViewModel.delegate = globalSearchViewModel

        registerForMoveEvent(resultViewModel: resultViewModel,
                             foldersAndFilesViewModel: foldersAndFilesViewModel,
                             librariesViewModel: librariesViewModel)

        registerForFavouriteEvent(resultViewModel: resultViewModel,
                                  foldersAndFilesViewModel: foldersAndFilesViewModel,
                                  librariesViewModel: librariesViewModel)

        registerForOfflineEvent(resultViewModel: resultViewModel,
                                foldersAndFilesViewModel: foldersAndFilesViewModel,
                                librariesViewModel: librariesViewModel)

        return (foldersAndFilesViewModel, librariesViewModel, globalSearchViewModel, resultViewModel)
    }

    private func registerForFavouriteEvent(resultViewModel: ResultsViewModel,
                                           foldersAndFilesViewModel: FavoritesViewModel,
                                           librariesViewModel: FavoritesViewModel) {
        let eventBusService = coordinatorServices?.eventBusService

        eventBusService?.register(observer: resultViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: foldersAndFilesViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: librariesViewModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.site])
    }

    private func registerForMoveEvent(resultViewModel: ResultsViewModel,
                                      foldersAndFilesViewModel: FavoritesViewModel,
                                      librariesViewModel: FavoritesViewModel) {
        let eventBusService = coordinatorServices?.eventBusService

        eventBusService?.register(observer: resultViewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: foldersAndFilesViewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: librariesViewModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.site])
    }

    private func registerForOfflineEvent(resultViewModel: ResultsViewModel,
                                         foldersAndFilesViewModel: FavoritesViewModel,
                                         librariesViewModel: FavoritesViewModel) {
        let eventBusService = coordinatorServices?.eventBusService

        eventBusService?.register(observer: resultViewModel,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: foldersAndFilesViewModel,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])
    }
}
