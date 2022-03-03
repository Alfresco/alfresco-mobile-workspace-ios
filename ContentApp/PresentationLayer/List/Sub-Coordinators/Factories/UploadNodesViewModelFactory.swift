//
// Copyright (C) 2005-2022 Alfresco Software Limited.
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

import UIKit

typealias UploadNodesDataSource = (ListComponentViewModel)

class UploadNodesViewModelFactory: NSObject {
    let services: CoordinatorServices

    init(services: CoordinatorServices) {
        self.services = services
    }
   
    // MARK: - Private builders

    private func uploadedFilesViewModel() -> ListComponentViewModel {
        let eventBusService = services.eventBusService

        let model = FolderDrillModel(listNode: nil,
                                     services: services)
        let viewModel = FolderDrillViewModel(model: model)

        eventBusService?.register(observer: model,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: model,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: model,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: model,
                                  for: SyncStatusEvent.self,
                                  nodeTypes: [.file, .folder])
        return viewModel
    }

    private func defaultViewModel() -> ListComponentViewModel {
        let eventBusService = services.eventBusService

        let model = FolderDrillModel(listNode: nil,
                                     services: services)
        let viewModel = FolderDrillViewModel(model: model)

        eventBusService?.register(observer: model,
                                  for: FavouriteEvent.self,
                                  nodeTypes: [.file, .folder])
        eventBusService?.register(observer: model,
                                  for: MoveEvent.self,
                                  nodeTypes: [.file, .folder, .site])
        eventBusService?.register(observer: model,
                                  for: OfflineEvent.self,
                                  nodeTypes: [.file, .folder])
        return viewModel
    }
}
