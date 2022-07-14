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
import AlfrescoContent

class TaskNode {
    var guid = ""
    var taskID: String?
    var title = ""
    var name: String?
    var description: String?
    var category: String?
    var assignee: TaskNodeAssignee?
    var created: Date?
    var dueDate: Date?
    var endDate: Date?
    var duration: String?
    var priority: Int?
    var parentTaskId: Int?
    var parentTaskName: String?
    var processInstanceId: String?
    var processInstanceName: String?
    var processDefinitionId: String?
    var processDefinitionName: String?
    var processDefinitionDescription: String?
    var processDefinitionKey: String?
    var processDefinitionCategory: String?
    var processDefinitionVersion: Int?
    var processDefinitionDeploymentId: String?
    var formKey: String?
    var processInstanceStartUserId: String?
    var initiatorCanCompleteTask: Bool?
    var deactivateUserTaskReassignment: Bool?
    var adhocTaskCanBeReassigned: Bool?
    var taskDefinitionKey: String?
    var executionId: String?
    var memberOfCandidateGroup: Bool?
    var memberOfCandidateUsers: Bool?
    var managerOfCandidateGroup: Bool?
    
    enum CodingKeys: String, CodingKey {
        case taskID = "id"
        case guid, title, name, description, category, assignee
        case created, dueDate, endDate
        case duration, priority, parentTaskId, parentTaskName, processInstanceId, processInstanceName
        case processDefinitionId, processDefinitionName, processDefinitionDescription, processDefinitionKey
        case processDefinitionCategory, processDefinitionVersion, processDefinitionDeploymentId
        case formKey, processInstanceStartUserId, initiatorCanCompleteTask, deactivateUserTaskReassignment
        case adhocTaskCanBeReassigned, taskDefinitionKey, executionId
        case memberOfCandidateGroup, memberOfCandidateUsers, managerOfCandidateGroup
    }
    
    init(guid: String,
         taskID: String? = nil,
         title: String,
         name: String? = nil,
         description: String? = nil,
         category: String? = nil,
         assignee: TaskNodeAssignee? = nil,
         created: Date? = nil,
         dueDate: Date? = nil,
         endDate: Date? = nil,
         duration: String? = nil,
         priority: Int? = nil,
         parentTaskId: Int? = nil,
         parentTaskName: String? = nil,
         processInstanceId: String? = nil,
         processInstanceName: String? = nil,
         processDefinitionId: String? = nil,
         processDefinitionName: String? = nil,
         processDefinitionDescription: String? = nil,
         processDefinitionKey: String? = nil,
         processDefinitionCategory: String? = nil,
         processDefinitionVersion: Int? = nil,
         processDefinitionDeploymentId: String? = nil,
         formKey: String? = nil,
         processInstanceStartUserId: String? = nil,
         initiatorCanCompleteTask: Bool? = nil,
         deactivateUserTaskReassignment: Bool? = nil,
         adhocTaskCanBeReassigned: Bool? = nil,
         taskDefinitionKey: String? = nil,
         executionId: String? = nil,
         memberOfCandidateGroup: Bool? = nil,
         memberOfCandidateUsers: Bool? = nil,
         managerOfCandidateGroup: Bool? = nil) {
        
        self.guid = guid
        self.taskID = taskID
        self.title = title
        self.name = name
        self.description = description
        self.category = category
        self.assignee = assignee
        self.created = created
        self.dueDate = dueDate
        self.endDate = endDate
        self.duration = duration
        self.priority = priority
        self.parentTaskId = parentTaskId
        self.parentTaskName = parentTaskName
        self.processInstanceId = processInstanceId
        self.processInstanceName = processInstanceName
        self.processDefinitionId = processDefinitionId
        self.processDefinitionName = processDefinitionName
        self.processDefinitionDescription = processDefinitionDescription
        self.processDefinitionKey = processDefinitionKey
        self.processDefinitionCategory = processDefinitionCategory
        self.processDefinitionVersion = processDefinitionVersion
        self.processDefinitionDeploymentId = processDefinitionDeploymentId
        self.formKey = formKey
        self.processInstanceStartUserId = processInstanceStartUserId
        self.initiatorCanCompleteTask = initiatorCanCompleteTask
        self.deactivateUserTaskReassignment = deactivateUserTaskReassignment
        self.adhocTaskCanBeReassigned = adhocTaskCanBeReassigned
        self.taskDefinitionKey = taskDefinitionKey
        self.executionId = executionId
        self.memberOfCandidateGroup = memberOfCandidateGroup
        self.memberOfCandidateUsers = memberOfCandidateUsers
        self.managerOfCandidateGroup = managerOfCandidateGroup
    }
}

// MARK: Task Assignee
class TaskNodeAssignee: Codable {
    var assigneeID: Int
    var firstName: String?
    var lastName: String?
    var email: String?
    
    enum CodingKeys: String, CodingKey {
        case assigneeID = "id"
        case firstName, lastName, email
    }
    
    init(assigneeID: Int, firstName: String?, lastName: String?, email: String?) {
        self.assigneeID = assigneeID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}
