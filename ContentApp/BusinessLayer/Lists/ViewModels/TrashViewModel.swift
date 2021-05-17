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
import UIKit
import AlfrescoAuth
import AlfrescoContent

class TrashViewModel: PageFetchingViewModel, ListViewModelProtocol {
    var listRequest: SearchRequest?
    var coordinatorServices: CoordinatorServices?
    var supportedNodeTypes: [NodeType] = []

    // MARK: - Init

    required init(with coordinatorServices: CoordinatorServices?, listRequest: SearchRequest?) {
        self.coordinatorServices = coordinatorServices
        self.listRequest = listRequest
    }

    // MARK: - ListViewModelProtocol

    func isEmpty() -> Bool {
        return results.isEmpty
    }

    func emptyList() -> EmptyListProtocol {
        return EmptyFolder()
    }

    func numberOfItems(in section: Int) -> Int {
        return results.count
    }

    func listNodes() -> [ListNode] {
        return results
    }
    
    func listNode(for indexPath: IndexPath) -> ListNode {
        return results[indexPath.row]
    }

    func shouldDisplayListLoadingIndicator() -> Bool {
        return self.shouldDisplayNextPageLoadingIndicator
    }

    func refreshList() {
        refreshedList = true
        currentPage = 1
        request(with: nil)
    }

    func performListAction() {
        // Do nothing
    }

    // MARK: - PageFetchingViewModel

    override func fetchItems(with requestPagination: RequestPagination, userInfo: Any?, completionHandler: @escaping PagedResponseCompletionHandler) {
        request(with: requestPagination)
    }

    override func handlePage(results: [ListNode], pagination: Pagination?, error: Error?) {
        updateResults(results: results, pagination: pagination, error: error)
    }

    override func updatedResults(results: [ListNode], pagination: Pagination) {
        pageUpdatingDelegate?.didUpdateList(error: nil,
                                            pagination: pagination)
    }

    // MARK: - Public interface

    func request(with paginationRequest: RequestPagination?) {
        pageFetchingGroup.enter()
        let accountService = coordinatorServices?.accountService
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            let skipCount = paginationRequest?.skipCount
            let maxItems = paginationRequest?.maxItems ?? APIConstants.pageSize
            TrashcanAPI.listDeletedNodes(skipCount: skipCount,
                                         maxItems: maxItems,
                                         include: [APIConstants.Include.path]) { (result, error) in
                var listNodes: [ListNode] = []
                if let entries = result?.list?.entries {
                    listNodes = DeleteNodeMapper.map(entries)
                } else {
                    if let error = error {
                        AlfrescoLog.error(error)
                    }
                }
                let paginatedResponse = PaginatedResponse(results: listNodes,
                                                          error: error,
                                                          requestPagination: paginationRequest,
                                                          responsePagination: result?.list?.pagination)
                sSelf.handlePaginatedResponse(response: paginatedResponse)
            }
        })
    }
}

// MARK: Event Observable

extension TrashViewModel: EventObservable {

    func handle(event: BaseNodeEvent, on queue: EventQueueType) {
        if let publishedEvent = event as? MoveEvent {
            handleMove(event: publishedEvent)
        }
    }

    private func handleMove(event: MoveEvent) {
        let node = event.node
        switch event.eventType {
        case .moveToTrash:
            if results.contains(node) == false {
                results.append(node)
            }
        case .restore, .permanentlyDelete:
            if let indexOfRemovedFavorite = results.firstIndex(of: node) {
                results.remove(at: indexOfRemovedFavorite)
            }
        case .created: break
        }
    }
}
