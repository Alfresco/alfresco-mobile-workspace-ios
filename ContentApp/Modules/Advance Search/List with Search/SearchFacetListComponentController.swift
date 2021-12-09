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

class SearchFacetListComponentController: NSObject {
    let facetViewModel: SearchFacetListComponentViewModel

    init(viewModel: SearchFacetListComponentViewModel = SearchFacetListComponentViewModel()) {
        self.facetViewModel = viewModel
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
        if facetViewModel.componentType == .facetQuery {
            buildViewModelForFacetQueries()
        } else if facetViewModel.componentType == .facetField {
            buildViewModelForFacetFields()
        } else if facetViewModel.componentType == .facetInterval {
            buildViewModelForFacetIntervals()
        }
    }
    
    func buildViewModelForFacetQueries() {
        var optionsArray = [RowViewModel]()
        let facetQueries = facetViewModel.facetQueryOptions
        for (index, item) in facetQueries.enumerated() {
            let label = item.label ?? ""
            let name = NSLocalizedString(label, comment: "")
            let count = item.count ?? 0
            let title = String(format: "%@ (%d)", name, count)
            var isSelected = false
            if facetViewModel.selectedFacetQuery.enumerated().first(where: {$0.element.label == label}) != nil {
                isSelected = true
            }
            let rowVM = ListItemCellViewModel(title: title, isRadioList: false, isSelected: isSelected)
            rowVM.didSelectListItem = {
                self.updateSelectedValueForFacetQueries(for: index)
            }
            optionsArray.append(rowVM)
        }
        
        facetViewModel.rowViewModels.value = optionsArray
    }
    
    func buildViewModelForFacetFields() {
        var optionsArray = [RowViewModel]()
        let facetFieldOptions = facetViewModel.facetFieldOptions
        for (index, item) in facetFieldOptions.enumerated() {
            let label = item.label ?? ""
            let name = NSLocalizedString(label, comment: "")
            let count = item.count ?? "0"
            let title = String(format: "%@ (%@)", name, count)
            var isSelected = false
            if facetViewModel.selectedFacetField.enumerated().first(where: {$0.element.label == label}) != nil {
                isSelected = true
            }
            let rowVM = ListItemCellViewModel(title: title, isRadioList: false, isSelected: isSelected)
            rowVM.didSelectListItem = {
                self.updateSelectedValueForFacetFields(for: index)
            }
            optionsArray.append(rowVM)
        }
        
        facetViewModel.rowViewModels.value = optionsArray
    }
    
    func buildViewModelForFacetIntervals() {
        var optionsArray = [RowViewModel]()
        let facetIntervalOptions = facetViewModel.facetIntervalOptions
        for (index, item) in facetIntervalOptions.enumerated() {
            let label = item.label ?? ""
            let name = NSLocalizedString(label, comment: "")
            let count = item.count ?? "0"
            let title = String(format: "%@ (%@)", name, count)
            var isSelected = false
            if facetViewModel.selectedFacetInterval.enumerated().first(where: {$0.element.label == label}) != nil {
                isSelected = true
            }
            let rowVM = ListItemCellViewModel(title: title, isRadioList: false, isSelected: isSelected)
            rowVM.didSelectListItem = {
                self.updateSelectedValueForFacetIntervals(for: index)
            }
            optionsArray.append(rowVM)
        }
        
        facetViewModel.rowViewModels.value = optionsArray
    }
    
    // MARK: - Update Selected Values
    func updatedSelectedValues() {
        if facetViewModel.componentType == .facetQuery {
            updatedSelectedValuesForFacetQueries()
        } else if facetViewModel.componentType == .facetField {
            updatedSelectedValuesForFacetFields()
        } else if facetViewModel.componentType == .facetInterval {
            updatedSelectedValuesForFacetIntervals()
        }
    }
    
    func updatedSelectedValuesForFacetQueries() {
        
        let facetQueryOptions = facetViewModel.facetQueryOptions
        if let selectedFacetQueryString = facetViewModel.selectedFacetQueryString, !selectedFacetQueryString.isEmpty {
            let valuesArray = selectedFacetQueryString.components(separatedBy: facetViewModel.stringConcatenator)

            for value in valuesArray {
                let localizedValue = NSLocalizedString(value, comment: "")
                if let object = facetQueryOptions.enumerated().first(where: {NSLocalizedString($0.element.label ?? "", comment: "") == localizedValue}) {
                    self.facetViewModel.selectedFacetQuery.append(object.element)
                }
            }
        }
    }
    
    func updatedSelectedValuesForFacetFields() {
        
        let facetFieldOptions = facetViewModel.facetFieldOptions
        if let selectedFacetFieldString = facetViewModel.selectedFacetFieldString, !selectedFacetFieldString.isEmpty {
            let valuesArray = selectedFacetFieldString.components(separatedBy: facetViewModel.stringConcatenator)

            for value in valuesArray {
                let localizedValue = NSLocalizedString(value, comment: "")
                if let object = facetFieldOptions.enumerated().first(where: {NSLocalizedString($0.element.label ?? "", comment: "") == localizedValue}) {
                    self.facetViewModel.selectedFacetField.append(object.element)
                }
            }
        }
    }
    
