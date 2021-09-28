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

class SearchViewModel: ListComponentViewModel {
    var searchModel: SearchModelProtocol
    let searchConfigurations = Observable<[AdvanceSearchConfigurations]>([])

    init(model: SearchModelProtocol) {
        searchModel = model
        super.init(model: model)
    }

    override func emptyList() -> EmptyListProtocol {
        return EmptySearch()
    }

    func shouldDisplaySearchBar() -> Bool {
        return true
    }

    func shouldDisplaySearchButton() -> Bool {
        return true
    }
}

// MARK: - Advance Search
extension SearchViewModel {
    func loadAppConfigurationsForSearch() {
        let repository = ApplicationBootstrap.shared().repository
        let accountService = repository.service(of: AccountService.identifier) as? AccountService
        guard let accountIdentifier = accountService?.activeAccount?.identifier else { return }
        if let data = DiskService.getAdvanceSearchConfigurations(for: accountIdentifier) {
            // fetch configuration from local file stored in document directory
            parseAppConfiguration(for: data)
        } else {
            // load data from bundle
            loadConfigurationsFromAppBundle()
        }
    }
    
    private func loadConfigurationsFromAppBundle() {
        if let fileUrl = Bundle.main.url(forResource: "advance-search-config", withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileUrl, options: [])
                parseAppConfiguration(for: data)
            } catch let error {
                AlfrescoLog.error(error.localizedDescription)
            }
        }
    }
    
    private func parseAppConfiguration(for data: Data?) {
        if let json = data {
            do {
                let decoded = try JSONDecoder().decode(SearchConfigModel.self, from: json)
                self.searchConfigurations.value = decoded.search
            } catch {
                AlfrescoLog.error(error.localizedDescription)
            }
        }
    }
}

