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

    static func set(value: Any, for key: String) {
        let userDefaults = UserDefaults(suiteName: KeyConstants.AppGroup.name)
        userDefaults?.set(value, forKey: key)
        userDefaults?.synchronize()
    }
    
    static func value(for key: String) -> Any? {
        let userDefaults = UserDefaults(suiteName: KeyConstants.AppGroup.name)
        return userDefaults?.value(forKey: key)
    }
    
    static func remove(forKey: String) {
        let defaults = UserDefaults(suiteName: KeyConstants.AppGroup.name)
        defaults?.removeObject(forKey: forKey)
        defaults?.synchronize()
    }
}