    func updatedSelectedValuesForFacetIntervals() {
        
        let facetIntervalOptions = facetViewModel.facetIntervalOptions
        if let selectedFacetIntervalString = facetViewModel.selectedFacetIntervalString, !selectedFacetIntervalString.isEmpty {
            let valuesArray = selectedFacetIntervalString.components(separatedBy: facetViewModel.stringConcatenator)

            for value in valuesArray {
                let localizedValue = NSLocalizedString(value, comment: "")
                if let object = facetIntervalOptions.enumerated().first(where: {NSLocalizedString($0.element.label ?? "", comment: "") == localizedValue}) {
                    self.facetViewModel.selectedFacetInterval.append(object.element)
                }
            }
        }
    }
}

// MARK: Facet Query
extension SearchFacetListComponentController {
   
    private func updateSelectedValueForFacetQueries(for index: Int) {
        let value = facetViewModel.facetQueryOptions[index].label ?? ""
        if let object = facetViewModel.selectedFacetQuery.enumerated().first(where: {$0.element.label == value}) {
            facetViewModel.selectedFacetQuery.remove(at: object.offset)
        } else {
            facetViewModel.selectedFacetQuery.append(facetViewModel.facetQueryOptions[index])
        }
        buildViewModelForFacetQueries()
    }
    
    func applyFilterForFacetQuery() {
        var selectedValue = ""
        let selectedFacetQuery = facetViewModel.selectedFacetQuery
        for counter in 0 ..< selectedFacetQuery.count {
            let item = selectedFacetQuery[counter]
            let label = item.label ?? ""
            let name = NSLocalizedString(label, comment: "")
            
            if counter != 0 {
                selectedValue.append(facetViewModel.stringConcatenator)
            }
            selectedValue.append(name)
        }
        facetViewModel.selectedFacetQueryString = selectedValue
        facetViewModel.queryBuilder = facetViewModel.buildQueryForFacetQueries()
    }
    
    func resetFilterForFacetQuery() {
        facetViewModel.selectedFacetQuery = []
        facetViewModel.selectedFacetQueryString = ""
        facetViewModel.queryBuilder = facetViewModel.buildQueryForFacetQueries()
    }
}

// MARK: Facet Fields
extension SearchFacetListComponentController {
   
    private func updateSelectedValueForFacetFields(for index: Int) {
        let value = facetViewModel.facetFieldOptions[index].label ?? ""
        if let object = facetViewModel.selectedFacetField.enumerated().first(where: {$0.element.label == value}) {
            facetViewModel.selectedFacetField.remove(at: object.offset)
        } else {
            facetViewModel.selectedFacetField.append(facetViewModel.facetFieldOptions[index])
        }
        buildViewModelForFacetFields()
    }
    
    func applyFilterForFacetFields() {
        var selectedValue = ""
        let selectedFacetField = facetViewModel.selectedFacetField
        for counter in 0 ..< selectedFacetField.count {
            let item = selectedFacetField[counter]
            let label = item.label ?? ""
            let name = NSLocalizedString(label, comment: "")
            
            if counter != 0 {
                selectedValue.append(facetViewModel.stringConcatenator)
            }
            selectedValue.append(name)
        }
        facetViewModel.selectedFacetFieldString = selectedValue
        facetViewModel.queryBuilder = facetViewModel.buildQueryForFacetFields()
    }
    
    func resetFilterForFacetFields() {
        facetViewModel.selectedFacetField = []
        facetViewModel.selectedFacetFieldString = ""
        facetViewModel.queryBuilder = facetViewModel.buildQueryForFacetFields()
    }
}

// MARK: Facet Intervals
extension SearchFacetListComponentController {
   
    private func updateSelectedValueForFacetIntervals(for index: Int) {
        let value = facetViewModel.facetIntervalOptions[index].label ?? ""
        if let object = facetViewModel.selectedFacetInterval.enumerated().first(where: {$0.element.label == value}) {
            facetViewModel.selectedFacetInterval.remove(at: object.offset)
        } else {
            facetViewModel.selectedFacetInterval.append(facetViewModel.facetIntervalOptions[index])
        }
        buildViewModelForFacetIntervals()
    }
    
    func applyFilterForFacetIntervals() {
        var selectedValue = ""
        let selectedFacetInterval = facetViewModel.selectedFacetInterval
        for counter in 0 ..< selectedFacetInterval.count {
            let item = selectedFacetInterval[counter]
            let label = item.label ?? ""
            let name = NSLocalizedString(label, comment: "")
            
            if counter != 0 {
                selectedValue.append(facetViewModel.stringConcatenator)
            }
            selectedValue.append(name)
        }
        facetViewModel.selectedFacetIntervalString = selectedValue
        facetViewModel.queryBuilder = facetViewModel.buildQueryForFacetIntervals()
    }
    
    func resetFilterForFacetIntervals() {
        facetViewModel.selectedFacetInterval = []
        facetViewModel.selectedFacetIntervalString = ""
        facetViewModel.queryBuilder = facetViewModel.buildQueryForFacetIntervals()
    }
}
