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
        node.offline = true
        if let node = query(node: node) {
            databaseService?.remove(entity: node)
        }
        databaseService?.store(entity: node)

        if node.nodeType == .folder {
            storeChildren(of: node, paginationRequest: nil)
        }
    }

    func remove(node: ListNode) {
        if node.id == 0 {
            if let queriedNode = query(node: node) {
                node.offline = false
                databaseService?.remove(entity: queriedNode)
                removeChildren(of: node)
            }
        } else {
            node.offline = false
            databaseService?.remove(entity: node)
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
                    ListNode.offline == true
                }.build()
                return try query.find()
            } catch {
                AlfrescoLog.error("Unable to retrieve offline marked nodes information.")
            }
        }
        return nil
    }

    func isNodeMarkedAsOffline(node: ListNode) -> Bool {
        guard let node = query(node: node) else { return false }
        return node.offline ?? false
    }

    // MARK: Private Helpers

    private func storeChildren(of node: ListNode, paginationRequest: RequestPagination?) {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            NodesAPI.listNodeChildren(nodeId: node.guid,
                                      skipCount: paginationRequest?.skipCount,
                                      maxItems: paginationRequest?.maxItems ?? kMaxCount) { (result, _) in
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
                        if pagination.totalItems ?? 0 != Int64(listNodes.count) + pagination.skipCount {
                            let reqPag = RequestPagination(maxItems: kMaxCount,
                                                           skipCount: Int(pagination.skipCount))
                            sSelf.storeChildren(of: node, paginationRequest: reqPag)
                        }
                    }
                }
            }
        })
    }

    private func removeChildren(of node: ListNode) {
        if let children = children(of: node) {
            for listNode in children where listNode.offline == false {
                if listNode.nodeType == .folder {
                    removeChildren(of: listNode)
                }
                databaseService?.remove(entity: listNode)
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
}
