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

class OfflineFolderChildrenViewModelFactory {
    var services: CoordinatorServices

    init(services: CoordinatorServices) {
        self.services = services
    }

    func offlineDataSource(for listNode: ListNode) -> OfflineFolderDrillViewModel {
        let eventBusService = services.eventBusService

        let offlineFolderDrillModel = OfflineFolderDrillModel(services: services,
                                                              parentListNode: listNode)
        let offlineFolderDrillViewModel = OfflineFolderDrillViewModel(model: offlineFolderDrillModel)

        eventBusService?.register(observer: offlineFolderDrillModel,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: offlineFolderDrillModel,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: offlineFolderDrillModel,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: offlineFolderDrillModel,
                                  for: SyncStatusEvent.self,
                                  nodeTypes: [.file, .folder])
        
        return offlineFolderDrillViewModel
    }
}
