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

class ResultsViewModel {
    weak var delegate: ListComponentPaginationDelegate?

    private var shouldDisplayNextPageLoadingIndicator: Bool = true
    private var results: [ListNode] = [] {
        willSet {
            shouldDisplayNextPageLoadingIndicator = true
        }
    }

    func updateResults(results: [ListNode]?, pagination: Pagination?, error: Error?) {
        if let results = results {
            if results.count > 0 {
                if pagination?.skipCount != 0 {
                    addNewResults(results: results, pagination: pagination)
                } else {
                    addResults(results: results, pagination: pagination)
                }
            } else if pagination?.skipCount == 0 {
                self.results = []
            }
        } else {
            if error == nil {
                self.results = []
            }
        }

        delegate?.didUpdateList(error: error, pagination: pagination)
    }

    func addNewResults(results: [ListNode]?, pagination: Pagination?) {
        guard let results = results else { return }
        if results.count != 0 {
            let olderElementsSet = Set(self.results)
            let newElementsSet = Set(results)

            if !newElementsSet.isSubset(of: olderElementsSet) {
                self.results.append(contentsOf: results)
            }

            if let pagination = pagination {
                shouldDisplayNextPageLoadingIndicator = (Int64(self.results.count) == pagination.totalItems) ? false : true
            }
        }
    }

    func addResults(results: [ListNode]?, pagination: Pagination?) {
        guard let results = results else { return }
        if results.count != 0 {
            self.results = results

            shouldDisplayNextPageLoadingIndicator = (Int64(results.count) == pagination?.totalItems) ? false : true
        }
    }

    func clearResults() {
        results = []
    }
}

// MARK: - SearchViewModelDelegate

extension ResultsViewModel: SearchViewModelDelegate {
    func handle(results: [ListNode]?, pagination: Pagination?, error: Error?) {
        updateResults(results: results, pagination: pagination, error: error)
    }
}

// MARK: - ListCcomponentDataSourceProtocol
extension ResultsViewModel: ListComponentDataSourceProtocol {
    func isEmpty() -> Bool {
        return results.isEmpty
    }

    func shouldDisplaySections() -> Bool {
        return false
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfItems(in section: Int) -> Int {
        return results.count
    }

    func listNode(for indexPath: IndexPath) -> ListNode {
        return results[indexPath.row]
    }

    func titleForSectionHeader(at indexPath: IndexPath) -> String {
        return ""
    }

    func shouldDisplayListLoadingIndicator() -> Bool {
        return self.shouldDisplayNextPageLoadingIndicator
    }

    func refreshList() {
        // TODO: request refresh
    }
}
