//
// Copyright (C) 2005-2023 Alfresco Software Limited.
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

import UIKit
import AlfrescoAuth
import AlfrescoContent

class APSService {
    static var repository = ApplicationBootstrap.shared().repository
    static var accountService = repository.service(of: AccountService.identifier) as? AccountService
    
    static var isAPSServiceEnable: Bool? {
        get {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.isAPSEnabled)"
            return UserDefaultsModel.value(for: key) as? Bool ?? false
        }
        set {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.isAPSEnabled)"
            UserDefaultsModel.set(value: newValue ?? false, for: key)
        }
    }
    
    static func checkIfAPSServiceEnabled() {
        accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            ProcessAPI.checkIfAPSIsEnabled { data, error in
                if error == nil {
                    DispatchQueue.main.async {
                        APSService.isAPSServiceEnable = true
                    }
                } else {
                    DispatchQueue.main.async {
                        APSService.isAPSServiceEnable = false
                    }
                }
            }
        })
    }
}
