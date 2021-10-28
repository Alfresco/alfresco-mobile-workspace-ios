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

import UIKit
import AlfrescoContent

class SearchNumberRangeComponentViewModel: NSObject {
    var selectedCategory: SearchCategories?
    let stringConcatenator = "-"
    let errorTopConstraint = 24.0
    
    var title: String {
        return selectedCategory?.name ?? ""
    }
    
    // MARK: - Update Selected Values
    func getPrefilledValues() -> (minValue: String?, maxValue: String?) {
        if let selectedCategory = self.selectedCategory {
            let component = selectedCategory.component
            let selectedValue = component?.settings?.selectedValue ?? ""
            let valuesArray = selectedValue.components(separatedBy: stringConcatenator)
            if valuesArray.count > 1 {
                let minimumValue = valuesArray[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let maximumValue = valuesArray[1].trimmingCharacters(in: .whitespacesAndNewlines)
                return (minimumValue, maximumValue)
            }
        }
        return (nil, nil)
    }

    // MARK: - Apply Filter
    func isValidationPassed(minValue: String?, maxValue: String?) -> Bool {
        let minimumValue = (minValue ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let maximumValue = (maxValue ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if minimumValue.isEmpty || maximumValue.isEmpty {
            return true
        } else if Int(maximumValue) ?? 0 <= Int(minimumValue) ?? 0 {
            return false
        } else {
            return true
        }
    }
    
    func applyFilter(minValue: String?, maxValue: String?) {
        let minimumValue = (minValue ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let maximumValue = (maxValue ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !minimumValue.isEmpty && !maximumValue.isEmpty && Int(maximumValue) ?? 0 > Int(minimumValue) ?? 0 {
            let value = String(format: "%@ %@ %@", minimumValue, stringConcatenator, maximumValue)
            if let selectedCategory = self.selectedCategory {
                let component = selectedCategory.component
                let settings = component?.settings
                settings?.selectedValue = value
                component?.settings = settings
                selectedCategory.component = component
                self.selectedCategory = selectedCategory
            }
        }
    }
    
    // MARK: - Reset Filter
    func resetFilter() {
        if let selectedCategory = self.selectedCategory {
            let component = selectedCategory.component
            let settings = component?.settings
            settings?.selectedValue = nil
            component?.settings = settings
            selectedCategory.component = component
            self.selectedCategory = selectedCategory
        }
    }
}
