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
    
    var dateFormat: String {
        if let dateFormat = self.selectedCategory?.component?.settings?.dateFormat {
            var format = dateFormat.replacingOccurrences(of: "D", with: "d")
            format = format.replacingOccurrences(of: "Y", with: "y")
            return format
        }
        return "dd-MMM-yy"
    }
    
    func selectedDateString(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    func date(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = dateFormat
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
    
    func getSelectedFromDate() -> Date {
        if let date = selectedFromDate {
            return date
        }
        return Date()
    }
    
    func getSelectedToDate() -> Date {
        if let date = selectedToDate {
            return date
        }
        return Date()
    }
    
    // MARK: - Update Selected Values
    func getPrefilledValues() -> (fromDate: String?, toDate: String?) {
        var selectedValue = ""
        if isTaskFilter {
            selectedValue = taskChip?.selectedValue ?? ""
        } else if let selectedCategory = self.selectedCategory {
            let component = selectedCategory.component
            selectedValue = component?.settings?.selectedValue ?? ""
        }
        
        let valuesArray = selectedValue.components(separatedBy: stringConcatenator)
        if valuesArray.count > 1 {
            let fromDate = valuesArray[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let toDate = valuesArray[1].trimmingCharacters(in: .whitespacesAndNewlines)
            selectedFromDate = self.date(from: fromDate)
            selectedToDate = self.date(from: toDate)
            return (fromDate, toDate)
        } else if let chip = taskChip {
            let fromDate = chip.options[0].value ?? ""
            let toDate = chip.options[1].value ?? ""
            selectedFromDate = self.date(from: fromDate)
            selectedToDate = self.date(from: toDate)
            return (fromDate, toDate)
        }
        return (nil, nil)
    }
    
    // MARK: - Apply Filter
    func applyFilter(fromValue: String?, toValue: String?) {
        let minimumValue = (fromValue ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let maximumValue = (toValue ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if isTaskFilter {
            self.applyTaskFilter(fromValue: fromValue, toValue: toValue)
        } else if !minimumValue.isEmpty && !maximumValue.isEmpty {
            let value = String(format: "%@ %@ %@", minimumValue, stringConcatenator, maximumValue)
            if let selectedCategory = self.selectedCategory {
                let component = selectedCategory.component
                let settings = component?.settings
                settings?.selectedValue = value
                component?.settings = settings
                selectedCategory.component = component
                self.selectedCategory = selectedCategory
                queryBuilder = buildQuery(with: value)
            }
        }
    }
    
    func applyTaskFilter(fromValue: String?, toValue: String?) {
        let minimumValue = (fromValue ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let maximumValue = (toValue ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if let options = taskChip?.options {
            var value = ""
            if !minimumValue.isEmpty && !maximumValue.isEmpty {
                value = String(format: "%@ %@ %@", minimumValue, stringConcatenator, maximumValue)
                
                options[0].isSelected = true
                options[1].isSelected = true
                options[0].value = getTaskDateString(from: getSelectedFromDate())
                options[1].value = getTaskDateString(from: getSelectedToDate())
            } else if !minimumValue.isEmpty {
                value = minimumValue
                options[0].isSelected = true
                options[0].value = getTaskDateString(from: getSelectedFromDate())
            } else if !maximumValue.isEmpty {
                value = maximumValue
                options[1].isSelected = true
                options[1].value = getTaskDateString(from: getSelectedToDate())
            }
            taskChip?.selectedValue = value
            taskChip?.options = options
        }
    }
    
    // MARK: - Reset Filter
    func resetFilter() {
        if isTaskFilter {
            resetTaskFilter()
        } else if let selectedCategory = self.selectedCategory {
            let component = selectedCategory.component
            let settings = component?.settings
            settings?.selectedValue = nil
            component?.settings = settings
            selectedCategory.component = component
            self.selectedCategory = selectedCategory
            queryBuilder = buildQuery(with: nil)
        }
    }
    
    func resetTaskFilter() {
        if let chip = taskChip {
            chip.selectedValue = nil
            chip.options[0].isSelected = false
            chip.options[0].value = nil
            chip.options[1].isSelected = false
            chip.options[1].value = nil
            taskChip = chip
        }
    }
    
    // MARK: - Query Builder
    func buildQuery(with selectedValue: String?) -> String? {
        if let field = self.selectedCategory?.component?.settings?.field, let _ = selectedValue {
            let fromDate = getDateString(from: getSelectedFromDate(), and: "00:00:00")
            let toDate = getDateString(from: getSelectedToDate(), and: "23:59:59")
            let query = String(format: "%@:['%@' TO '%@']", field, fromDate, toDate)
            return query
        }
        return nil
    }
    
    func getDateString(from date: Date, and time: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'\(time)Z"
        return dateFormatter.string(from: date)
    }
    
    func getTaskDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}

