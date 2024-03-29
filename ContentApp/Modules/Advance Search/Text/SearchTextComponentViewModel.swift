//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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

class SearchTextComponentViewModel {
    var selectedCategory: SearchCategories?
    var queryBuilder: String?
    var taskChip: TaskChipItem?
    
    var isTaskFilter: Bool {
        if taskChip != nil {
            return true
        }
        return false
    }
    
    var title: String {
        if isTaskFilter {
            return NSLocalizedString(taskChip?.name ?? "", comment: "")
        } else {
            return NSLocalizedString(selectedCategory?.name ?? "", comment: "")
        }
    }
    
    // MARK: - To get placeholder for selector
    func getPlaceholder() -> String {
        if isTaskFilter {
            return title
        } else if let selectedCategory = self.selectedCategory {
            let placeholder = selectedCategory.component?.settings?.placeholder ?? ""
            return NSLocalizedString(placeholder, comment: "")
        }
        return ""
    }
    
    // MARK: - To get already added value for selector
    func getValue() -> String {
        if isTaskFilter {
            return taskChip?.selectedValue ?? ""
        } else if let selectedCategory = self.selectedCategory {
            return selectedCategory.component?.settings?.selectedValue ?? ""
        }
        return ""
    }
    
    // MARK: - To reset filter, pass nil else pass value
    func applyFilter(with value: String?) {
        if isTaskFilter {
            taskChip?.selectedValue = value
        } else if let selectedCategory = self.selectedCategory {
            let component = selectedCategory.component
            let settings = component?.settings
            settings?.selectedValue = value
            component?.settings = settings
            selectedCategory.component = component
            self.selectedCategory = selectedCategory
            self.queryBuilder = buildQuery(with: value)
        }
    }
    
    // MARK: - Query Builder
    func buildQuery(with value: String?) -> String? {
        if let field = self.selectedCategory?.component?.settings?.field, let value = value {
            let query = "\(field):\(value)"
            return query
        }
        return nil
    }
}
