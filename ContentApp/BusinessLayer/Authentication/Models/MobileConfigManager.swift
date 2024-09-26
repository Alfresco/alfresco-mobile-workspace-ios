//
// Copyright (C) 2005-2024 Alfresco Software Limited.
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

  public final class MobileConfigManager {
    
    // Shared instance for singleton pattern
    static let shared = MobileConfigManager()
    
    // Cache to store MobileConfigData after first load
    private var cachedConfigData: MobileConfigData?

    // Private initializer to restrict instantiation
    private init() {}
    
    func fetchMenuOption(accountService: AccountServiceProtocol?) {
        accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            MobileConfigApi.getMobileConfig(appConfig: APIConstants.Path.appConfig) {[weak self] data, error in
                guard let sSelf = self, let configData = data else { return }
                sSelf.saveMobileConfigData(configData)
            }
        })
    }
    
    private func saveMobileConfigData(_ configData: MobileConfigData) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(configData)
            UserDefaultsModel.set(value: data, for: KeyConstants.Save.kConfigData)
        } catch {
            AlfrescoLog.debug("Failed to encode MobileConfigData: \(error)")
        }
    }
    
    // Function to load config data
    func loadMobileConfigData() -> MobileConfigData? {
        // Return cached data if already fetched
        if let cachedData = cachedConfigData {
            return cachedData
        }
        
        // Fetch data from UserDefaults if not cached
        guard let data = UserDefaultsModel.value(for: KeyConstants.Save.kConfigData) as? Data else {
            return nil
        }

        let decoder = JSONDecoder()
        do {
            let configData = try decoder.decode(MobileConfigData.self, from: data)
            cachedConfigData = configData  // Cache the data after fetching it
            return configData
        } catch {
            return nil
        }
    }
    
    // Optional: Invalidate the cache if needed (e.g., after saving new config)
    func invalidateCache() {
        cachedConfigData = nil
    }
}
