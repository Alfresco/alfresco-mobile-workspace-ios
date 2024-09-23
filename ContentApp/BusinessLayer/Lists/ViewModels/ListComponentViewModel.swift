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

protocol ListComponentViewModelDelegate: AnyObject {
    func didUpdateListActionState(enable: Bool)
}

class ListComponentViewModel {
    weak var delegate: ListComponentViewModelDelegate?
    var model: ListComponentModelProtocol
    var pageViewName: String?
    var isMultipleFileSelectionEnabled = false
    var selectedMultipleItems = [ListNode]()
    
    var isFileAvailable = true
    var isMultiFileAvailable = true
    var isFolderAvailable = true
    var isMultiFolderAvailable = true
    var isTrashAvailable = true
    
    let fileMenuIds: [MenuId] = [.openWith, .addFavorite, .removeFavorite, .startProcess, .rename, .move, .addOffline, .removeOffline, .trash]
    let multiSelectFileMenuIds: [MenuId] = [.addFavorite, .removeFavorite, .startProcess, .move, .addOffline, .removeOffline, .trash]
    let folderMenuIds: [MenuId] = [.addFavorite, .removeFavorite, .rename, .move, .addOffline, .removeOffline, .trash]
    let multiSelectFolderMenuIds: [MenuId] = [.addFavorite, .removeFavorite, .move, .addOffline, .removeOffline, .trash]
    let trashMenuIds: [MenuId] = [.permanentlyDelete, .restore]

    init(model: ListComponentModelProtocol) {
        self.model = model
    }
    
    func getAvailableMenus() {
        guard let configData = MobileConfigManager.shared.loadMobileConfigData() else {
            return }
        
        // Fetch enabled menus from config data
        let enabledMenus = configData.featuresMobile.menu.filter { $0.enabled }
        
        // Check availability of file and folder menus
        isFileAvailable = enabledMenus.contains(where: { fileMenuIds.contains($0.id) })
        isMultiFileAvailable = enabledMenus.contains(where: { multiSelectFileMenuIds.contains($0.id) })
        isFolderAvailable = enabledMenus.contains(where: { folderMenuIds.contains($0.id) })
        isMultiFolderAvailable = enabledMenus.contains(where: { multiSelectFolderMenuIds.contains($0.id) })
        isTrashAvailable = enabledMenus.contains(where: { trashMenuIds.contains($0.id) })
    }

    func checkMoveEnabled() -> Bool {
        if let configData = MobileConfigManager.shared.loadMobileConfigData() {
            return configData.featuresMobile.menu.contains { $0.id == .move && $0.enabled }
        }
        return true
    }
    
    func emptyList() -> EmptyListProtocol {
        return EmptyFolder()
    }

    func listActionTitle() -> String? {
        return nil
    }

    func shouldDisplayCreateButton() -> Bool {
        return false
    }

    func shouldDisplayListActionButton() -> Bool {
        return false
    }
    
    func shouldHideMoveItemView() -> Bool {
        let isMoveFiles = appDelegate()?.isMoveFilesAndFolderFlow ?? false
        return !isMoveFiles
    }

    func shouldDisplayPullToRefreshOffline() -> Bool {
        return false
    }

    func shouldEnableListActionButton() -> Bool {
        return false
    }

    func shouldDisplaySettingsButton() -> Bool {
        return false
    }

    func performListAction() { }

    func shouldDisplaySubtitle(for indexPath: IndexPath) -> Bool {
        return false
    }

    func shouldDisplayMoreButton(for indexPath: IndexPath) -> Bool {
        return true
    }

    func shouldPreviewNode(at indexPath: IndexPath) -> Bool {
        return true
    }
    
    func shouldDisplaySyncBanner() -> Bool {
        return false
    }
    
    func fireAnalyticEvent() { }
}
