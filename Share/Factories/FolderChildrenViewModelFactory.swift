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
                                      contextualSearchViewModel: SearchViewModel)

class FolderChildrenViewModelFactory {
    var services: CoordinatorServices
    var model: FolderDrillModel?

    init(services: CoordinatorServices) {
        self.services = services
    }

    func folderChildrenDataSource(for listNode: ListNode) -> FolderChildrenDataSource {
        let folderDrillModel = FolderDrillModel(listNode: listNode,
                                                services: services)
        self.model = folderDrillModel
        let folderDrillViewModel = FolderDrillViewModel(model: folderDrillModel)

        let searchChip = SearchChipItem(name: LocalizationConstants.Search.searchIn + listNode.title,
                                      type: .node, selected: true,
                                      nodeID: listNode.guid)
        let searchModel = ContextualSearchModel(with: services)
        searchModel.searchChipNode = searchChip

        let contextualSearchViewModel =
            ContextualSearchViewModel(model: searchModel)

        return (folderDrillViewModel, contextualSearchViewModel)
    }
}
