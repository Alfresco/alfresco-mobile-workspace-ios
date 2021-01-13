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
import AlfrescoCore

class SyncOperationFactory {
    let nodeOperations: NodeOperations

    init(nodeOperations: NodeOperations) {
        self.nodeOperations = nodeOperations
    }

    func nodeDetailsOperation(node: ListNode) -> AsyncClosureOperation {
        let operation = AsyncClosureOperation { [weak self] completion in
            guard let sSelf = self else { return }

            let guid = node.guid
            sSelf.nodeOperations.fetchNodeDetails(for: guid) { (result, error) in
                if let error = error {
                    if error.code == StatusCodes.code404NotFound.rawValue {
                        node.markedForDeletion = true
                    } else {
                        AlfrescoLog.error("Unexpected sync process error: \(error)")
                    }
                } else if let entry = result?.entry {
                    let onlineListNode = NodeChildMapper.create(from: entry)

                    if onlineListNode.modifiedAt != node.modifiedAt ||
                        node.localPath == nil {
                        onlineListNode.markedForDownload = true

                        let dataAccessor = ListNodeDataAccessor()
                        dataAccessor.store(node: onlineListNode)
                    }
                }

                completion()
            }
        }

        return operation
    }

    func deleteMarkedNodesOperation(nodes: [ListNode]?) -> AsyncClosureOperation {
        let operation = AsyncClosureOperation { completion in

            let dataAccessor = ListNodeDataAccessor()
            let nodesToBeRemoved = dataAccessor.queryMarkedForDeletion()

            completion()
        }

        return operation
    }

    func downloadMarkedNodesOperation(nodes: [ListNode]?) -> AsyncClosureOperation {
        let operation = AsyncClosureOperation { completion in

            completion()
        }

        return operation
    }
}
