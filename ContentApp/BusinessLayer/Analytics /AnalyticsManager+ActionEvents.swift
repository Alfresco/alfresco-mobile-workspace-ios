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
        parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.filePreview.rawValue
        self.logEvent(name: Event.Action.filePreview.rawValue, parameters: parameters)
    }

    func fileActionEvent(for node: ListNode?, action: ActionMenu) {
        if let mappedEvent = mapWithAnalyticAction(event: action.analyticEventName) {
            let fileExtension = node?.title.split(separator: ".").last
            let mimeType = node?.mimeType ?? ""
            var parameters = self.commonParameters()
            parameters[AnalyticsConstants.Parameters.fileMimetype] = mimeType
            parameters[AnalyticsConstants.Parameters.fileExtension] = fileExtension ?? ""
            parameters[AnalyticsConstants.Parameters.eventName] = mappedEvent.rawValue
            self.logEvent(name: mappedEvent.rawValue, parameters: parameters)
        }
    }
    
    func mapWithAnalyticAction(event: String) -> Event.Action? {
        let eventActionName = Event.Action.allCases.first(where: {"\($0)" == event})
        return eventActionName
    }
    
    func theme(name: String) {
        var parameters = self.commonParameters()
        parameters[AnalyticsConstants.Parameters.theme] = name
        parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.changeTheme.rawValue
        self.logEvent(name: Event.Action.changeTheme.rawValue, parameters: parameters)
    }
    
    func appLaunched() {
        var parameters = self.commonParameters()
        parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.appLaunched.rawValue
        self.logEvent(name: Event.Action.appLaunched.rawValue, parameters: parameters)
    }
    
    func searchFacets(name: String?) {
        var parameters = self.commonParameters()
        parameters[AnalyticsConstants.Parameters.facet] = name ?? ""
        parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.searchFacets.rawValue
        self.logEvent(name: Event.Action.searchFacets.rawValue, parameters: parameters)
    }
    
    func discardCaptures(count: Int) {
        var parameters = self.commonParameters()
        parameters[AnalyticsConstants.Parameters.assetsCount] = count
        parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.discardCaptures.rawValue
        self.logEvent(name: Event.Action.discardCaptures.rawValue, parameters: parameters)
    }
    
    func taskFilters(name: String?) {
        if let componentValue = name, let mappedEvent = mapWithAnalyticAction(event: componentValue) {
            var parameters = self.commonParameters()
            parameters[AnalyticsConstants.Parameters.eventName] = mappedEvent.rawValue
            self.logEvent(name: mappedEvent.rawValue, parameters: parameters)
        }
    }
    
    func didTapTaskCompleteAlert() {
        var parameters = self.commonParameters()
        parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.taskComplete.rawValue
        self.logEvent(name: Event.Action.taskComplete.rawValue, parameters: parameters)
    }
    
    func didTapCreateTask() {
        var parameters = self.commonParameters()
        parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.createTask.rawValue
        self.logEvent(name: Event.Action.createTask.rawValue, parameters: parameters)
    }
    
    func didUpdateTaskDetails() {
        var parameters = self.commonParameters()
        parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.updateTask.rawValue
        self.logEvent(name: Event.Action.updateTask.rawValue, parameters: parameters)
    }
    
    func didTapDeleteTaskAttachment(isWorkflow: Bool = false) {
        var parameters = self.commonParameters()
        if isWorkflow {
            parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.deleteWorkflowAttachment.rawValue
            self.logEvent(name: Event.Action.deleteWorkflowAttachment.rawValue, parameters: parameters)
        } else {
            parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.deleteTaskAttachment.rawValue
            self.logEvent(name: Event.Action.deleteTaskAttachment.rawValue, parameters: parameters)
        }
    }
    
    func didTapEditTask() {
        var parameters = self.commonParameters()
        parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.editTask.rawValue
        self.logEvent(name: Event.Action.editTask.rawValue, parameters: parameters)
    }
    
    func didTapDoneTask() {
        var parameters = self.commonParameters()
        parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.doneTask.rawValue
        self.logEvent(name: Event.Action.doneTask.rawValue, parameters: parameters)
    }
    
    func didTapUploadTaskAttachment(isWorkflow: Bool = false) {
        var parameters = self.commonParameters()
        if isWorkflow {
            parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.uploadWorkflowAttachment.rawValue
            self.logEvent(name: Event.Action.uploadWorkflowAttachment.rawValue, parameters: parameters)
        } else {
            parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.uploadTaskAttachment.rawValue
            self.logEvent(name: Event.Action.uploadTaskAttachment.rawValue, parameters: parameters)
        }
    }
    
    func takePhotoforTasks(isWorkflow: Bool = false) {
        var parameters = self.commonParameters()
        if isWorkflow {
            parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.workflowTakePhoto.rawValue
            self.logEvent(name: Event.Action.workflowTakePhoto.rawValue, parameters: parameters)
        } else {
            parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.taskTakePhoto.rawValue
            self.logEvent(name: Event.Action.taskTakePhoto.rawValue, parameters: parameters)
        }
    }
    
    func uploadPhotoforTasks(isWorkflow: Bool = false) {
        var parameters = self.commonParameters()
        if isWorkflow {
            parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.workflowUploadPhoto.rawValue
            self.logEvent(name: Event.Action.workflowUploadPhoto.rawValue, parameters: parameters)
        } else {
            parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.taskUploadPhoto.rawValue
            self.logEvent(name: Event.Action.taskUploadPhoto.rawValue, parameters: parameters)
        }
    }
    
    func uploadFilesforTasks(isWorkflow: Bool = false) {
        var parameters = self.commonParameters()
        if isWorkflow {
            parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.workflowUploadFile.rawValue
            self.logEvent(name: Event.Action.workflowUploadFile.rawValue, parameters: parameters)
        } else {
            parameters[AnalyticsConstants.Parameters.eventName] = Event.Action.taskUploadFile.rawValue
            self.logEvent(name: Event.Action.taskUploadFile.rawValue, parameters: parameters)
        }
    }
}
