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

class SearchListComponentViewModel {
    var selectedCategory: SearchCategories?
    var selectedOptions = [SearchComponentOptions]()
    var isRadioList = false
    let rowViewModels = Observable<[RowViewModel]>([])
    let stringConcatenator = ", "
    var queryBuilder: String?
    var taskChip: TaskChipItem?
    var taskSelectedOptions = [TaskOptions]()

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
    
    // MARK: - Query Builder
    func buildQuery() -> String? {
        var queryString = ""
        let searchOperator = self.selectedCategory?.component?.settings?.searchOperator ?? ""
        for counter in 0 ..< selectedOptions.count {
            let value = selectedOptions[counter].value ?? ""
            if !value.isEmpty {
                if counter != 0 {
                    queryString.append(" " + searchOperator + " ")
                }
                queryString.append(value)
            }
        }
        return queryString
    }
}
