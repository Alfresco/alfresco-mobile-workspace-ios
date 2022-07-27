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

// MARK: Tasks
class TasksFilters {
    var id: Int?
    var name: String?
    var isSelected: Bool?
    var state: String?
    
    init(id: Int?,
         name: String?,
         isSelected: Bool? = false,
         state: String?) {
        
        self.id = id
        self.name = name
        self.isSelected = isSelected
        self.state = state
    }
    
    static func getFiltersList() -> [TasksFilters] {
        // active tasks
        let activeTasks = TasksFilters.createFilter(for: 1,
                                        name: LocalizationConstants.Tasks.myTasks,
                                        isSelected: true,
                                        state: nil)
        
        // completed tasks
        let completedTasks = TasksFilters.createFilter(for: 2,
                                        name: LocalizationConstants.Tasks.completedTasks,
                                        state: "completed")
        
        return [activeTasks, completedTasks]
    }
    
    private static func createFilter(for id: Int?,
                                     name: String?,
                                     isSelected: Bool? = false,
                                     state: String?) -> TasksFilters {
        let taskFilter = TasksFilters(id: id,
                                      name: name,
                                      isSelected: isSelected,
                                      state: state)
        return taskFilter
    }
    
    // MARK: - Update selected filter
    static func updateSelectedFilter(at index: Int, for filters: [TasksFilters]) -> [TasksFilters] {
        for count in 0 ..< filters.count {
            if count == index {
                filters[count].isSelected = true
            } else {
                filters[count].isSelected = false
            }
        }
        return filters
    }
}
