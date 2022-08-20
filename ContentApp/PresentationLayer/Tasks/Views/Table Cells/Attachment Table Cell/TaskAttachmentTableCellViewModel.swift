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
    var attachment: TaskAttachmentModel?
    var didSelectTaskAttachment: (() -> Void)?
    var name: String? {
        return attachment?.name
    }
    
    var mimeType: String? {
        return attachment?.mimeType
    }
    
    var icon: UIImage? {
        return FileIcon.icon(for: mimeType)
    }
    
    func cellIdentifier() -> String {
        return "TaskAttachmentTableViewCell"
    }
    
    init(attachment: TaskAttachmentModel?) {
        self.attachment = attachment
    }
}
