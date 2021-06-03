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
import AlfrescoContent

enum ListEntrySyncStatus: String {
    case markedForOffline = "ic-sync-status-marked"
    case error = "ic-sync-status-error"
    case pending = "ic-sync-status-pending"
    case inProgress = "ic-sync-status-in-progress"
    case downloaded = "ic-sync-status-synced"
    case uploaded = "ic-sync-status-uploaded"
    case undefined = "ic-sync-status-undefined"
}

#warning("Rename to ListComponentModelDelegate after refactor")
protocol ListModelDelegate: AnyObject {
    func needsDataSourceReload()
    func needsDisplayStateRefresh()
}

#warning("Rename to ListComponentModelProtocol after refactor")
protocol ListModelProtocol: AnyObject {
    var delegate: ListModelDelegate? { get set }
    var rawListNodes: [ListNode] { get set}

    func isEmpty() -> Bool
    func clear()
    func numberOfItems(in section: Int) -> Int

    func listNodes() -> [ListNode]
    func listNode(for indexPath: IndexPath) -> ListNode
    func titleForSectionHeader(at indexPath: IndexPath) -> String
    func syncStatusForNode(at indexPath: IndexPath) -> ListEntrySyncStatus

    func fetchItems(with requestPagination: RequestPagination,
                    completionHandler: @escaping PagedResponseCompletionHandler)
}

#warning("Rename to ListComponentModelProtocol after refactor")
extension ListModelProtocol {
    func clear() {
        rawListNodes = []
    }

    func syncStatusForNode(at indexPath: IndexPath) -> ListEntrySyncStatus {
        return listNode(for: indexPath).isMarkedOffline() ? .markedForOffline : .undefined
    }
}
