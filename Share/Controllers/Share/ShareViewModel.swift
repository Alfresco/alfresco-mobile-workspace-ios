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
import AlfrescoAuth
import AlfrescoCore
import AlfrescoContent

class ShareViewModel: NSObject {
    var browseType: BrowseType = .personalFiles
    var paginationEnabled = true
    var currentPage = 1
    var pageSkipCount = 0
    var totalItems: Int64 = 0
    var hasMoreItems = true
    var shouldDisplayNextPageLoadingIndicator = false
    var shouldRefreshList = true
    var requestInProgress = false

    var repository: ServiceRepository {
        return ApplicationBootstrap.shared().repository
    }
    var accountService: AccountService? {
        let identifier = AccountService.identifier
        return repository.service(of: identifier) as? AccountService
    }
    var themingService: MaterialDesignThemingService? {
        let identifier = MaterialDesignThemingService.identifier
        return repository.service(of: identifier) as? MaterialDesignThemingService
    }
    var activeTheme: PresentationTheme?

    var activeAccount: AccountProtocol? {
        didSet {
            if let activeAccountIdentifier = activeAccount?.identifier {
                UserDefaultsModel.set(value: activeAccountIdentifier, for: KeyConstants.Save.activeAccountIdentifier)
            } else {
                UserDefaultsModel.remove(forKey: KeyConstants.Save.activeAccountIdentifier)
            }
        }
    }
    
    var listNode: ListNode?
    var nodeOperations: NodeOperations {
        return NodeOperations(accountService: accountService)
    }
    private let uploadTransferDataAccessor = UploadTransferDataAccessor()
    var rawListNodes: [ListNode] = []
    
    // MARK: -  Fetch Items
    func fetchItems(with requestPagination: RequestPagination,
                    completionHandler: @escaping PagedResponseCompletionHandler) {
        let reqPagination = RequestPagination(maxItems: requestPagination.maxItems,
                                              skipCount: requestPagination.skipCount)
        let relativePath = (listNode?.nodeType == .site) ? APIConstants.Path.relativeSites : nil
        if relativePath == APIConstants.Path.relativeSites {
            self.fetchItemsForDocumentLibrary(with: reqPagination) { paginatedResponse in
                completionHandler(paginatedResponse)
            }
        } else {
            self.fetchNodeChildren(with: requestPagination) { paginatedResponse in
                completionHandler(paginatedResponse)
            }
        }
    }
    
    private func fetchItemsForDocumentLibrary(with requestPagination: RequestPagination,
                                              completionHandler: @escaping PagedResponseCompletionHandler) {
        self.getNodeDetails(for: listNode) { node in
            guard let node = node else { return }
            self.listNode = node
            let reqPagination = RequestPagination(maxItems: requestPagination.maxItems,
                                                  skipCount: requestPagination.skipCount)
            self.updateNodeDetailsIfNecessary { [weak self] (_) in
                guard let sSelf = self else { return }
                let parentGuid = sSelf.listNode?.guid ?? APIConstants.my
                sSelf.nodeOperations.fetchNodeChildren(for: parentGuid,
                                                       pagination: reqPagination) { (result, error) in
                    guard let sSelf = self else { return }
                    
                    var listNodes: [ListNode] = []
                    if let entries = result?.list?.entries {
                        listNodes = NodeChildMapper.map(entries)
                    } else {
                        if let error = error {
                            AlfrescoLog.error(error)
                        }
                    }
                    
                    // Insert nodes to be uploaded
                    let responsePagination = result?.list?.pagination
                    let uploadTransfers = sSelf.uploadTransferDataAccessor.queryAll(for: parentGuid) { uploadTransfers in
                        guard let sSelf = self else { return }
                        sSelf.insert(uploadTransfers: uploadTransfers,
                                     to: &sSelf.rawListNodes,
                                     totalItems: responsePagination?.totalItems ?? 0)
                       // sSelf.delegate?.needsDisplayStateRefresh()
                    }
                    sSelf.insert(uploadTransfers: uploadTransfers,
                                 to: &listNodes,
                                 totalItems: responsePagination?.totalItems ?? 0)
                    let paginatedResponse = PaginatedResponse(results: listNodes,
                                                              error: error,
                                                              requestPagination: requestPagination,
                                                              responsePagination: responsePagination)
                    completionHandler(paginatedResponse)
                }
            }
        }
    }
    
