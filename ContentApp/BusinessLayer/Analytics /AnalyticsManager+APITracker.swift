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

// MARK: - API Tracker Events
extension AnalyticsManager {
    
    func apiTracker(name: String?, fileSize: Double = 0, success: Bool, outcome: String = "") {
        if let name = name {
            let eventName =  name + (success ? "_success" : "_fail")
            var parameters = self.commonParameters()
            if fileSize > 0 {
                let size = "\(fileSize) MB"
                parameters[AnalyticsConstants.Parameters.fileSize] = size
            }
            if !outcome.isEmpty {
                parameters[AnalyticsConstants.Parameters.actionOutcome] = outcome
            }
            parameters[AnalyticsConstants.Parameters.previewSuccess] = success
            parameters[AnalyticsConstants.Parameters.eventName] = eventName
            self.logEvent(name: eventName, parameters: parameters)
        }
    }
}
