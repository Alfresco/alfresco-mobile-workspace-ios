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

enum CreateTaskViewType {
    case createTask
    case editTask
}

class CreateTaskViewModel: TaskPropertiesViewModel {
    private var coordinatorServices: CoordinatorServices?
    var createTaskViewType: CreateTaskViewType = .createTask
    var title: String? {
        if task != nil {
            return LocalizationConstants.EditTask.nameAndDescription
        }
        return LocalizationConstants.Tasks.newTask
    }
    
    var uploadButtonTitle: String? {
        if task != nil {
            return LocalizationConstants.General.save
        }
        return LocalizationConstants.Tasks.nextTitle
    }

    // MARK: - Init

    init(coordinatorServices: CoordinatorServices?,
         createTaskViewType: CreateTaskViewType,
         task: TaskNode?) {

        super.init()
        self.coordinatorServices = coordinatorServices
        self.createTaskViewType = createTaskViewType
        self.task = task
    }
}
