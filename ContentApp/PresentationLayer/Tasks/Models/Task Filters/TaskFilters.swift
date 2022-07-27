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
    var recent: Bool?
    var icon: String?
    var isSelected: Bool?
    var filter: TasksFilterQuery?
    
    init(id: Int?,
         name: String?,
         recent: Bool?,
         icon: String?,
         isSelected: Bool? = false,
         filter: TasksFilterQuery?) {
        
        self.id = id
        self.name = name
        self.recent = recent
        self.icon = icon
        self.isSelected = isSelected
        self.filter = filter
    }
}

// MARK: Task Assignee
class TasksFilterQuery: Codable {
    var sort: String?
    var name: String?
    var assignment: String?
    
    init(sort: String?,
         name: String?,
         assignment: String?) {
        self.sort = sort
        self.name = name
        self.assignment = assignment
    }
}
