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

class FolderDrillViewModel: PageFetchingViewModel, ListViewModelProtocol, EventObservable {
    var listRequest: SearchRequest?
    var accountService: AccountService?

    var listNodeGuid: String = kAPIPathMy
    var listNodeIsFolder: Bool = true

    var supportedNodeTypes: [ElementKindType]?

    // MARK: - Init

    required init(with accountService: AccountService?, listRequest: SearchRequest?) {
        self.accountService = accountService
        self.listRequest = listRequest
    }

    // MARK: - Public methods

    func request(with paginationRequest: RequestPagination?) {
        pageFetchingGroup.enter()

        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            let relativePath = (sSelf.listNodeIsFolder) ? nil : kAPIPathRelativeForSites
            let skipCount = paginationRequest?.skipCount
            let maxItems = paginationRequest?.maxItems ?? kListPageSize

            NodesAPI.listNodeChildren(nodeId: sSelf.listNodeGuid,
                                      skipCount: skipCount,
                                      maxItems: maxItems,
                                      orderBy: nil,
                                      _where: nil,
                                      include: [kAPIIncludeIsFavoriteNode,
                                                kAPIIncludePathNode,
                                                kAPIIncludeAllowableOperationsNode],
                                      relativePath: relativePath,
                                      includeSource: nil,
                                      fields: nil) { (result, error) in
                var listNodes: [ListNode]?
                if let entries = result?.list?.entries {
                    listNodes = NodeChildMapper.map(entries)
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

    func shouldDisplaySettingsButton() -> Bool {
        return false
    }

    // MARK: - ListViewModelProtocol

    func shouldDisplayNodePath() -> Bool {
        return false
    }

    func shouldDisplayMoreButton() -> Bool {
        return true
    }

    func isEmpty() -> Bool {
        return results.isEmpty
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
        return self.shouldDisplayNextPageLoadingIndicator
    }

    func refreshList() {
        currentPage = 1
        request(with: nil)
    }

    func updateDetails(for listNode: ListNode?, completion: @escaping ((ListNode?, Error?) -> Void)) {
        completion(listNode, nil)
    }

    override func fetchItems(with requestPagination: RequestPagination,
                             userInfo: Any?,
                             completionHandler: @escaping PagedResponseCompletionHandler) {
        request(with: requestPagination)
    }

    override func handlePage(results: [ListNode]?, pagination: Pagination?, error: Error?) {
        updateResults(results: results, pagination: pagination, error: error)
    }

    override func updatedResults(results: [ListNode], pagination: Pagination) {
        pageUpdatingDelegate?.didUpdateList(error: nil,
                                            pagination: pagination)
    }

    // MARK: Event observable

    func handle(event: BaseNodeEvent, on queue: EventQueueType) {
        if let publishedEvent = event as? FavouriteEvent {
            let node = publishedEvent.node
            for listNode in results where listNode == node {
                listNode.favorite = node.favorite
            }
        } else if let publishedEvent = event as? MoveEvent {
            let node = publishedEvent.node
            if let indexOfMovedNode = results.firstIndex(of: node), node.kind == .file {
                results.remove(at: indexOfMovedNode)
            } else {
                refreshList()
            }
        }
    }
}
