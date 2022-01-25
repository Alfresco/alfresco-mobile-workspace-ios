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
        var optionsArray = [RowViewModel]()
        let searchFacetOptions = facetViewModel.searchFacetOptions
        for (index, item) in searchFacetOptions.enumerated() {
            let label = item.label ?? ""
            let name = NSLocalizedString(label, comment: "")
            let count = item.count ?? "0"
            let title = String(format: "%@ (%@)", name, count)
            var isSelected = false
            if facetViewModel.selectedSearchFacet.firstIndex(where: {$0.label == label}) != nil {
                isSelected = true
            }
            let rowVM = ListItemCellViewModel(title: title, isRadioList: false, isSelected: isSelected)
            rowVM.didSelectListItem = {
                self.updateSelectedValue(for: index)
            }
            optionsArray.append(rowVM)
        }
        
        facetViewModel.rowViewModels.value = optionsArray
    }
    
    // MARK: - Update Selected Values
    func updatedSelectedValues() {
        let searchFacetOptions = facetViewModel.searchFacetOptions
        if let selectedSearchFacetString = facetViewModel.selectedSearchFacetString, !selectedSearchFacetString.isEmpty {
            let valuesArray = selectedSearchFacetString.components(separatedBy: facetViewModel.stringConcatenator)

            for value in valuesArray {
                let localizedValue = NSLocalizedString(value, comment: "")
                if let index = searchFacetOptions.firstIndex(where: {NSLocalizedString($0.label ?? "", comment: "") == localizedValue}) {
                    self.facetViewModel.selectedSearchFacet.append(searchFacetOptions[index])
                }
            }
        }
    }
}

// MARK: Facet Fields
extension SearchFacetListComponentController {

    private func updateSelectedValue(for index: Int) {
        let value = facetViewModel.searchFacetOptions[index].label ?? ""
        if let facetIndex = facetViewModel.selectedSearchFacet.firstIndex(where: {$0.label == value}) {
            facetViewModel.selectedSearchFacet.remove(at: facetIndex)
        } else {
            facetViewModel.selectedSearchFacet.append(facetViewModel.searchFacetOptions[index])
        }
        buildViewModel()
    }
    
    func applyFilter() {
        var selectedValue = ""
        let selectedSearchFacet = facetViewModel.selectedSearchFacet
        for counter in 0 ..< selectedSearchFacet.count {
            let item = selectedSearchFacet[counter]
            let name = NSLocalizedString(item.label ?? "", comment: "")
            if counter != 0 {
                selectedValue.append(facetViewModel.stringConcatenator)
            }
            selectedValue.append(name)
        }
        facetViewModel.selectedSearchFacetString = selectedValue
        facetViewModel.queryBuilder = facetViewModel.buildQueryForSearchFacets()
    }
    
    func resetFilter() {
        facetViewModel.selectedSearchFacet = []
        facetViewModel.selectedSearchFacetString = ""
        facetViewModel.queryBuilder = facetViewModel.buildQueryForSearchFacets()
    }
}
