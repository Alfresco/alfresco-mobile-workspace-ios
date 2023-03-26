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

class WorkflowNodeOperations: NSObject {
    
    static func processNodes(for processes: [Process]) -> [WorkflowNode] {
        var nodes: [WorkflowNode] = []
        for process in processes {
            
            let assignee = WorkflowNodeOperations.processWorkflowNodeAssignee(for: process.startedBy)
           
            let node = WorkflowNode(processID: process.id,
                                    name: process.name,
                                    businessKey: process.businessKey,
                                    processDefinitionId: process.processDefinitionId,
                                    tenantId: process.tenantId,
                                    started: process.started,
                                    ended: process.ended,
                                    startedBy: assignee,
                                    processDefinitionName: process.processDefinitionName,
                                    processDefinitionDescription: process.processDefinitionDescription,
                                    processDefinitionKey: process.processDefinitionKey,
                                    processDefinitionCategory: process.processDefinitionCategory,
                                    processDefinitionVersion: process.processDefinitionVersion,
                                    processDefinitionDeploymentId: process.processDefinitionDeploymentId,
                                    graphicalNotationDefined: process.graphicalNotationDefined,
                                    startFormDefined: process.startFormDefined,
                                    suspended: process.suspended)
            nodes.append(node)
        }
        return nodes
    }
    
    static func processWorkflowNodeAssignee(for assignee: ProcessUser?) -> ProcessNodeAssignee? {
        if let assignee = assignee {
            return ProcessNodeAssignee(assigneeID: assignee.id ?? -1,
                                                   firstName: assignee.firstName,
                                                   lastName: assignee.lastName,
                                                   email: assignee.email)
        }
        return nil
    }
}
