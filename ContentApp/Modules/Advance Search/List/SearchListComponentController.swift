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

class SearchListComponentController: NSObject {
    let listViewModel: SearchListComponentViewModel

    init(viewModel: SearchListComponentViewModel = SearchListComponentViewModel()) {
        self.listViewModel = viewModel
    }
    
    func cellIdentifier(for viewModel: RowViewModel) -> String {
        switch viewModel {
        case is ListItemCellViewModel:
            return ListItemTableViewCell.cellIdentifier()
        default:
            fatalError("Unexpected view model type: \(viewModel)")
        }
    }
    
    // MARK: - Build View Models
    func buildViewModel() {
        var optionsArray = [RowViewModel]()
        if let options = listViewModel.selectedCategory?.component?.settings?.options {
            for (index, item) in options.enumerated() {
                let name = item.name
                let value = item.value
                var isSelected = false
                if listViewModel.selectedOptions.firstIndex(where: {$0.value == value}) != nil {
                    isSelected = true
                }
                
                let rowVM = ListItemCellViewModel(title: name, isRadioList: listViewModel.isRadioList, isSelected: isSelected)
                rowVM.didSelectListItem = {
                    if self.listViewModel.isRadioList {
                        self.updateSelectedValueForRadioList(for: index)
                    } else {
                        self.updateSelectedValueForCheckList(for: index)
                    }
                }
                optionsArray.append(rowVM)
            }
        }
        listViewModel.rowViewModels.value = optionsArray
    }
    
    func applyFilterAction() {
        var selectedValue = ""
        let options = listViewModel.selectedOptions
        for counter in 0 ..< options.count {
            let item = options[counter]
            let name = NSLocalizedString(item.name ?? "", comment: "")
            let value = item.value ?? ""
            if !value.isEmpty {
                if counter != 0 {
                    selectedValue.append(listViewModel.stringConcatenator)
                }
                selectedValue.append(name)
            }
        }
        listViewModel.selectedCategory?.component?.settings?.selectedValue = selectedValue
        listViewModel.queryBuilder = listViewModel.buildQuery()
    }
    
    func resetFilterAction() {
        listViewModel.selectedOptions = []
        listViewModel.selectedCategory?.component?.settings?.selectedValue = ""
        listViewModel.queryBuilder = listViewModel.buildQuery()
    }
    
    // MARK: - Update Selected Values
    func updatedSelectedValues() {
        if let category = listViewModel.selectedCategory,
            let selectedValue = category.component?.settings?.selectedValue,
            let options = category.component?.settings?.options {
            
            let valuesArray = selectedValue.components(separatedBy: listViewModel.stringConcatenator)
            for value in valuesArray {
                let localizedValue = NSLocalizedString(value, comment: "")
                if let index = options.firstIndex(where: {NSLocalizedString($0.name ?? "", comment: "") == localizedValue}) {
                    let object = options[index]
                    self.listViewModel.selectedOptions.append(object)
                }
            }
        }
        
        if listViewModel.isRadioList && listViewModel.selectedOptions.isEmpty {
            if let category = listViewModel.selectedCategory,
                let options = category.component?.settings?.options {
                if let index = options.firstIndex(where: {$0.isDefault == true}) {
                    let object = options[index]
                    self.listViewModel.selectedOptions.append(object)
                }
            }
        }
    }
    
    // MARK: - Check List
    private func updateSelectedValueForCheckList(for index: Int) {
        if let category = listViewModel.selectedCategory,
            let options = category.component?.settings?.options {
            let value = options[index].value ?? ""
            
            if let index = listViewModel.selectedOptions.firstIndex(where: {$0.value == value}) {
                listViewModel.selectedOptions.remove(at: index)
            } else {
                listViewModel.selectedOptions.append(options[index])
            }
            buildViewModel()
        }
    }
        
    // MARK: - Radio List
    private func updateSelectedValueForRadioList(for index: Int) {
        if let category = self.listViewModel.selectedCategory {
            let options = category.component?.settings?.options ?? []
            listViewModel.selectedOptions.removeAll()
            listViewModel.selectedOptions.append(options[index])
            buildViewModel()
        }
    }
}
