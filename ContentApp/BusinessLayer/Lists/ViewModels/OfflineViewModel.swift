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
import MaterialComponents.MaterialDialogs

class OfflineViewModel: ListComponentViewModel {
    private var shouldEnableListButton = true
    var services: CoordinatorServices?

    override func emptyList() -> EmptyListProtocol {
        return EmptyOffline()
    }

    override func shouldDisplaySubtitle(for indexPath: IndexPath) -> Bool {
        return true
    }

    override func shouldPreviewNode(at indexPath: IndexPath) -> Bool {
        if let node = model.listNode(for: indexPath) {
            let listNodeDataAccessor = ListNodeDataAccessor()
            if node.isAFolderType() {
                return true
            }
            if listNodeDataAccessor.isContentDownloaded(for: node) {
                return true
            }
        }
        return false
    }

    override func shouldDisplaySettingsButton() -> Bool {
            return true
    }

    override func shouldDisplayListActionButton() -> Bool {
        return !model.rawListNodes.isEmpty
    }

    override func listActionTitle() -> String? {
        return LocalizationConstants.Buttons.syncAll
    }

    override func shouldEnableListActionButton() -> Bool {
        return shouldEnableListButton
    }

    override func shouldDisplayPullToRefreshOffline() -> Bool {
        true
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

extension OfflineViewModel: SyncServiceDelegate {
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
            SyncBannerService.updateProgress()
        }
    }
}

