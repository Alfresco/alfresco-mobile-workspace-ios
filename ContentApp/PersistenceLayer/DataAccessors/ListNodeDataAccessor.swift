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
import ObjectBox
import AlfrescoContent

let kMaxCount = 100

class ListNodeDataAccessor {
    private var databaseService: DatabaseService?
    private var accountService: AccountService?

    init() {
        let repository = ApplicationBootstrap.shared().repository
        databaseService = repository.service(of: DatabaseService.identifier) as? DatabaseService
        accountService = repository.service(of: AccountService.identifier) as? AccountService
    }

    func store(node: ListNode) {
        node.markedAsOffline = true

        if node.id == 0 {
            if let queriedNode = query(node: node) {
                update(node: queriedNode, with: node)
                databaseService?.store(entity: queriedNode)
            }
        } else {
            databaseService?.store(entity: node)
        }

        if node.nodeType == .folder {
            storeChildren(of: node, paginationRequest: nil)
        }
    }

    func remove(node: ListNode) {
        if node.id == 0 {
            if let queriedNode = query(node: node) {
                queriedNode.markedAsOffline = false
                queriedNode.markedForDeletion = true
                databaseService?.store(entity: queriedNode)
                removeChildren(of: queriedNode)
            }
        } else {
            node.markedAsOffline = false
            node.markedForDeletion = true
            databaseService?.store(entity: node)
            removeChildren(of: node)
        }
    }

    func query(node: ListNode) -> ListNode? {
        if let listBox = databaseService?.box(entity: ListNode.self) {
            do {
                let querry: Query<ListNode> = try listBox.query {
                    ListNode.guid == node.guid
                }.build()
                let node = try querry.findUnique()
                return node
            } catch {
                AlfrescoLog.error("Unable to retrieve node information.")
            }
        }
        return nil
    }

    func queryAll() -> [ListNode]? {
        databaseService?.queryAll(entity: ListNode.self)
    }

    func queryMarkedOffline() -> [ListNode]? {
        if let listBox = databaseService?.box(entity: ListNode.self) {
            do {
                let query: Query<ListNode> = try listBox.query {
                    ListNode.markedAsOffline == true
                }.ordered(by: ListNode.title).build()
                return try query.find()
            } catch {
                AlfrescoLog.error("Unable to retrieve offline marked nodes information.")
            }
        }
        return nil
    }

    func querryOfflineChildren(for parentNode: ListNode?) -> [ListNode]? {
        guard let node = parentNode else { return nil }
        if let listBox = databaseService?.box(entity: ListNode.self) {
            do {
                let query: Query<ListNode> = try listBox.query {
                    ListNode.parentGuid == node.guid
                }.ordered(by: ListNode.title).build()
                return try query.find()
            } catch {
                AlfrescoLog.error("Unable to retrieve offline marked nodes information.")
            }
        }
        return nil
    }

    func isNodeMarkedAsOffline(node: ListNode) -> Bool {
        guard let node = query(node: node) else { return false }
        return node.markedAsOffline ?? false
    }

    // MARK: Private Helpers

    private func storeChildren(of node: ListNode, paginationRequest: RequestPagination?) {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            NodesAPI.listNodeChildren(nodeId: node.guid,
                                      skipCount: paginationRequest?.skipCount,
                                      maxItems: paginationRequest?.maxItems ?? kMaxCount,
                                      include: [kAPIIncludeIsFavoriteNode,
                                                kAPIIncludePathNode,
                                                kAPIIncludeAllowableOperationsNode,
                                                kAPIIncludeProperties]) { (result, _) in
                if let entries = result?.list?.entries {
                    let listNodes = NodeChildMapper.map(entries)
                    for listNode in listNodes {
                        if sSelf.query(node: listNode) == nil {
                            sSelf.databaseService?.store(entity: listNode)
                        }
                        if listNode.nodeType == .folder {
                            sSelf.storeChildren(of: listNode, paginationRequest: nil)
                        }
                    }
                    if let pagination = result?.list?.pagination {
                        let skipCount = Int64(listNodes.count) + pagination.skipCount
                        if pagination.totalItems ?? 0 != skipCount {
                            let reqPag = RequestPagination(maxItems: kMaxCount,
                                                           skipCount: Int(skipCount))
                            sSelf.storeChildren(of: node, paginationRequest: reqPag)
                        }
                    }
                }
            }
        })
    }

    private func removeChildren(of node: ListNode) {
        if let children = children(of: node) {
            for listNode in children where listNode.markedAsOffline == false {
                if listNode.nodeType == .folder {
                    removeChildren(of: listNode)
                }
                if let queryNode = query(node: listNode),
                   queryNode.markedForDeletion == false {
                    queryNode.markedAsOffline = false
                    queryNode.markedForDeletion = true
                    databaseService?.store(entity: queryNode)
                }
            }
        }
    }

    private func children(of node: ListNode) -> [ListNode]? {
        if let listBox = databaseService?.box(entity: ListNode.self) {
            do {
                let query: Query<ListNode> = try listBox.query {
                    ListNode.parentGuid == node.guid
                }.build()
                return try query.find()
            } catch {
                AlfrescoLog.error("Unable to retrieve children node information.")
            }
        }
        return nil
    }

    func update(node: ListNode, with newVersion: ListNode) {
        node.parentGuid = newVersion.parentGuid
        node.siteID = newVersion.siteID
        node.destination = newVersion.destination
        node.mimeType = newVersion.mimeType
        node.title = newVersion.title
        node.path = newVersion.path
        node.modifiedAt = newVersion.modifiedAt
        node.favorite = newVersion.favorite
        node.nodeType = newVersion.nodeType
        node.allowableOperations = newVersion.allowableOperations
    }
}
