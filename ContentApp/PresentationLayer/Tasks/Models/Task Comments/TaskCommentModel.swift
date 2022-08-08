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

import AlfrescoContent

class TaskCommentModel {
    var created: Date?
    var createdBy: TaskNodeAssignee?
    var commentID: Int?
    var message: String?
    var messageDate: String?

    enum CodingKeys: String, CodingKey {
        case commentID = "id"
        case created, createdBy, message
    }
    
    init(created: Date?,
         createdBy: TaskNodeAssignee?,
         commentID: Int?,
         message: String?) {
        
        self.created = created
        self.createdBy = createdBy
        self.commentID = commentID
        self.message = message
        self.messageDate = self.dateFrom(date: created)
    }
    
    private func dateFrom(date: Date?) -> String? {
        if let createdDate = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            return dateFormatter.string(from: createdDate)
        }
        return nil
    }
}
