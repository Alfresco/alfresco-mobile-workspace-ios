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

class FolderDrillViewModel: ListComponentViewModel {
    override func emptyList() -> EmptyListProtocol {
        return EmptyFolder()
    }
    
    func shouldDisplaySubtitle(for indexPath: IndexPath) -> Bool {
        if model.listNode(for: indexPath).markedFor == .upload {
            return true
        }
        return false
    }

    override func shouldDisplayCreateButton() -> Bool {
        guard let model = model as? FolderDrillModel,
              let listNode = model.listNode else { return false }
        return listNode.hasPermissionToCreate()
    }
    
    func shouldDisplayMoreButton(for indexPath: IndexPath) -> Bool {
        return true
    }
    
    func shouldPreviewNode(at indexPath: IndexPath) -> Bool {
        return true
    }
    
    func syncStatusForNode(at indexPath: IndexPath) -> ListEntrySyncStatus {
        let node = model.listNode(for: indexPath)
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
}
