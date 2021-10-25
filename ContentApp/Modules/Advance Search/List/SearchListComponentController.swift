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
        if self.listViewModel.isRadioList {
            buildViewModelForRadioList()
        } else {
            buildViewModelForCheckList()
        }
    }
    
    // MARK: - Check List
    private func buildViewModelForCheckList() {
        var optionsArray = [RowViewModel]()
        if let options = self.listViewModel.selectedCategory?.component?.settings?.options {
            for (index, item) in options.enumerated() {
                let name = item.name
                let isSelected = item.isSelected ?? false
                let rowVM = ListItemCellViewModel(title: name, isRadioList: self.listViewModel.isRadioList, isSelected: isSelected)
                rowVM.didSelectListItem = {
                    self.updateSelectedValueForCheckList(for: index)
                }
                optionsArray.append(rowVM)
            }
        }
        self.listViewModel.rowViewModels.value = optionsArray
    }
    
    private func updateSelectedValueForCheckList(for index: Int) {
        if let category = self.listViewModel.selectedCategory {
            category.component?.settings?.options?[index].isSelected = !(category.component?.settings?.options?[index].isSelected ?? false)
            self.listViewModel.selectedCategory = category
            self.buildViewModel()
        }
    }
    
    func resetFilerForCheckList() {
        if let options = self.listViewModel.selectedCategory?.component?.settings?.options {
            var updatedOptions = [SearchComponentOptions]()
            for item in options {
                item.isSelected = false
                updatedOptions.append(item)
            }
            self.listViewModel.selectedCategory?.component?.settings?.options = options
            self.buildViewModel()
        }
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
}
