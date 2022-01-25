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
import UIKit

class SearchFacetListComponentViewModel {
    var searchFacets: SearchFacets?
    var searchFacetOptions = [Buckets]()
    var tempSearchFacetOptions = [Buckets]()
    var selectedSearchFacet = [Buckets]()
    var selectedSearchFacetString: String?

    let rowViewModels = Observable<[RowViewModel]>([])
    let stringConcatenator = ", "
    let searchOperator = "OR"
    var queryBuilder: String?
    let minimumItemsInListToShowSearchBar = 10

    var title: String {
        let name = NSLocalizedString(searchFacets?.label ?? "", comment: "")
        return name
    }
        
    func saveTemporaryDataForSearchResults() {
        searchFacetOptions = searchFacets?.buckets ?? []
        tempSearchFacetOptions = searchFacetOptions
    }
    
    // MARK: Search Bar
    func isShowSearchBar() -> Bool {
        return (searchFacetOptions.count > minimumItemsInListToShowSearchBar) ? true : false
    }
    
    func heightAndAlphaOfSearchView() -> (height: CGFloat, alpha: CGFloat) {
        if isShowSearchBar() {
            return (55.0, 1.0)
        } else {
            return (0.0, 0.0)
        }
    }
}

// MARK: Facet Field
extension SearchFacetListComponentViewModel {
    
    func buildQueryForSearchFacets() -> String? {
        var queryString = ""
        for counter in 0 ..< selectedSearchFacet.count {
            let value = selectedSearchFacet[counter].filterQuery ?? ""
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
