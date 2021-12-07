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

class SearchFacetListComponentViewModel {
    var facetQueryOptions = [SearchFacetQueries]()
    var selectedFacetQuery = [SearchFacetQueries]()
    var selectedFacetQueryString: String?

    var facetFieldOptions: SearchFacetFields?
    var selectedFacetField = [SearchFacetFields]()

    var facetIntervalsOptions: SearchFacetIntervals?
    var selectedFacetInterval = [SearchFacetIntervals]()

    let rowViewModels = Observable<[RowViewModel]>([])
    var componentType: ComponentType = .facetQuery

    let stringConcatenator = ", "
    let searchOperator = "OR"
    var queryBuilder: String?

    var title: String {
        if componentType == .facetQuery {
            return NSLocalizedString("size-facet-queries", comment: "")
        } else if componentType == .facetField {
            let name = facetFieldOptions?.label ?? ""
            return NSLocalizedString(name, comment: "")
        } else if componentType == .facetInterval {
            let name = facetIntervalsOptions?.label ?? ""
            return NSLocalizedString(name, comment: "")
        }
        return ""
    }
}

// MARK: Facet Query
extension SearchFacetListComponentViewModel {
    
    func buildQueryForFacetQueries() -> String? {
        var queryString = ""
        for counter in 0 ..< selectedFacetQuery.count {
            let value = selectedFacetQuery[counter].filterQuery ?? ""
            if !value.isEmpty {
                if counter != 0 {
                    queryString.append(" " + searchOperator + " ")
                }
                queryString.append(value)
            }
        }
        return queryString
    }
}
