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
                                 globalSearchViewModel: GlobalSearchViewModel)

class FavoritesViewModelFactory {
    var services: CoordinatorServices

    init(services: CoordinatorServices) {
        self.services = services
    }

    func favoritesDataSource() -> FavoritesDataSource {
        let foldersAndFilesModel = FavoritesModel(services: services,
                                                  listCondition: APIConstants.QuerryConditions.whereFavoritesFileFolder)
        let librariesModel = FavoritesModel(services: services,
                                            listCondition: APIConstants.QuerryConditions.whereFavoritesSite)
        let foldersAndFilesViewModel = FavoritesViewModel(model: foldersAndFilesModel)
        let librariesViewModel = FavoritesViewModel(model: librariesModel)
        
        let searchModel = GlobalSearchModel(with: services)
        let globalSearchViewModel = GlobalSearchViewModel(model: searchModel)

        registerForMoveEvent(foldersAndFilesModel: foldersAndFilesModel,
                             librariesModel: librariesModel,
                             globalSearchModel: searchModel)

        registerForFavouriteEvent(foldersAndFilesModel: foldersAndFilesModel,
                                  librariesModel: librariesModel,
                                  globalSearchModel: searchModel)

        registerForOfflineEvent(foldersAndFilesModel: foldersAndFilesModel,
                                librariesModel: librariesModel,
                                globalSearchModel: searchModel)

        return (foldersAndFilesViewModel, librariesViewModel, globalSearchViewModel)
    }

    private func registerForFavouriteEvent(foldersAndFilesModel: FavoritesModel,
                                           librariesModel: FavoritesModel,
                                           globalSearchModel: GlobalSearchModel) {
        let eventBusService = services.eventBusService

        eventBusService?.register(observer: foldersAndFilesModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: librariesModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.site])
        eventBusService?.register(observer: globalSearchModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder, .site])
    }

    private func registerForMoveEvent(foldersAndFilesModel: FavoritesModel,
                                      librariesModel: FavoritesModel,
                                      globalSearchModel: GlobalSearchModel) {
        let eventBusService = services.eventBusService

        eventBusService?.register(observer: foldersAndFilesModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: librariesModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.site])
        eventBusService?.register(observer: globalSearchModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
    }

    private func registerForOfflineEvent(foldersAndFilesModel: FavoritesModel,
                                         librariesModel: FavoritesModel,
                                         globalSearchModel: GlobalSearchModel) {
        let eventBusService = services.eventBusService

        eventBusService?.register(observer: foldersAndFilesModel,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: globalSearchModel,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])
    }
}
