//
// Copyright (C) 2005-2024 Alfresco Software Limited.
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
import AlfrescoContent

class AddAttachmentComplexTableViewCellViewModel: RowViewModel {
    
    var title: String?
    var attachments = [ListNode]()
    var didChangeText: ((String?) -> Void)?
    var multiSelection = false
    var field: Field?
    var tempWorkflowId: String = ""
    var fieldRequired = false
    var isFolder = false
    var folderId = ""
    var isComplexFirstTime = false
    var folderName = ""
    
    var name: String? {
        if fieldRequired {
            return String(format: "%@*", title ?? "")
        } else {
            return title
        }
    }
    
    func cellIdentifier() -> String {
        return "AddAttachmentComplexTableViewCell"
    }
    
    init(field: Field, type: ComplexFormFieldType, isComplexFirstTime: Bool) {
        if let assignee = field.value?.getValueElementArray() {
            let localAttachments = TaskAttachmentOperations.processWorkflowAttachments(for: assignee, taskId: "")
            self.attachments = localAttachments
            var guidStr = ""
            if isComplexFirstTime {
                for attachment in attachments {
                    attachment.syncStatus = .synced
                    guidStr.isEmpty ? (guidStr = attachment.guid) : (guidStr += ",\(attachment.guid)")
                }
                field.value = .string(guidStr)
                self.isComplexFirstTime = isComplexFirstTime
            }
        }
        self.field = field
        self.title = field.name
        let multiSelection = ((field.params?.multipal) != nil)
        self.multiSelection = multiSelection
        self.fieldRequired = field.fieldRequired
        let type = field.type
        if type == ComplexFormFieldType.selectfolder.rawValue {
            isFolder = true
        }
    }
}
