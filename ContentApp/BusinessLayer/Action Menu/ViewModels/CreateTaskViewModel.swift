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
import Alamofire
import MaterialComponents.MaterialDialogs

protocol CreateTaskViewModelDelegate: AnyObject {
    func handleCreatedTask(task: TaskNode?, error: Error?, isUpdate: Bool)
}

enum CreateTaskViewType {
    case createTask
    case editTask
}

class CreateTaskViewModel: NSObject {
    private var coordinatorServices: CoordinatorServices?
    private weak var delegate: CreateTaskViewModelDelegate?
    var createTaskViewType: CreateTaskViewType = .createTask
    var task: TaskNode?
    var title: String? {
        if task != nil {
            return LocalizationConstants.Tasks.editTask
        }
        return LocalizationConstants.Tasks.newTask
    }
    
    var taskName: String? {
        return task?.name
    }
    
    var taskDescription: String? {
        return task?.description
    }
    
    var uploadButtonTitle: String? {
        if task != nil {
            return LocalizationConstants.General.save
        }
        return LocalizationConstants.General.create
    }

    // MARK: - Init

    init(coordinatorServices: CoordinatorServices?,
         delegate: CreateTaskViewModelDelegate?,
         createTaskViewType: CreateTaskViewType,
         task: TaskNode?) {

        self.coordinatorServices = coordinatorServices
        self.delegate = delegate
        self.createTaskViewType = createTaskViewType
        self.task = task
    }
    
    // MARK: - Public

    func createTask(with name: String, description: String?) {
        AlfrescoLog.debug("Create Task with name: \(name) and description: \(description)")
    }
}
