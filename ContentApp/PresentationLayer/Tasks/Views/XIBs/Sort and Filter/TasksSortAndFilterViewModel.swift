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

class TasksSortAndFilterViewModel: NSObject {
    var filters: [TasksFilters] = []
    var chips = [TaskChipItem]()
    var selectedChip: TaskChipItem?

    // MARK: - load filters from bundle
    func loadFiltersFromAppBundle(_ completionHandler: @escaping (_ isDone: Bool?) -> Void) {
        if let fileUrl = Bundle.main.url(forResource: KeyConstants.Tasks.configFile, withExtension: KeyConstants.Tasks.configFileExtension) {
            do {
                let data = try Data(contentsOf: fileUrl, options: [])
                parseAppConfiguration(for: data) { isDone in
                    completionHandler(isDone)
                }
            } catch let error {
                AlfrescoLog.error(error.localizedDescription)
            }
        }
    }
    
    private func parseAppConfiguration(for data: Data?, _ completionHandler: @escaping (_ isDone: Bool?) -> Void) {
        if let json = data {
            do {
                let decoded = try JSONDecoder().decode(Filter.self, from: json)
                self.filters = decoded.filters
                createChipsForTaskFilters { isDone in
                    completionHandler(isDone)
                }
            } catch {
                AlfrescoLog.error(error)
            }
        }
    }
    
    private func createChipsForTaskFilters(_ completionHandler: @escaping (_ isDone: Bool?) -> Void) {
        chips.removeAll()
        for filter in filters {
            let name = NSLocalizedString(filter.name ?? "", comment: "")
            if let componentType = filter.selector {
                let chip = TaskChipItem(chipId: filter.filterID,
                                        name: name,
                                        selected: false,
                                        selectedValue: nil,
                                        componentType: componentType,
                                        query: filter.query,
                                        options: filter.options ?? [],
                                        accessibilityIdentifier: filter.accessibilityIdentifier)
                chips.append(chip)
            }
        }
        completionHandler(true)
    }
    
    func resetChipsAction(_ completionHandler: @escaping (_ isDone: Bool?) -> Void) {
        
        let filteredChips = self.chips.filter({($0.selectedValue != nil)})
        if !filteredChips.isEmpty {
            for chip in filteredChips {
                if let index = self.chips.firstIndex(where: {($0.chipId == chip.chipId)}) {
                    chip.selected = false
                    chip.selectedValue = nil
                    
                    var chipOptions = [TaskOptions]()
                    for option in chip.options {
                        option.isSelected = false
                        if chip.componentType == .createdDateRange {
                            option.value = nil
                        }
                        chipOptions.append(option)
                    }
                    chip.options = chipOptions
                    self.chips[index] = chip
                }
            }
            completionHandler(true)
        }
    }
}
