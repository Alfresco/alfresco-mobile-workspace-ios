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
        
    }
    
    func buildViewModelForFacetIntervals() {
        
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
        
    }
    
    func updatedSelectedValuesForFacetIntervals() {
        
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
