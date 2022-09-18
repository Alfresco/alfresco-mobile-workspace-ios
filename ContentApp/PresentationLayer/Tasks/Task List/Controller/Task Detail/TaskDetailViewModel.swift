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

import Foundation

class TaskDetailViewModel: TaskPropertiesViewModel {
    let rowViewModels = Observable<[RowViewModel]>([])
    var viewAllCommentsAction: ((_ isAddComment: Bool) -> Void)?
    var viewAllAttachmentsAction: (() -> Void)?
    var isAttachmentsLoaded = false
    var didRefreshTaskList: (() -> Void)?
    var isOpenAfterTaskCreation = false
    var isEditTask = false
    var readOnlyTask: TaskNode?
    
    var editButtonTitle: String {
        if isEditTask {
            return LocalizationConstants.General.done
        } else {
            return LocalizationConstants.General.edit
        }
    }

    func isTaskUpdated() -> Bool {
        let name = readOnlyTask?.name ?? ""
        let description = readOnlyTask?.description ?? ""
        let readOnlyTaskDueDate = getDueDate(for: readOnlyTask?.dueDate)
        let taskDueDate = getDueDate(for: dueDate)
        let taskPriority = readOnlyTask?.priority ?? -1
        let userId = readOnlyTask?.assignee?.assigneeID ?? -1

        if taskName != name || taskDescription != description || readOnlyTaskDueDate != taskDueDate || priority != taskPriority || assigneeUserId != userId {
            return true
        }
        
        return false
    }
}
