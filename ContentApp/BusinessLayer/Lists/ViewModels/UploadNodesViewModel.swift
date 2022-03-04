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

class UploadNodesViewModel: ListComponentViewModel {
    
    func queryAll() -> [UploadTransfer] {
        let dataAccessor = UploadTransferDataAccessor()
        let pendingUploadTransfers = dataAccessor.queryAll()
        return pendingUploadTransfers
    }
    
    func listNodes() -> [ListNode] {
        let items = self.queryAll()
        return items.map({$0.listNode()})
    }
    
    func numberOfItems() -> Int {
        return listNodes().count
    }
    
    func isEmpty() -> Bool {
        return listNodes().isEmpty
    }
    
    func listNode(for index: Int) -> ListNode? {
        return listNodes()[index]
    }
    
    func syncStatusForNode(at index: Int) -> ListEntrySyncStatus {
        if let node = listNode(for: index) {
            if node.isAFileType() && node.markedFor == .upload {
                let nodeSyncStatus = node.syncStatus
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

            return node.isMarkedOffline() ? .markedForOffline : .undefined
        }
        return .undefined
    }
    
    func shouldDisplayMoreButton(for index: Int) -> Bool {
        switch syncStatusForNode(at: index) {
        case .pending:
            return false
        case .inProgress:
            return false
        case .error:
            return false
        default:
            return true
        }
    }
}

