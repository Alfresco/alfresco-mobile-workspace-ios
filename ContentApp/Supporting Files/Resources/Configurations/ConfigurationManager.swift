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

class ConfigurationManager: NSObject {
    public static let shared = ConfigurationManager()
    
    func isPaidUser() -> Bool {
        if let accountService = ApplicationBootstrap.shared().repository.service(of: AccountService.identifier) as? AccountService, let serverEdition = accountService.serverEdition {
            return serverEdition == PersonNetwork.SubscriptionLevel.enterprise.rawValue
        }
        return false
    }

    private func loadConfigurations() -> NSDictionary? {
        if let configFile = Bundle.main.path(forResource: "Configurations", ofType: "plist") {
            return NSDictionary(contentsOfFile: configFile)!
        } else {
            return nil
        }
    }
    
    func getAdvanceSearchAPIInterval() -> Int {
        if let configurations = ConfigurationManager.shared.loadConfigurations() {
            let advanceSearchAPIIntervalInHours = configurations[ConfigurationKeys.advanceSearchAPIIntervalInHours] as? String ?? "0"
            return Int(advanceSearchAPIIntervalInHours) ?? 0
        } else {
            return 0
        }
    }
}
