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

class UserProfile {
    static var repository = ApplicationBootstrap.shared().repository
    static var accountService = repository.service(of: AccountService.identifier) as? AccountService

    static var displayName: String {
        get {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.displayProfileName)"
            return UserDefaults.standard.object(forKey: key) as? String ?? ""
        }
        set {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.displayProfileName)"
            UserDefaults.standard.set(newValue, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }

    static var email: String {
        get {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.emailProfile)"
            return UserDefaults.standard.object(forKey: key) as? String ?? ""
        }
        set {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.emailProfile)"
            UserDefaults.standard.set(newValue, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }

    static var personalFilesID: String? {
        get {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.personalFilesID)"
            return UserDefaults.standard.object(forKey: key) as? String ?? ""
        }
        set {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.personalFilesID)"
            UserDefaults.standard.set(newValue, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }

    static var allowSyncOverCellularData: Bool {
        get {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.allowSyncOverCellularData)"
            return UserDefaults.standard.object(forKey: key) as? Bool ?? false
        }
        set {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.allowSyncOverCellularData)"
            UserDefaults.standard.set(newValue, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }

    static var allowOnceSyncOverCellularData: Bool {
        get {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.allowOnceSyncOverCellularData)"
            return UserDefaults.standard.object(forKey: key) as? Bool ?? false
        }
        set {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.allowOnceSyncOverCellularData)"
            UserDefaults.standard.set(newValue, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }

    // MARK: - Persist Data

    static func persistUserProfile(person: Person) {
        var profileName = person.firstName
        if let lastName = person.lastName {
            profileName = "\(profileName) \(lastName)"
        }
        if let displayName = person.displayName {
            profileName = displayName
        }
        UserProfile.displayName = profileName
        UserProfile.email = person.email
    }

    // MARK: - Remove Data

    static func removeUserProfile(forAccountIdentifier identifier: String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "\(identifier)-\(KeyConstants.Save.displayProfileName)")
        defaults.removeObject(forKey: "\(identifier)-\(KeyConstants.Save.emailProfile)")
        defaults.removeObject(forKey: "\(identifier)-\(KeyConstants.Save.personalFilesID)")
        defaults.removeObject(forKey: "\(identifier)-\(KeyConstants.Save.allowSyncOverCellularData)")
        defaults.removeObject(forKey: "\(identifier)-\(KeyConstants.Save.allowOnceSyncOverCellularData)")
        defaults.synchronize()
    }
}
