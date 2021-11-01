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
    var pattern = "(.*?)"
    var queryBuilder: String?

    var title: String {
        return selectedCategory?.name ?? ""
    }
    
    // MARK: - To get placeholder for selector
    func getPlaceholder() -> String {
        if let selectedCategory = self.selectedCategory {
            return selectedCategory.component?.settings?.placeholder ?? ""
        }
        return ""
    }
    
    // MARK: - To get already added value for selector
    func getValue() -> String {
        if let selectedCategory = self.selectedCategory {
            return selectedCategory.component?.settings?.selectedValue ?? ""
        }
        return ""
    }
    
    // MARK: - To reset filter, pass nil else pass value
    func applyFilter(with value: String?) {
        if let selectedCategory = self.selectedCategory {
            let component = selectedCategory.component
            let settings = component?.settings
            settings?.selectedValue = value
            component?.settings = settings
            selectedCategory.component = component
            self.selectedCategory = selectedCategory
            buildQuery(with: value)
        }
    }
    
    // MARK: - Query Builder
    func buildQuery(with value: String?) -> String? {
        if let selectedCategory = self.selectedCategory {
            if let pattern = selectedCategory.component?.settings?.pattern {
                let patternArray = pattern.components(separatedBy: "'")
                if patternArray.count > 1 {
                    let query = String(format: "%@'%@'", patternArray[0], patternArray[1])
                    AlfrescoLog.debug("Quey builder: \(query)")
                    return query
                }
            }
        }
        return nil
    }
}
