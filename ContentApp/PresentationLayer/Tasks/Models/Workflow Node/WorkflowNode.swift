//
// Copyright (C) 2005-2023 Alfresco Software Limited.
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

import AlfrescoContent

struct WorkflowNode {
    var processID: String?
    var name: String?
    var businessKey: String?
    var processDefinitionId: String?
    var tenantId: String?
    var started: Date?
    var ended: Date?
    var startedBy: ProcessNodeAssignee?
    var processDefinitionName: String?
    var processDefinitionDescription: String?
    var processDefinitionKey: String?
    var processDefinitionCategory: String?
    var processDefinitionVersion: Int?
    var processDefinitionDeploymentId: String?
    var graphicalNotationDefined: Bool?
    var startFormDefined: Bool?
    var suspended: Bool?
    
    enum CodingKeys: String, CodingKey {
        case processID = "id"
        case name, businessKey, processDefinitionId, tenantId, started, ended
        case startedBy, processDefinitionName, processDefinitionDescription
        case processDefinitionKey, processDefinitionCategory, processDefinitionVersion, processDefinitionDeploymentId, graphicalNotationDefined, startFormDefined
        case suspended
    }
    
    init(processID: String?,
         name: String?,
         businessKey: String?,
         processDefinitionId: String?,
         tenantId: String?,
         started: Date?,
         ended: Date?,
         startedBy: ProcessNodeAssignee?,
         processDefinitionName: String?,
         processDefinitionDescription: String?,
         processDefinitionKey: String?,
         processDefinitionCategory: String?,
         processDefinitionVersion: Int?,
         processDefinitionDeploymentId: String?,
         graphicalNotationDefined: Bool?,
         startFormDefined: Bool?,
         suspended: Bool?) {
        
        self.processID = processID
        self.name = name
        self.businessKey = businessKey
        self.processDefinitionId = processDefinitionId
        self.tenantId = tenantId
        self.started = started
        self.ended = ended
        self.startedBy = startedBy
        self.processDefinitionName = processDefinitionName
        self.processDefinitionDescription = processDefinitionDescription
        self.processDefinitionKey = processDefinitionKey
        self.processDefinitionCategory = processDefinitionCategory
        self.processDefinitionVersion = processDefinitionVersion
        self.processDefinitionDeploymentId = processDefinitionDeploymentId
        self.graphicalNotationDefined = graphicalNotationDefined
        self.startFormDefined = startFormDefined
        self.suspended = suspended
    }
}

// MARK: Task Assignee
struct ProcessNodeAssignee: Codable {
    var assigneeID: Int?
    var firstName: String?
    var lastName: String?
    var email: String?
    var userName: String?

    enum CodingKeys: String, CodingKey {
        case assigneeID = "id"
        case firstName, lastName, email
    }
    
    init(assigneeID: Int, firstName: String?, lastName: String?, email: String?) {
        self.assigneeID = assigneeID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.userName = String(format: "%@ %@", firstName ?? "", lastName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
