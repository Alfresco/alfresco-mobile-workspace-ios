//
// Copyright (C) 2005-2022 Alfresco Software Limited.
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

class ShareViewModel: NSObject {
    var browseType: BrowseType = .personalFiles
    var repository: ServiceRepository {
        return ApplicationBootstrap.shared().repository
    }
    var accountService: AccountService? {
        let identifier = AccountService.identifier
        return repository.service(of: identifier) as? AccountService
    }
    var themingService: MaterialDesignThemingService? {
        let identifier = MaterialDesignThemingService.identifier
        return repository.service(of: identifier) as? MaterialDesignThemingService
    }
    var activeTheme: PresentationTheme?

    var activeAccount: AccountProtocol? {
        didSet {
            if let activeAccountIdentifier = activeAccount?.identifier {
                UserDefaultsModel.set(value: activeAccountIdentifier, for: KeyConstants.Save.activeAccountIdentifier)
            } else {
                UserDefaultsModel.remove(forKey: KeyConstants.Save.activeAccountIdentifier)
            }
        }
    }
}
