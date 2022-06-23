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

// MARK: - Screen View Events
extension AnalyticsManager {
    
    func previewFile(fileMimetype: String?, fileExtension: Any?, success: Bool) {
        var parameters = self.commonParameters()
        parameters[AnalyticsConstants.Parameters.fileMimetype] = fileMimetype ?? ""
        parameters[AnalyticsConstants.Parameters.fileExtension] = fileExtension ?? ""
        parameters[AnalyticsConstants.Parameters.previewSuccess] = success
        parameters[AnalyticsConstants.Parameters.eventName] = EventName.filePreview.rawValue
        self.logEvent(type: .screenView, parameters: parameters)
    }
    
    func fileActionEvent(for node: ListNode?, eventName: EventName) {
        let fileExtension = node?.title.split(separator: ".").last
        let mimeType = node?.mimeType ?? ""
        var parameters = self.commonParameters()
      
        parameters[AnalyticsConstants.Parameters.fileMimetype] = mimeType
        parameters[AnalyticsConstants.Parameters.fileExtension] = fileExtension ?? ""
        parameters[AnalyticsConstants.Parameters.eventName] = eventName.rawValue
        self.logEvent(type: .screenView, parameters: parameters)
    }

    func theme(name: String) {
        var parameters = self.commonParameters()
        parameters[AnalyticsConstants.Parameters.theme] = name
        parameters[AnalyticsConstants.Parameters.eventName] = EventName.themeUpdated.rawValue
        self.logEvent(type: .screenView, parameters: parameters)
    }
    
    func appLaunched() {
        var parameters = self.commonParameters()
        parameters[AnalyticsConstants.Parameters.eventName] = EventName.appLaunched.rawValue
        self.logEvent(type: .screenView, parameters: parameters)
    }
    
    func searchFacets(name: String?) {
        var parameters = self.commonParameters()
        parameters[AnalyticsConstants.Parameters.facet] = name ?? ""
        parameters[AnalyticsConstants.Parameters.eventName] = EventName.searchFacets.rawValue
        self.logEvent(type: .screenView, parameters: parameters)
    }
    
    func discardCaptures(count: Int) {
        var parameters = self.commonParameters()
        parameters[AnalyticsConstants.Parameters.assetsCount] = count
        parameters[AnalyticsConstants.Parameters.eventName] = EventName.discardCaptures.rawValue
        self.logEvent(type: .screenView, parameters: parameters)
    }
    
    func scanDocuments() {
        var parameters = self.commonParameters()
        parameters[AnalyticsConstants.Parameters.eventName] = EventName.scanDocuments.rawValue
        self.logEvent(type: .screenView, parameters: parameters)
    }
}
