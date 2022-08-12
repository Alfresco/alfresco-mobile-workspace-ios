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

class TaskCommentOperations: NSObject {
  
    static func processComments(for taskComments: [TaskComment]) -> [TaskCommentModel] {
        var comments: [TaskCommentModel] = []
        for comment in taskComments {
            
            let assignee = TaskNodeAssignee(assigneeID: comment.createdBy?.id ?? -1,
                                            firstName: comment.createdBy?.firstName,
                                            lastName: comment.createdBy?.lastName,
                                            email: comment.createdBy?.email)
           
            let comment = TaskCommentModel(created: comment.created,
                                           createdBy: assignee,
                                           commentID: comment.id,
                                           message: comment.message)
            comments.append(comment)
        }
        return comments
    }
}
