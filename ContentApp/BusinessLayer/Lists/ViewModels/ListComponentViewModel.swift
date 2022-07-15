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

protocol ListComponentViewModelDelegate: AnyObject {
    func didUpdateListActionState(enable: Bool)
}

class ListComponentViewModel {
    weak var delegate: ListComponentViewModelDelegate?
    var model: ListComponentModelProtocol
    var pageViewName: String?

    init(model: ListComponentModelProtocol) {
        self.model = model
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