    private func getNodeDetails(for listNode: ListNode?, completionHandler: @escaping (ListNode?) -> Void) {
        let guid = listNode?.guid ?? APIConstants.my
        let relativePath = (listNode?.nodeType == .site) ? APIConstants.Path.relativeSites : nil
        nodeOperations.fetchNodeDetails(for: guid, relativePath: relativePath) {(result, error) in
            if let error = error {
                AlfrescoLog.error(error)
                completionHandler(nil)
            } else if let entry = result?.entry {
                let node = NodeChildMapper.create(from: entry)
                print("update list")
                //self.folderChildrenDelegate?.updateListNode(with: node)
                completionHandler(node)
            }
        }
    }
    
    func fetchNodeChildren(with requestPagination: RequestPagination,
                           completionHandler: @escaping PagedResponseCompletionHandler) {
        let reqPagination = RequestPagination(maxItems: requestPagination.maxItems,
                                              skipCount: requestPagination.skipCount)
        let relativePath = (listNode?.nodeType == .site) ? APIConstants.Path.relativeSites : nil

        self.updateNodeDetailsIfNecessary { [weak self] (_) in
            guard let sSelf = self else { return }
            let parentGuid = sSelf.listNode?.guid ?? APIConstants.my
            sSelf.nodeOperations.fetchNodeChildren(for: parentGuid,
                                                   pagination: reqPagination,
                                                   relativePath: relativePath) { (result, error) in
                guard let sSelf = self else { return }
                
                var listNodes: [ListNode] = []
                if let entries = result?.list?.entries {
                    listNodes = NodeChildMapper.map(entries)
                } else {
                    if let error = error {
                        AlfrescoLog.error(error)
                    }
                }
                
                // Insert nodes to be uploaded
                let responsePagination = result?.list?.pagination
                let uploadTransfers = sSelf.uploadTransferDataAccessor.queryAll(for: parentGuid) { uploadTransfers in
                    guard let sSelf = self else { return }
                    sSelf.insert(uploadTransfers: uploadTransfers,
                                 to: &sSelf.rawListNodes,
                                 totalItems: responsePagination?.totalItems ?? 0)
                    //sSelf.delegate?.needsDisplayStateRefresh()
                }
                sSelf.insert(uploadTransfers: uploadTransfers,
                             to: &listNodes,
                             totalItems: responsePagination?.totalItems ?? 0)
                let paginatedResponse = PaginatedResponse(results: listNodes,
                                                          error: error,
                                                          requestPagination: requestPagination,
                                                          responsePagination: responsePagination)
                completionHandler(paginatedResponse)
            }
        }
    }
    
    // MARK: - Private interface

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
            }
            handle(error)
        }
    }

    private func insert(uploadTransfers: [UploadTransfer],
                        to list: inout [ListNode],
                        totalItems: Int64) {
        uploadTransfers.forEach { transfer in
            let listNode = transfer.listNode()
            if !list.contains(listNode) {
                var insertionIndex = 0

                for (index, node) in list.enumerated() {
                    if node.isFolder {
                        insertionIndex = index + 1
                    } else {
                        if node.title.localizedCompare(listNode.title) == .orderedAscending {
                            insertionIndex = index + 1
                        } else if node.title.localizedCompare(listNode.title) == .orderedSame {
                            insertionIndex = index + 1
                            break
                        } else {
                            insertionIndex = index
                            break
                        }
                    }
                }

                if list.isEmpty {
                    list.insert(listNode, at: 0)
                } else if insertionIndex < list.count {
                    list.insert(listNode, at: insertionIndex)
                } else if insertionIndex >= totalItems ||
                            list.count + 1 == totalItems {
                    list.insert(listNode, at: list.count)
                }
            }
        }
    }
    
    func isEmpty() -> Bool {
        rawListNodes.isEmpty
    }

    func numberOfItems(in section: Int) -> Int {
        return rawListNodes.count
    }

    func listNodes() -> [ListNode] {
        return rawListNodes
    }

    func listNode(for indexPath: IndexPath) -> ListNode? {
        if !rawListNodes.isEmpty && rawListNodes.count > indexPath.row {
            return rawListNodes[indexPath.row]
        } else {
            return nil
        }
    }
    
    func emptyList() -> EmptyListProtocol {
        return EmptyFolder()
    }
}
