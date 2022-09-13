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

    static var firstName: String {
        get {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.displayFirstName)"
            return UserDefaultsModel.value(for: key) as? String ?? ""
        }
        set {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.displayFirstName)"
            UserDefaultsModel.set(value: newValue, for: key)
        }
    }

    static var lastName: String {
        get {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.displayLastName)"
            return UserDefaultsModel.value(for: key) as? String ?? ""
        }
        set {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.displayLastName)"
            UserDefaultsModel.set(value: newValue, for: key)
        }
    }
    
    static var displayName: String {
        get {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.displayProfileName)"
            return UserDefaultsModel.value(for: key) as? String ?? ""
        }
        set {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.displayProfileName)"
            UserDefaultsModel.set(value: newValue, for: key)
        }
    }

    static var email: String {
        get {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.emailProfile)"
            return UserDefaultsModel.value(for: key) as? String ?? ""
        }
        set {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.emailProfile)"
            UserDefaultsModel.set(value: newValue, for: key)
        }
    }

    static var personalFilesID: String? {
        get {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.personalFilesID)"
            return UserDefaultsModel.value(for: key) as? String ?? ""
        }
        set {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.personalFilesID)"
            UserDefaultsModel.set(value: newValue ?? "", for: key)
        }
    }

    static var allowSyncOverCellularData: Bool {
        get {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.allowSyncOverCellularData)"
            return UserDefaultsModel.value(for: key) as? Bool ?? false
        }
        set {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.allowSyncOverCellularData)"
            UserDefaultsModel.set(value: newValue, for: key)
        }
    }

    static var allowOnceSyncOverCellularData: Bool {
        get {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.allowOnceSyncOverCellularData)"
            return UserDefaultsModel.value(for: key) as? Bool ?? false
        }
        set {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.allowOnceSyncOverCellularData)"
            UserDefaultsModel.set(value: newValue, for: key)
        }
    }

    // MARK: - Persist Data

    static func persistUserProfile(person: Person) {
        let firstName = person.firstName
        let lastName = person.lastName ?? ""
        var profileName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
        if let displayName = person.displayName {
            profileName = displayName
        }
        
        UserProfile.firstName = firstName
        UserProfile.lastName = lastName
        UserProfile.displayName = profileName
        UserProfile.email = person.email
    }
    
    static var apsUserID: Int? {
        get {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.apsUserId)"
            return UserDefaultsModel.value(for: key) as? Int ?? -1
        }
        set {
            let identifier = accountService?.activeAccount?.identifier ?? ""
            let key = "\(identifier)-\(KeyConstants.Save.apsUserId)"
            UserDefaultsModel.set(value: newValue ?? -1, for: key)
        }
    }

    // MARK: - Remove Data

    static func removeUserProfile(forAccountIdentifier identifier: String) {
        UserDefaultsModel.remove(forKey: "\(identifier)-\(KeyConstants.Save.displayFirstName)")
        UserDefaultsModel.remove(forKey: "\(identifier)-\(KeyConstants.Save.displayLastName)")
        UserDefaultsModel.remove(forKey: "\(identifier)-\(KeyConstants.Save.displayProfileName)")
        UserDefaultsModel.remove(forKey: "\(identifier)-\(KeyConstants.Save.emailProfile)")
        UserDefaultsModel.remove(forKey: "\(identifier)-\(KeyConstants.Save.personalFilesID)")
        UserDefaultsModel.remove(forKey: "\(identifier)-\(KeyConstants.Save.allowSyncOverCellularData)")
        UserDefaultsModel.remove(forKey: "\(identifier)-\(KeyConstants.Save.allowOnceSyncOverCellularData)")
        
        UserDefaultsModel.remove(forKey: KeyConstants.Save.displayFirstName)
        UserDefaultsModel.remove(forKey: KeyConstants.Save.displayLastName)
        UserDefaultsModel.remove(forKey: "\(identifier)-\(KeyConstants.Save.apsUserId)")
    }
}
