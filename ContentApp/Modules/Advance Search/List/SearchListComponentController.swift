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
    
    func buildViewModel() {
        if listViewModel.isRadioList {
            buildViewModelForRadioList()
        } else {
            buildViewModelForCheckList()
        }
    }
    
    func applyFilterAction() {
        if listViewModel.isRadioList {
            applyFilterForRadioList()
        } else {
            applyFilterForCheckList()
        }
    }
    
    func resetFilterAction() {
        if listViewModel.isRadioList {
            resetFilterForRadioList()
        } else {
            resetFilterForCheckList()
        }
    }
    
    // MARK: - Check List
    private func buildViewModelForCheckList() {
        var optionsArray = [RowViewModel]()
        if let options = listViewModel.selectedCategory?.component?.settings?.options {
            for (index, item) in options.enumerated() {
                let name = item.name
                let isSelected = item.isSelected ?? false
                let rowVM = ListItemCellViewModel(title: name, isRadioList: listViewModel.isRadioList, isSelected: isSelected)
                rowVM.didSelectListItem = {
                    self.updateSelectedValueForCheckList(for: index)
                }
                optionsArray.append(rowVM)
            }
        }
        listViewModel.rowViewModels.value = optionsArray
    }
    
    private func updateSelectedValueForCheckList(for index: Int) {
        if let category = listViewModel.selectedCategory {
            category.component?.settings?.options?[index].isSelected = !(category.component?.settings?.options?[index].isSelected ?? false)
            listViewModel.selectedCategory = category
            buildViewModelForCheckList()
        }
    }
    
    func resetFilterForCheckList() {
        if let options = listViewModel.selectedCategory?.component?.settings?.options {
            var updatedOptions = [SearchComponentOptions]()
            for item in options {
                item.isSelected = false
                updatedOptions.append(item)
            }
            listViewModel.selectedCategory?.component?.settings?.options = options
            listViewModel.selectedCategory?.component?.settings?.selectedValue = ""
        }
    }
    
    func applyFilterForCheckList() {
        var selectedValue = ""
        if let options = listViewModel.selectedCategory?.component?.settings?.options {
            let filteredArray = options.filter({$0.isSelected == true})
            for counter in 0 ..< filteredArray.count {
                let item = filteredArray[counter]
                let name = NSLocalizedString(item.name ?? "", comment: "")
                let isSelected = item.isSelected ?? false
                if counter != 0 {
                    selectedValue.append(", ")
                }
                if isSelected {
                    selectedValue.append(name)
                }
            }
        }
        listViewModel.selectedCategory?.component?.settings?.selectedValue = selectedValue
    }
    
    // MARK: - Radio List
    private func buildViewModelForRadioList() {
        var optionsArray = [RowViewModel]()
        if let options = self.listViewModel.selectedCategory?.component?.settings?.options {
            for (index, item) in options.enumerated() {
                let name = item.name
                var isSelected = item.isSelected ?? false
                let isDefault = item.isDefault ?? false
                if isDefault && self.listViewModel.isRadioButtonUIShownFirstTime {
                    isSelected = true
                    self.listViewModel.isRadioButtonUIShownFirstTime = false
                }
                let rowVM = ListItemCellViewModel(title: name, isRadioList: self.listViewModel.isRadioList, isSelected: isSelected)
                rowVM.didSelectListItem = {
                    self.updateSelectedValueForRadioList(for: index)
                }
                optionsArray.append(rowVM)
            }
        }
        self.listViewModel.rowViewModels.value = optionsArray
    }
    
    private func updateSelectedValueForRadioList(for index: Int) {
        if let category = self.listViewModel.selectedCategory {
            let options = category.component?.settings?.options ?? []
            if let row = options.firstIndex(where: {$0.isSelected == true}) {
                options[row].isSelected = false
            }
            options[index].isSelected = true
            category.component?.settings?.options = options
            self.listViewModel.selectedCategory = category
            self.buildViewModel()
        }
    }
    
    func resetFilterForRadioList() {
        /*if let options = listViewModel.selectedCategory?.component?.settings?.options {
            var updatedOptions = [SearchComponentOptions]()
            for item in options {
                item.isSelected = false
                updatedOptions.append(item)
            }
            listViewModel.selectedCategory?.component?.settings?.options = options
            listViewModel.selectedCategory?.component?.settings?.selectedValue = ""
        }*/
    }
    
    func applyFilterForRadioList() {
       /*
        var selectedValue = ""
        if let options = listViewModel.selectedCategory?.component?.settings?.options {
            let filteredArray = options.filter({$0.isSelected == true})
            for counter in 0 ..< filteredArray.count {
                let item = filteredArray[counter]
                let name = NSLocalizedString(item.name ?? "", comment: "")
                let isSelected = item.isSelected ?? false
                if counter != 0 {
                    selectedValue.append(", ")
                }
                if isSelected {
                    selectedValue.append(name)
                }
            }
        }
        listViewModel.selectedCategory?.component?.settings?.selectedValue = selectedValue
        */
    }
}
