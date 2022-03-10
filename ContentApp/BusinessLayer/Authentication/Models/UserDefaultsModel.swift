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

class UserDefaultsModel: NSObject {

    static func getUserDefault() -> UserDefaults? {
        let userDefaults = UserDefaults(suiteName: KeyConstants.AppGroup.name)
        return userDefaults
    }
    
    static func set(value: Any, for key: String) {
        let userDefaults = UserDefaultsModel.getUserDefault()
        userDefaults?.set(value, forKey: key)
        userDefaults?.synchronize()
    }
    
    static func value(for key: String) -> Any? {
        let userDefaults = UserDefaultsModel.getUserDefault()
        let value = userDefaults?.value(forKey: key)
        if let returnValue = value {
            return returnValue
        } else if let oldValue = UserDefaults.standard.value(forKey: key) {
            UserDefaultsModel.set(value: oldValue, for: key)
            return oldValue
        }
        return nil
    }
    
    static func remove(forKey: String) {
        let defaults = UserDefaultsModel.getUserDefault()
        defaults?.removeObject(forKey: forKey)
        defaults?.synchronize()
        UserDefaults.standard.removeObject(forKey: forKey)
        UserDefaults.standard.synchronize()
    }
}
