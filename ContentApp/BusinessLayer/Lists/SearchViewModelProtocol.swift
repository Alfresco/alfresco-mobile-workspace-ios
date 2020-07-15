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
import AlfrescoContentServices

protocol SearchViewModelProtocol {
    var viewModelDelegate: SearchViewModelDelegate? { get set }
    var searchChips: [SearchChipItem] { get set }

    func performSearch(for string: String?)
    func performLiveSearch(for string: String?)
    func save(recentSearch string: String?)
    func recentSearches() -> [String]
}

protocol SearchViewModelDelegate: class {
    /**
     Handle search results
     - results: list of nodes from a search operation
     - Note: If the list  is empty,  a view with empty list will appear.  If the list is a nil object then recent searches will appear
     */
    func handle(results: [ListNode]?)
}
