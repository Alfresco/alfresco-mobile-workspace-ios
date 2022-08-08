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

class TaskPropertiesViewModel: NSObject {
    var task: TaskNode?
    var services: CoordinatorServices?
    let isLoading = Observable<Bool>(true)

    var taskName: String? {
        return task?.name
    }
    
    var userName: String? {
        return task?.assignee?.userName
    }
    
    var priority: Int {
        return task?.priority ?? 0
    }
    
    var taskPriority: TaskPriority {
        if priority >= 0 && priority <= 3 {
            return .low
        } else if priority >= 4 && priority <= 7 {
            return .medium
        } else {
            return .high
        }
    }
    
    func getPriorityValues(for currentTheme: PresentationTheme) -> (textColor: UIColor, backgroundColor: UIColor, priorityText: String) {
       
        var textColor: UIColor = currentTheme.taskErrorTextColor
        var backgroundColor: UIColor = currentTheme.taskErrorContainer
        var priorityText = LocalizationConstants.Tasks.low
       
        if taskPriority == .low {
            textColor = currentTheme.taskSuccessTextColor
            backgroundColor = currentTheme.taskSuccessContainer
            priorityText = LocalizationConstants.Tasks.low
        } else if taskPriority == .medium {
            textColor = currentTheme.taskWarningTextColor
            backgroundColor = currentTheme.taskWarningContainer
            priorityText = LocalizationConstants.Tasks.medium
        } else if taskPriority == .high {
            textColor = currentTheme.taskErrorTextColor
            backgroundColor = currentTheme.taskErrorContainer
            priorityText = LocalizationConstants.Tasks.high
        }
        return(textColor, backgroundColor, priorityText)
    }
    
    var dueDate: Date? {
        return task?.dueDate
    }
    
    func getDueDate() -> String? {
        dueDate?.dateString(format: "dd MMM yyyy")
    }
    
    var status: String {
        if task?.endDate == nil {
            return LocalizationConstants.Tasks.active
        }
        return LocalizationConstants.Tasks.completed
    }
    
    var taskID: String {
        return task?.taskID ?? ""
    }
}
