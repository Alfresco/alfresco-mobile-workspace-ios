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

class WFlowAppDefinitionOperations: NSObject {
    
    static func processNodes(for appDefinitions: [WorkflowAppDefinitionDetail]) -> [WFlowAppDefinitions] {
        var nodes: [WFlowAppDefinitions] = []
        for appDefinition in appDefinitions {
            let deploymentId = appDefinition.deploymentId ?? ""
            if !deploymentId.isEmpty {
                let node = WFlowAppDefinitions(addDefinitionID: appDefinition.id,
                                               defaultAppId: appDefinition.defaultAppId,
                                               name: appDefinition.name,
                                               description: appDefinition.description,
                                               modelId: appDefinition.modelId,
                                               theme: appDefinition.theme,
                                               icon: appDefinition.icon,
                                               deploymentId: deploymentId,
                                               tenantId: appDefinition.tenantId)
                nodes.append(node)
            }
        }
        return nodes
    }
}
