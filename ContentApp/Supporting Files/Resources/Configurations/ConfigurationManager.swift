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

class ConfigurationManager: NSObject {
    public static let shared = ConfigurationManager()

    private func loadConfigurations() -> NSDictionary? {
        let bundle = Bundle(for: type(of: self))
        if let configFile = bundle.path(forResource: "Configurations", ofType: "plist") {
            let configurationDictionary = NSDictionary(contentsOfFile: configFile)!
            return configurationDictionary
        }
        return nil
    }
    
    func isEnterpriseUser() -> Bool {
        if let configuartions = self.loadConfigurations() {
            return configuartions[ConfigurationKeys.isEnterpriseUser] as? Bool ?? false
        }
        return false
    }
    
    func isMultipleVideosCapturedAllowed() -> Bool {
        if let configuartions = self.loadConfigurations() {
            return configuartions[ConfigurationKeys.isMultipleVideosCapturedAllowed] as? Bool ?? false
        }
        return false
    }
    
    func isSimultaneousImageAndVideoCapturedAllowed() -> Bool {
        if let configuartions = self.loadConfigurations() {
            return configuartions[ConfigurationKeys.isSimultaneousImageAndVideoCapturedAllowed] as? Bool ?? false
        }
        return false
    }
}
