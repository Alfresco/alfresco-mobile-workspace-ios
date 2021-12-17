//
// Copyright (C) 2005-2020 Alfresco Software Limited.
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

enum SearchType {
    case live
    case simple
}

protocol SearchModelProtocol: ListComponentModelProtocol, EventObservable {
    var searchChips: [SearchChipItem] { get set }
    var searchString: String? { get set }
    var facetFields: FacetFields? { get set }
    var facetQueries: FacetQueries? { get set }
    var facetIntervals: FacetIntervals? { get set }
    var searchType: SearchType { get set }
    var selectedSearchFilter: AdvanceSearchFilters? { get set } // selected search filter
    
    func isNodePathEnabled() -> Bool
    func defaultSearchChips(for configurations: [AdvanceSearchFilters], and index: Int) -> [SearchChipItem]
    func facetSearchChips(for searchFacets: [SearchFacets]) -> [SearchChipItem]

    func searchChipIndexes(for tappedChip: SearchChipItem) -> [Int]
    func performSearch(for string: String,
                       with facetFields: FacetFields?,
                       facetQueries: FacetQueries?,
                       facetIntervals: FacetIntervals?,
                       paginationRequest: RequestPagination?,
                       completionHandler: SearchCompletionHandler)
    func performLiveSearch(for string: String,
                           with facetFields: FacetFields?,
                           facetQueries: FacetQueries?,
                           facetIntervals: FacetIntervals?,
                           paginationRequest: RequestPagination?,
                           completionHandler: SearchCompletionHandler)
    
    func getAdvanceSearchConfigurationFromServer(callback completion: ((_ configuration: SearchConfigModel?, _ data: Data?) -> Void)?)
}
