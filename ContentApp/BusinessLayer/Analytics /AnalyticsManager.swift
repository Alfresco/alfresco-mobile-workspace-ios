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
import Firebase

class AnalyticsManager: NSObject {
    public static let shared = AnalyticsManager()

    private func serverURL() -> String? {
        return AuthenticationParameters.parameters().fullHostnameURL
    }
    
    private func deviceName() -> String? {
        return UIDevice.current.name
    }
    
    private func deviceOS() -> String? {
        return UIDevice.current.systemVersion
    }
    
    private func deviceNetwork() -> String? {
        let connectivityService = ConnectivityService()
        return connectivityService.status.description
    }
    
    private func appVersion() -> String? {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return appVersion
    }
    
    private func deviceId() -> String? {
        return UIDevice.current.identifierForVendor!.uuidString
    }

    func commonParameters() -> Dictionary<String, Any> {
        let dictionary = [
            AnalyticsConstants.CommonParameters.serverURL: AnalyticsManager.shared.serverURL() ?? "",
            AnalyticsConstants.CommonParameters.deviceName: AnalyticsManager.shared.deviceName() ?? "",
            AnalyticsConstants.CommonParameters.deviceOS: AnalyticsManager.shared.deviceOS() ?? "",
            AnalyticsConstants.CommonParameters.deviceNetwork: AnalyticsManager.shared.deviceNetwork() ?? "",
            AnalyticsConstants.CommonParameters.appVersion: AnalyticsManager.shared.appVersion() ?? "",
            AnalyticsConstants.CommonParameters.deviceID: AnalyticsManager.shared.deviceId() ?? ""
        ]
        return dictionary
    }
    
    func logEvent(type: EventType, parameters: [String: Any]) {
        Analytics.logEvent(type.rawValue, parameters: parameters)
    }
}
