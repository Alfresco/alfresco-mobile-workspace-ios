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

class FolderDrillViewModel: PageFetchingViewModel, ListViewModelProtocol {
    var listRequest: SearchRequest?
    var accountService: AccountService?
    var listNode: ListNode?

    var supportedNodeTypes: [NodeType]?

    // MARK: - ListViewModelProtocol

    required init(with accountService: AccountService?, listRequest: SearchRequest?) {
        self.accountService = accountService
        self.listRequest = listRequest
    }

    func shouldDisplaySettingsButton() -> Bool {
        return false
    }

    func shouldDisplayNodePath() -> Bool {
        return false
    }

    func shouldDisplayMoreButton() -> Bool {
        return true
    }

    func shouldDisplayCreateButton() -> Bool {
        return false
//        guard let listNode = listNode else { return true }
//        return listNode.hasPermissionToCreate()
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
        return self.shouldDisplayNextPageLoadingIndicator
    }

    func refreshList() {
        currentPage = 1
        request(with: nil)
    }

    func performListAction() {
        // Do nothing
    }

    // MARK: - PageFetchingViewModel

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

    // MARK: - Public methods

    func request(with paginationRequest: RequestPagination?) {
        pageFetchingGroup.enter()

        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            let relativePath = (sSelf.listNode?.nodeType == .site) ? kAPIPathRelativeForSites : nil
            let skipCount = paginationRequest?.skipCount
            let maxItems = paginationRequest?.maxItems ?? kListPageSize
            sSelf.updateNodeDetailsIfNecessary { (_) in
                NodesAPI.listNodeChildren(nodeId: sSelf.listNode?.guid ?? kAPIPathMy,
                                          skipCount: skipCount,
                                          maxItems: maxItems,
                                          orderBy: nil,
                                          _where: nil,
                                          include: [kAPIIncludeIsFavoriteNode,
                                                    kAPIIncludePathNode,
                                                    kAPIIncludeAllowableOperationsNode,
                                                    kAPIIncludeProperties],
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
            }
        })
    }

    // MARK: - Private Utils

    private func updateNodeDetailsIfNecessary(handle: @escaping (Error?) -> Void) {
        guard let listNode = self.listNode else {
            handle(nil)
            return
        }
        if listNode.nodeType == .folderLink {
            updateDetails(for: listNode, handle: handle)
            return
        }
        if listNode.nodeType == .site || listNode.shouldUpdate() == false {
            handle(nil)
            return
        }
        updateDetails(for: listNode, handle: handle)
    }

    private func updateDetails(for listNode: ListNode, handle: @escaping (Error?) -> Void) {
        var guid = listNode.guid
        if listNode.nodeType == .folderLink {
            guid = listNode.destination ?? listNode.guid
        }
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            NodesAPI.getNode(nodeId: guid,
                             include: [kAPIIncludePathNode,
                                       kAPIIncludeIsFavoriteNode,
                                       kAPIIncludeAllowableOperationsNode,
                                       kAPIIncludeProperties],
                             relativePath: nil) { (result, error) in
                if let error = error {
                    AlfrescoLog.error(error)
                } else if let entry = result?.entry {
                    sSelf.listNode = NodeChildMapper.create(from: entry)
                    sSelf.pageUpdatingDelegate?
                        .shouldDisplayCreateButton(enable: sSelf.shouldDisplayCreateButton())
                }
                handle(error)
            }
        })
    }
}

// MARK: Event observable

extension FolderDrillViewModel: EventObservable {

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
        case .created:
            if self.listNode?.guid == node.guid || listNode == nil {
                refreshList()
            }
        default: break
        }
    }

    private func handleOffline(event: OfflineEvent) {
        let node = event.node
        if let indexOfOfflineNode = results.firstIndex(of: node) {
            results[indexOfOfflineNode] = node
        }
    }
}
