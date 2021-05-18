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
    var coordinatorServices: CoordinatorServices?
    let nodeOperations: NodeOperations
    var listNode: ListNode?

    var supportedNodeTypes: [NodeType] = []
    let uploadTransferDataAccessor = UploadTransferDataAccessor()

    // MARK: - Init

    required init(with coordinatorServices: CoordinatorServices?, listRequest: SearchRequest?) {
        self.coordinatorServices = coordinatorServices
        self.listRequest = listRequest
        self.nodeOperations = NodeOperations(accountService: coordinatorServices?.accountService)
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

    func refreshList() {
        refreshedList = true
        currentPage = 1
        request(with: nil)
    }
    
    func listNodes() -> [ListNode] {
        return results
    }
    
    func listNode(for indexPath: IndexPath) -> ListNode {
        return results[indexPath.row]
    }
    
    func shouldDisplaySubtitle(for indexPath: IndexPath) -> Bool {
        if listNode(for: indexPath).markedFor == .upload {
            return true
        }
        return false
    }

    func shouldDisplayCreateButton() -> Bool {
        guard let listNode = listNode else { return true }
        return listNode.hasPermissionToCreate()
    }

    func shouldDisplayListLoadingIndicator() -> Bool {
        return self.shouldDisplayNextPageLoadingIndicator
    }
    
    func shouldDisplayMoreButton(for indexPath: IndexPath) -> Bool {
        return true
    }
    
    func shouldPreviewNode(at indexPath: IndexPath) -> Bool {
        return true
    }
    
    func syncStatusForNode(at indexPath: IndexPath) -> ListEntrySyncStatus {
        let listNode = listNode(for: indexPath)
        if listNode.isAFileType() && listNode.markedFor == .upload {
            let nodeSyncStatus = listNode.syncStatus
            var entryListStatus: ListEntrySyncStatus

            switch nodeSyncStatus {
            case .pending:
                entryListStatus = .pending
            case .error:
                entryListStatus = .error
            case .inProgress:
                entryListStatus = .inProgress
            case .synced:
                entryListStatus = .uploaded
            default:
                entryListStatus = .undefined
            }

            return entryListStatus
        }

        return listNode.isMarkedOffline() ? .markedForOffline : .undefined
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

    override func handlePage(results: [ListNode], pagination: Pagination?, error: Error?) {
        updateResults(results: results, pagination: pagination, error: error)
    }

    override func updatedResults(results: [ListNode], pagination: Pagination) {
        pageUpdatingDelegate?.didUpdateList(error: nil,
                                            pagination: pagination)
    }

    // MARK: - Public methods

    func request(with paginationRequest: RequestPagination?) {
        pageFetchingGroup.enter()
        let relativePath = (listNode?.nodeType == .site) ? APIConstants.Path.relativeSites : nil
        let reqPagination = RequestPagination(maxItems: paginationRequest?.maxItems ?? APIConstants.pageSize,
                                              skipCount: paginationRequest?.skipCount)
        updateNodeDetailsIfNecessary { [weak self] (_) in
            guard let sSelf = self else { return }
            let guid = sSelf.listNode?.guid ?? APIConstants.my

            sSelf.nodeOperations.fetchNodeChildren(for: guid,
                                                   pagination: reqPagination,
                                                   relativePath: relativePath) { (result, error) in
                var listNodes: [ListNode] = []
                if let entries = result?.list?.entries {
                    listNodes = NodeChildMapper.map(entries)
                } else {
                    if let error = error {
                        AlfrescoLog.error(error)
                    }
                }

                let uploadTransfers = sSelf.uploadTransferDataAccessor
                    .queryAll(for: guid) { [weak self] uploadTransfers in
                    guard let sSelf = self else { return }
                    sSelf.appendFirstInResult(uploadTransfers: uploadTransfers)
                }
                sSelf.appendFirstInResult(uploadTransfers: uploadTransfers)

                let paginatedResponse = PaginatedResponse(results: listNodes,
                                                          error: error,
                                                          requestPagination: paginationRequest,
                                                          responsePagination: result?.list?.pagination)
                sSelf.handlePaginatedResponse(response: paginatedResponse)
            }
        }
    }

    // MARK: - Private Utils
    
    private func appendFirstInResult(uploadTransfers: [UploadTransfer]) {
        var nodesToBeInserted: [ListNode] = []
        _ = uploadTransfers.map { transfer in
            let listNode = transfer.listNode()
            if !results.contains(listNode) {
                nodesToBeInserted.insert(listNode, at: 0)
            }
        }

        if !nodesToBeInserted.isEmpty {
            results.insert(contentsOf: nodesToBeInserted, at: 0)
        }
    }

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

        nodeOperations.fetchNodeDetails(for: guid) { [weak self] (result, error) in
            guard let sSelf = self else { return }

            if let error = error {
                AlfrescoLog.error(error)
            } else if let entry = result?.entry {
                sSelf.listNode = NodeChildMapper.create(from: entry)
                sSelf.pageUpdatingDelegate?
                    .shouldDisplayCreateButton(enable: sSelf.shouldDisplayCreateButton())
            }
            handle(error)
        }
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
        } else if let publishedEvent = event as? SyncStatusEvent {
            handleSyncStatus(event: publishedEvent)
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
            results.remove(at: indexOfOfflineNode)
            results.insert(node, at: indexOfOfflineNode)
        }
    }
    
    private func handleSyncStatus(event: SyncStatusEvent) {
        let eventNode = event.node
        guard eventNode.markedFor == .upload else { return }
        for (index, listNode) in results.enumerated() where listNode.id == eventNode.id {
            results[index] = eventNode
            return
        }
    }
}
