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
                              globalSearchViewModel: GlobalSearchViewModel)

class RecentViewModelFactory {
    var services: CoordinatorServices

    init(services: CoordinatorServices) {
        self.services = services
    }

    func recentDataSource() -> RecentDataSource {
        let eventBusService = services.eventBusService

        let recentModel = RecentModel(services: services)
        let recentViewModel = RecentViewModel(model: recentModel)

        let searchModel = GlobalSearchModel(with: services)
        let globalSearchViewModel = GlobalSearchViewModel(model: searchModel)

        eventBusService?.register(observer: recentModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file])
        eventBusService?.register(observer: recentModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: recentModel,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])

        eventBusService?.register(observer: searchModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: searchModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: searchModel,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])

        return (recentViewModel, globalSearchViewModel)
    }
}
