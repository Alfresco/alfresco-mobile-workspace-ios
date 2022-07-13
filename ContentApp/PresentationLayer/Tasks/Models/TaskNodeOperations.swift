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

class TaskNodeOperations: NSObject {
    
    static func processNodes(for tasks: [Task]) -> [TaskNode] {
        var nodes: [TaskNode] = []
        for task in tasks {
            
            let assignee = TaskNodeAssignee(id: task.assignee?.id ?? -1,
                                            firstName: task.assignee?.firstName,
                                            lastName: task.assignee?.lastName,
                                            email: task.assignee?.email)
            let node = TaskNode(guid: "",
                                id: task.id,
                                title: "",
                                name: task.name,
                                description: task.description,
                                category: task.category,
                                assignee: assignee,
                                created: task.created,
                                dueDate: task.dueDate,
                                endDate: task.endDate,
                                duration: task.duration,
                                priority: task.priority,
                                parentTaskId: task.parentTaskId,
                                parentTaskName: task.parentTaskName,
                                processInstanceId: task.processInstanceId,
                                processInstanceName: task.processInstanceName,
                                processDefinitionId: task.processDefinitionId,
                                processDefinitionName: task.processDefinitionName,
                                processDefinitionDescription: task.processDefinitionDescription,
                                processDefinitionKey: task.processDefinitionKey,
                                processDefinitionCategory: task.processDefinitionCategory,
                                processDefinitionVersion: task.processDefinitionVersion,
                                processDefinitionDeploymentId: task.processDefinitionDeploymentId,
                                formKey: task.formKey,
                                processInstanceStartUserId: task.processInstanceStartUserId,
                                initiatorCanCompleteTask: task.initiatorCanCompleteTask,
                                deactivateUserTaskReassignment: task.deactivateUserTaskReassignment,
                                adhocTaskCanBeReassigned: task.adhocTaskCanBeReassigned,
                                taskDefinitionKey: task.taskDefinitionKey,
                                executionId: task.executionId,
                                memberOfCandidateGroup: task.memberOfCandidateGroup,
                                memberOfCandidateUsers: task.memberOfCandidateUsers,
                                managerOfCandidateGroup: task.managerOfCandidateGroup)
            nodes.append(node)
        }
        return nodes
    }
}
