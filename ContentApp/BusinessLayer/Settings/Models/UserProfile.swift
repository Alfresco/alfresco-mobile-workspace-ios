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

    // MARK: - Persist Data

    static func persistUserProfile(person: Person) {
        let identifier = accountService?.activeAccount?.identifier ?? ""
        var profileName = person.firstName
        if let lastName = person.lastName {
            profileName = "\(profileName) \(lastName)"
        }
        if let displayName = person.displayName {
            profileName = displayName
        }

        let defaults = UserDefaults.standard
        defaults.set(profileName, forKey: "\(identifier)-\(kSaveDiplayProfileName)")
        defaults.set(person.email, forKey: "\(identifier)-\(kSaveEmailProfile)")
        defaults.synchronize()
    }

    static func persistPersonalFilesID(nodeID: String) {
        let identifier = accountService?.activeAccount?.identifier ?? ""
        let defaults = UserDefaults.standard
        defaults.set(nodeID, forKey: "\(identifier)-\(kSavePersonalFilesID)")
        defaults.synchronize()
    }

    static func persistOptionToOverrideSyncCellularData(_ option: Bool) {
        let identifier = accountService?.activeAccount?.identifier ?? ""
        let defaults = UserDefaults.standard
        defaults.set(option, forKey: "\(identifier)-\(kSaveOptionToOverrideSyncCellularData)")
        defaults.synchronize()
    }

    static func persistOptionToOverrideSyncOnlyOnceCellularData(_ option: Bool) {
        let identifier = accountService?.activeAccount?.identifier ?? ""
        let defaults = UserDefaults.standard
        defaults.set(option, forKey: "\(identifier)-\(kSaveOptionToOverrideSyncOnlyOnceCellularData)")
        defaults.synchronize()
    }

    // MARK: - Remove Data

    static func removeUserProfile(withAccountIdentifier identifier: String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "\(identifier)-\(kSaveDiplayProfileName)")
        defaults.removeObject(forKey: "\(identifier)-\(kSaveEmailProfile)")
        defaults.removeObject(forKey: "\(identifier)-\(kSavePersonalFilesID)")
        defaults.removeObject(forKey: "\(identifier)-\(kSaveOptionToOverrideSyncCellularData)")
        defaults.removeObject(forKey: "\(identifier)-\(kSaveOptionToOverrideSyncOnlyOnceCellularData)")
    }

    // MARK: - Get Data

    static func getPersonalFilesID() -> String? {
        let identifier = accountService?.activeAccount?.identifier ?? ""
        let key = "\(identifier)-\(kSavePersonalFilesID)"
        return UserDefaults.standard.object(forKey: key) as? String
    }

    static func getProfileName() -> String {
        let identifier = accountService?.activeAccount?.identifier ?? ""
        let key = "\(identifier)-\(kSaveDiplayProfileName)"
        return UserDefaults.standard.object(forKey: key) as? String ?? ""
    }

    static func getEmail() -> String {
        let identifier = accountService?.activeAccount?.identifier ?? ""
        let key = "\(identifier)-\(kSaveEmailProfile)"
        return UserDefaults.standard.object(forKey: key) as? String ?? ""
    }

    static func getOptionToOverrideSyncCellularData() -> Bool {
        let identifier = accountService?.activeAccount?.identifier ?? ""
        let key = "\(identifier)-\(kSaveOptionToOverrideSyncCellularData)"
        return UserDefaults.standard.object(forKey: key) as? Bool ?? false
    }

    static func getOptionToOverrideSyncOnlyOnceCellularData() -> Bool {
        let identifier = accountService?.activeAccount?.identifier ?? ""
        let key = "\(identifier)-\(kSaveOptionToOverrideSyncOnlyOnceCellularData)"
        return UserDefaults.standard.object(forKey: key) as? Bool ?? false
    }
}
