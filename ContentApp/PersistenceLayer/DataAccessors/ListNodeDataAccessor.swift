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
    private let nodeOperations: NodeOperations

    init() {
        let repository = ApplicationBootstrap.shared().repository
        databaseService = repository.service(of: DatabaseService.identifier) as? DatabaseService
        accountService = repository.service(of: AccountService.identifier) as? AccountService
        self.nodeOperations = NodeOperations(accountService: accountService)
    }

    // MARK: - Database operations

    func store(node: ListNode) {
        var nodeToBeStored = node

        if node.id == 0 {
            if let queriedNode = query(node: node) {
                queriedNode.update(with: node)
                nodeToBeStored = queriedNode
            }
        }
        databaseService?.store(entity: nodeToBeStored)
    }

    func remove(node: ListNode) {
        var nodeToBeDeleted = node

        if node.id == 0 {
            if let queriedNode = query(node: node) {
                nodeToBeDeleted = queriedNode
            }
        }

        removeChildren(of: nodeToBeDeleted)
        databaseService?.remove(entity: nodeToBeDeleted)

        if let nodeURL = fileLocalPath(for: node) {
            _ = DiskService.delete(itemAtPath: nodeURL.deletingLastPathComponent().path)
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
                    ListNode.markedAsOffline == true &&
                        ListNode.markedFor != MarkedForStatus.removal.rawValue
                }.ordered(by: ListNode.title).build()
                return try query.find()
            } catch {
                AlfrescoLog.error("Unable to retrieve offline marked nodes information.")
            }
        }
        return nil
    }

    func queryMarkedForDeletion() -> [ListNode]? {
        if let listBox = databaseService?.box(entity: ListNode.self) {
            do {
                let query: Query<ListNode> = try listBox.query {
                    ListNode.markedFor == MarkedForStatus.removal.rawValue
                }.ordered(by: ListNode.title).build()
                return try query.find()
            } catch {
                AlfrescoLog.error("Unable to retrieve offline marked nodes information.")
            }
        }

        return nil
    }

    func queryMarkedForDownload() -> [ListNode]? {
        if let listBox = databaseService?.box(entity: ListNode.self) {
            do {
                let query: Query<ListNode> = try listBox.query {
                    ListNode.markedFor == MarkedForStatus.download.rawValue
                }.ordered(by: ListNode.title).build()
                return try query.find()
            } catch {
                AlfrescoLog.error("Unable to retrieve offline marked nodes information.")
            }
        }

        return nil
    }

    func querryChildren(for parentNode: ListNode?) -> [ListNode]? {
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

    // MARK: - Path construction

    func fileLocalPath(for node: ListNode) -> URL? {
        guard let accountIdentifier = nodeOperations.accountService?.activeAccount?.identifier else { return nil }
        let localPath = DiskService.documentsDirectoryPath(for: accountIdentifier)
        var localURL = URL(fileURLWithPath: localPath)
        localURL.appendPathComponent(node.guid)
        localURL.appendPathComponent(node.title)

        return localURL
    }

    func renditionLocalPath(for node: ListNode, isImageRendition: Bool) -> URL? {
        guard let accountIdentifier = nodeOperations.accountService?.activeAccount?.identifier else { return nil }
        let localPath = DiskService.documentsDirectoryPath(for: accountIdentifier)
        var localURL = URL(fileURLWithPath: localPath)
        localURL.appendPathComponent(node.guid)
        localURL.appendPathComponent(String(format: "%@-rendition", node.title))
        localURL.appendPathExtension(isImageRendition ? "png" : "pdf")

        return localURL
    }

    func isContentDownloaded(for node: ListNode) -> Bool {
        if let fileLocalPath = fileLocalPath(for: node)?.path,
           let imageRenditionPath = renditionLocalPath(for: node, isImageRendition: true)?.path,
           let pdfRenditionPath = renditionLocalPath(for: node, isImageRendition: false)?.path {
            let fileManager = FileManager.default

            let doesOriginalFileExists = fileManager.fileExists(atPath: fileLocalPath)
            let doesImagerenditionExists = fileManager.fileExists(atPath: imageRenditionPath)
            let doesPDFRenditionExists = fileManager.fileExists(atPath: pdfRenditionPath)

            if doesOriginalFileExists || doesImagerenditionExists || doesPDFRenditionExists {
                return true
            }
        }

        return false
    }

    func localRenditionType(for node: ListNode) -> RenditionType? {
        if let imageRenditionPath = renditionLocalPath(for: node, isImageRendition: true)?.path,
           let pdfRenditionPath = renditionLocalPath(for: node, isImageRendition: false)?.path {
            let fileManager = FileManager.default

            if fileManager.fileExists(atPath: imageRenditionPath) {
                return .imagePreview
            } else if fileManager.fileExists(atPath: pdfRenditionPath) {
                return .pdf
            }
        }

        return nil
    }

    func removeAllNodes() {
        if let listBox = databaseService?.box(entity: ListNode.self) {
            do {
                try listBox.removeAll()
            } catch {
                AlfrescoLog.error("Unable to remove all ListNode entity.")
            }
        }
    }

    // MARK: Private Helpers

    private func removeChildren(of node: ListNode) {
        if let children = children(of: node) {
            for listNode in children where listNode.markedAsOffline == false || listNode.markedAsOffline == nil {
                if listNode.nodeType == .folder {
                    removeChildren(of: listNode)
                } else {
                    if let nodeURL = fileLocalPath(for: listNode) {
                        _ = DiskService.delete(itemAtPath: nodeURL.deletingLastPathComponent().path)
                    }

                    databaseService?.remove(entity: listNode)
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
}
