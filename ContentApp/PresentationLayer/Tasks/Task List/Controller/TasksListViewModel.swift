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
import AlfrescoContent

class TasksListViewModel: NSObject {
    let isLoading = Observable<Bool>(false)
    let tasks = Observable<[Task]>([])

    // MARK: - Get Tasks
    func getTasks(for params: TaskListParams, completion: @escaping ([Task]) -> Void) {
       
        self.isLoading.value = true
        TasksAPI.getTasksList(params: params) { data, error in
            self.isLoading.value = false
            if data != nil {
                let tasks =  data?.data ?? []
                self.tasks.value = tasks
                completion(tasks)
            }
        }
    }
}
