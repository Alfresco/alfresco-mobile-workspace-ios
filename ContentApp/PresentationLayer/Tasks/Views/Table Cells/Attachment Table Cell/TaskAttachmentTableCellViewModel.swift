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

class TaskAttachmentTableCellViewModel: RowViewModel {
    var name: String?
    var mimeType: String?
    var icon: UIImage? {
        return FileIcon.icon(for: mimeType)
    }
    var didSelectTaskAttachment: (() -> Void)?
    var didSelectDeleteAttachment: (() -> Void)?
    var syncStatus: ListEntrySyncStatus?

    var showSyncStatus: Bool {
        return (syncStatus != .undefined && syncStatus != .uploaded)
    }
    
    var syncStatusImage: UIImage? {
        return showSyncStatus ? UIImage(named: syncStatus?.rawValue ?? "") : nil
    }
    
    var isHideAllOptionsFromRight = false
    
    func cellIdentifier() -> String {
        return "TaskAttachmentTableViewCell"
    }
    
    init(name: String?,
         mimeType: String?,
         syncStatus: ListEntrySyncStatus?,
         isHideAllOptionsFromRight: Bool = false) {
        self.name = name
        self.mimeType = mimeType
        self.syncStatus = syncStatus
        self.isHideAllOptionsFromRight = isHideAllOptionsFromRight
    }
}
