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
import AlfrescoContent


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
    
    func isAdvanceSearchConfigAllowedFromServer() -> Bool {
        let apiInterval = ConfigurationManager.shared.getAdvanceSearchAPIInterval()
        if UserDefaults.standard.bool(forKey: KeyConstants.AdvanceSearch.fetchConfigurationFromServer) == true || self.isTimeExceedsForAdvanceSearchConfig(apiInterval: apiInterval) {
            self.updateSearchConfigurationKeys()
            return true
        }
        return false
    }
    
    func isTimeExceedsForAdvanceSearchConfig(apiInterval: Int) -> Bool {
        let hours = lastAPICallDifferenceInHours()
        if hours >= apiInterval {
            return true
        }
        return false
    }
    
    func updateSearchConfigurationKeys() {
        UserDefaults.standard.set(false, forKey: KeyConstants.AdvanceSearch.fetchConfigurationFromServer)
        UserDefaults.standard.set(Date().currentTimeMillis(), forKey: KeyConstants.AdvanceSearch.lastAPICallTime)
        UserDefaults.standard.synchronize()
    }
    
    private func lastAPICallDifferenceInHours() -> Int {
        let lastAPITime = UserDefaults.standard.value(forKey: KeyConstants.AdvanceSearch.lastAPICallTime)
        let currentTime = Date().currentTimeMillis()
        let time1 = Date(timeIntervalSince1970: lastAPITime as? TimeInterval ?? 0)
        let time2 = Date(timeIntervalSince1970: TimeInterval(currentTime))
        let difference = Calendar.current.dateComponents([.second], from: time1, to: time2)
        let duration = (difference.second ?? 0).msToSeconds
        let hours = duration.secondsToHours
        return hours
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
        self.loadConfigurationFromServer()
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
                let decoded = try JSONDecoder().decode(AlfrescoContent.SearchConfigModel.self, from: json)
                self.searchConfigurations.value = decoded.search
            } catch {
                AlfrescoLog.error(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Load configuration from server and store locally
    func loadConfigurationFromServer() {
        if self.isAdvanceSearchConfigAllowedFromServer() {
            self.searchModel.getAdvanceSearchConfigurationFromServer { (configuration, data)  in
                guard let configuration = configuration else { return }
                self.saveConfiguartionLocally(for: data)
                self.searchConfigurations.value = configuration.search
            }
        }
    }
    
    private func saveConfiguartionLocally(for data: Data?) {
        let repository = ApplicationBootstrap.shared().repository
        let accountService = repository.service(of: AccountService.identifier) as? AccountService
        guard let accountIdentifier = accountService?.activeAccount?.identifier else { return }
        DiskService.saveAdvanceSearchConfigurations(for: accountIdentifier, and: data)
    }
}

