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
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class SearchCalendarComponentViewModel: NSObject {
    var selectedCategory: SearchCategories?
    var selectedTextField: MDCOutlinedTextField!
    let stringConcatenator = " - "
    var selectedFromDate: Date?
    var selectedToDate: Date?

    var title: String {
        return selectedCategory?.name ?? ""
    }
    
    func selectedDateString(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-YY"
        return dateFormatter.string(from: date)
    }
    
    func date(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "dd-MMM-yy"
        return dateFormatter.date(from: dateString)
    }
    
    func getMinimumAndMaximumDateForFromTextField() -> (minimumDate: Date?, maximumDate: Date?) {
        if let toDate = selectedToDate {
            return (nil, toDate)
        }
        return (nil, Date())
    }
    
    func getMinimumAndMaximumDateForToTextField() -> (minimumDate: Date?, maximumDate: Date?) {
        if let fromDate = selectedFromDate {
            return (fromDate, Date())
        }
        return (nil, Date())
    }
    
    // MARK: - Update Selected Values
    func getPrefilledValues() -> (fromDate: String?, toDate: String?) {
        if let selectedCategory = self.selectedCategory {
            let component = selectedCategory.component
            let selectedValue = component?.settings?.selectedValue ?? ""
            let valuesArray = selectedValue.components(separatedBy: stringConcatenator)
            if valuesArray.count > 1 {
                let fromDate = valuesArray[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let toDate = valuesArray[1].trimmingCharacters(in: .whitespacesAndNewlines)
                selectedFromDate = self.date(from: fromDate)
                selectedToDate = self.date(from: toDate)
                return (fromDate, toDate)
            }
        }
        return (nil, nil)
    }
    
    // MARK: - Apply Filter
    func applyFilter(fromValue: String?, toValue: String?) {
        let minimumValue = (fromValue ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let maximumValue = (toValue ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !minimumValue.isEmpty && !maximumValue.isEmpty {
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
