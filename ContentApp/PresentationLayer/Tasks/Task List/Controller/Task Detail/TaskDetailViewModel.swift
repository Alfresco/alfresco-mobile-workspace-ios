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
import AlfrescoContent

class TaskDetailViewModel {
    var services: CoordinatorServices?
    var taskNode: TaskNode?
    let rowViewModels = Observable<[RowViewModel]>([])
    let isLoading = Observable<Bool>(true)

    var name: String? {
        return taskNode?.name
    }
    
    var dueDate: Date? {
        return taskNode?.dueDate
    }
    
    func getDueDate() -> String? {
        if let dueDate = dueDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            return dateFormatter.string(from: dueDate)
        }
        return nil
    }
    
    var priority: Int? {
        return taskNode?.priority
    }
    
    var assigneeName: String {
        let firstName = taskNode?.assignee?.firstName ?? ""
        let lastName = taskNode?.assignee?.lastName ?? ""
        return String(format: "%@ %@", firstName, lastName).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var status: String {
        if taskNode?.endDate == nil {
            return LocalizationConstants.Tasks.active
        }
        return LocalizationConstants.Tasks.completed
    }
    
    var taskID: String {
        return taskNode?.taskID ?? ""
    }
    
    // MARK: - Task details
    
    func taskDetails(with taskId: String, completionHandler: @escaping (_ taskNodes: TaskNode?, _ error: Error?) -> Void) {
        
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            
            TasksAPI.getTasksDetails(with: taskId) {[weak self] data, error in
                guard let sSelf = self else { return }
                sSelf.isLoading.value = false
                if data != nil {
                    let taskNodes = TaskNodeOperations.processNodes(for: [data!])
                    if !taskNodes.isEmpty {
                        sSelf.taskNode = taskNodes.first
                        completionHandler(sSelf.taskNode, nil)
                    }
                    
                } else {
                    completionHandler(nil, error)
                }
            }
        })
    }
}
