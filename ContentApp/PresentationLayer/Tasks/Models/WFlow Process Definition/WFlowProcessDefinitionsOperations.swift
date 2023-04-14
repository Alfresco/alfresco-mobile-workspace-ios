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

class WFlowProcessDefinitionsOperations: NSObject {
    
    static func processNodes(for processDefinitions: [ProcessDefinitionDetail]) -> WFlowProcessDefinitions? {
        
        if !processDefinitions.isEmpty, let processDefinition = processDefinitions.first {
            return WFlowProcessDefinitions(processId: processDefinition.id,
                                           name: processDefinition.name,
                                           description: processDefinition.description,
                                           key: processDefinition.key,
                                           category: processDefinition.category,
                                           version: processDefinition.version,
                                           deploymentId: processDefinition.deploymentId,
                                           tenantId: processDefinition.tenantId,
                                           hasStartForm: processDefinition.hasStartForm)
        }
        return nil
    }
}
