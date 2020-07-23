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

protocol ResultsViewModelDelegate: class {
    func didUpdateResultsList(error: Error?, pagination: Pagination?)
}

class ResultsViewModel {
    var results: [ListElementProtocol] = [] {
        willSet {
            shouldDisplayNextPageLoadingIndicator = true
        }
    }
    var shouldDisplayNextPageLoadingIndicator: Bool = true
    weak var delegate: ResultsViewModelDelegate?

    func updateResults(results: [ListElementProtocol]?, pagination: Pagination?, error: Error?) {
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

        delegate?.didUpdateResultsList(error: error, pagination: pagination)
    }

    func addNewResults(results: [ListElementProtocol]?, pagination: Pagination?) {
        guard let results = results else { return }
        if results.count != 0 {
            self.results.append(contentsOf: results)

            if let pagination = pagination {
                shouldDisplayNextPageLoadingIndicator = (Int64(self.results.count) == pagination.totalItems) ? false : true
            }
        }
    }

    func addResults(results: [ListElementProtocol]?, pagination: Pagination?) {
        guard let results = results else { return }
        if results.count != 0 {
            self.results = results

            shouldDisplayNextPageLoadingIndicator = (Int64(results.count) == pagination?.totalItems) ? false : true
        }
    }
}
