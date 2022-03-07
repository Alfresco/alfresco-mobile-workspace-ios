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
    private var shouldEnableListButton = false
    var services: CoordinatorServices?

    override func emptyList() -> EmptyListProtocol {
        return EmptyUploads()
    }

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
    
    override func shouldDisplayMoreButton(for indexPath: IndexPath) -> Bool {
        switch model.syncStatusForNode(at: indexPath) {
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
    
    override func shouldDisplayListActionButton() -> Bool {
        return true
    }
    
    override func listActionTitle() -> String? {
        return LocalizationConstants.Buttons.syncAll
    }
    
    override func performListAction() {
        let connectivityService = services?.connectivityService
        let syncTriggersService = services?.syncTriggersService
        if connectivityService?.status == .cellular &&
            UserProfile.allowSyncOverCellularData == false {
            syncTriggersService?.showOverrideSyncOnCellularDataDialog(for: .userDidInitiateSync)
        } else {
            syncTriggersService?.triggerSync(for: .userDidInitiateSync)
        }
    }
}

// MARK: - SyncServiceDelegate

extension UploadNodesViewModel: SyncServiceDelegate {
    func syncDidStarted() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.shouldEnableListButton = false
            sSelf.delegate?.didUpdateListActionState(enable: false)
        }
    }

    func syncDidFinished() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.shouldEnableListButton = true
            sSelf.delegate?.didUpdateListActionState(enable: true)
        }
    }
}
