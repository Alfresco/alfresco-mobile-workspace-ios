//
// Copyright (C) 2005-2023 Alfresco Software Limited.
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

struct WorkflowFilters {
    var localizedName: String?
    var filterID: Int
    var state: ProcessStates?
    
    init(localizedName: String?,
         filterID: Int,
         state: ProcessStates?) {
        self.localizedName = localizedName
        self.filterID = filterID
        self.state = state
    }
    
    static func getWorkflowFilters() -> [WorkflowFilters] {
        let activeFilter = WorkflowFilters(localizedName: LocalizationConstants.Tasks.active,
                                           filterID: 1,
                                           state: .running)
        
        let completedFilter = WorkflowFilters(localizedName: LocalizationConstants.Tasks.completed,
                                              filterID: 2,
                                              state: .completed)
        
        let allFilter = WorkflowFilters(localizedName: LocalizationConstants.Workflows.allTitle,
                                        filterID: 3,
                                        state: .all)
        return [activeFilter, completedFilter, allFilter]
    }
    
    static func defaultFilter() -> WorkflowFilters {
        return WorkflowFilters(localizedName: LocalizationConstants.Tasks.active,
                               filterID: 1,
                               state: .running)
    }
}
