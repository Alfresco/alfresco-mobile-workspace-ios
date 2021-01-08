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

class OfflineViewModel: PageFetchingViewModel, ListViewModelProtocol {
    var supportedNodeTypes: [NodeType]?

    required init(with accountService: AccountService?, listRequest: SearchRequest?) {
        super.init()
        refreshList()
    }

    func shouldDisplaySettingsButton() -> Bool {
        return true
    }

    // MARK: - ListViewModelProtocol

    func shouldDisplayNodePath() -> Bool {
        return true
    }

    func shouldDisplayMoreButton() -> Bool {
        return true
    }

    func shouldDisplayCreateButton() -> Bool {
        return false
    }

    func isEmpty() -> Bool {
        return results.isEmpty
    }

    func emptyList() -> EmptyListProtocol {
        return EmptyFolder()
    }

    func shouldDisplaySections() -> Bool {
        return false
    }

    func numberOfSections() -> Int {
        return (results.count == 0) ? 0 : 1
    }

    func numberOfItems(in section: Int) -> Int {
        return results.count
    }

    func listNode(for indexPath: IndexPath) -> ListNode {
        return results[indexPath.row]
    }

    func titleForSectionHeader(at indexPath: IndexPath) -> String {
        return ""
    }

    func shouldDisplayListLoadingIndicator() -> Bool {
        return false
    }

    func refreshList() {
        let listNodeDataAccessor = ListNodeDataAccessor()
        if let offlineNodes = listNodeDataAccessor.querryMarkedOffline() {
            results = offlineNodes
        }

        handlePage(results: results,
                   pagination: nil,
                   error: nil)
    }

    override func fetchItems(with requestPagination: RequestPagination,
                             userInfo: Any?,
                             completionHandler: @escaping PagedResponseCompletionHandler) {
        refreshList()
    }

    override func handlePage(results: [ListNode]?, pagination: Pagination?, error: Error?) {
        updateResults(results: results, pagination: pagination, error: error)
    }

    override func updatedResults(results: [ListNode], pagination: Pagination) {
        pageUpdatingDelegate?.didUpdateList(error: nil,
                                            pagination: pagination)
    }
}

// MARK: Event observable

extension OfflineViewModel: EventObservable {
    func handle(event: BaseNodeEvent, on queue: EventQueueType) {
        if let publishedEvent = event as? FavouriteEvent {
            handleFavorite(event: publishedEvent)
        } else if let publishedEvent = event as? MoveEvent {
            handleMove(event: publishedEvent)
        } else if let publishedEvent = event as? OfflineEvent {
            handleOffline(event: publishedEvent)
        }
    }

    private func handleFavorite(event: FavouriteEvent) {
        let node = event.node
        for listNode in results where listNode == node {
            listNode.favorite = node.favorite
        }
    }

    private func handleMove(event: MoveEvent) {
        let node = event.node
        switch event.eventType {
        case .moveToTrash:
            if node.nodeType == .file {
                if let indexOfMovedNode = results.firstIndex(of: node) {
                    results.remove(at: indexOfMovedNode)
                }
            } else {
                refreshList()
            }
        case .restore:
            refreshList()

        default: break
        }
    }

    private func handleOffline(event: OfflineEvent) {
        refreshList()
    }
}
