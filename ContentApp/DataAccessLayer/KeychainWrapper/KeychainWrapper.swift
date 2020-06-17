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

class Keychain {

    public static let standard = Keychain()

    // MARK: - Public methods

    func set(value: Data, forKey key: String) -> Bool {
        let dictionary = self.accessDictionary(for: key)
        dictionary.setObject(value, forKey: String(kSecValueData) as NSCopying)
        dictionary.setObject(kSecAttrAccessibleWhenUnlocked, forKey: String(kSecAttrAccessible) as NSCopying)
        let status = SecItemAdd(dictionary, nil)
        switch status {
        case errSecSuccess:
            AlfrescoLog.info("Added value to Keychain for identifier: \(key)")
            return true
        case errSecDuplicateItem:
            return self.update(value: value, forKey: key)
        default:
            AlfrescoLog.error("Cannot add value to Keychain for identifier: \(key)")
            return false
        }
    }

    func set(value: String, forKey key: String) -> Bool {
        if let data = value.data(using: String.Encoding.utf8) {
            return self.set(value: data, forKey: key)
        }
        return false
    }

    func update(value: Data, forKey key: String) -> Bool {
        let dictionary = self.accessDictionary(for: key)
        let updateDictionary = NSMutableDictionary()
        updateDictionary.setObject(value, forKey: String(kSecValueData) as NSCopying)
        let status = SecItemUpdate(dictionary, updateDictionary)
        switch status {
        case errSecSuccess:
            AlfrescoLog.info("Updated value to Keychain for identifier: \(key)")
            return true
        default:
            AlfrescoLog.error("Cannot update value to Keychain for identifier: \(key)")
            return false
        }
    }

    func update(value: String, forKey key: String) -> Bool {
        if let data = value.data(using: String.Encoding.utf8) {
            return self.update(value: data, forKey: key)
        }
        return false
    }

    func data(forKey key: String) -> Data? {
        return self.searchMatching(identifier: key)
    }

    func string(forKey key: String) -> String? {
        if let data = self.searchMatching(identifier: key) {
            return String(decoding: data, as: UTF8.self)
        }
        return nil
    }

    func delete(forKey key: String) {
        let dictionary = self.accessDictionary(for: key)
        _ = SecItemDelete(dictionary)
        AlfrescoLog.info("Deleted value to Keychain for identifier: \(key)")
    }

    // MARK: - Private utils

    private func accessDictionary(for identifier: String) -> NSMutableDictionary {
        let searchDictionary = NSMutableDictionary()
        searchDictionary.setObject(kSecClassGenericPassword, forKey: String(kSecClass) as NSCopying)
        searchDictionary.setObject(Bundle.main.infoDictionary?["CFBundleIdentifier"] ?? "", forKey: String(kSecAttrService) as NSCopying)
        if let encodedIdentifier = identifier.data(using: String.Encoding.utf8) {
            searchDictionary.setObject(encodedIdentifier, forKey: String(kSecAttrGeneric) as NSCopying)
            searchDictionary.setObject(encodedIdentifier, forKey: String(kSecAttrAccount) as NSCopying)
        }
        return searchDictionary
    }

    private func searchMatching(identifier: String) -> Data? {
        let dictionary = self.accessDictionary(for: identifier)
        dictionary.setObject(kSecMatchLimitOne, forKey: String(kSecMatchLimit) as NSCopying)
        dictionary.setObject(kCFBooleanTrue ?? true, forKey: String(kSecReturnData) as NSCopying)
        var foundObject: AnyObject?
        let status = SecItemCopyMatching(dictionary, &foundObject)
        switch status {
        case noErr:
            return foundObject as? Data
        default:
            return nil
        }
    }
}
