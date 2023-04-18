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

struct WFlowAppDefinitions {
    var addDefinitionID: Int?
    var defaultAppId: String?
    var name: String?
    var description: String?
    var modelId: Int?
    var theme: String?
    var icon: String?
    var deploymentId: String?
    var tenantId: Int?
    
    enum CodingKeys: String, CodingKey {
        case addDefinitionID = "id"
        case defaultAppId, name, description, modelId, theme
        case icon, deploymentId, tenantId
    }
    
    init(addDefinitionID: Int?,
         defaultAppId: String?,
         name: String?,
         description: String?,
         modelId: Int?,
         theme: String?,
         icon: String?,
         deploymentId: String?,
         tenantId: Int?) {
        
        self.addDefinitionID = addDefinitionID
        self.defaultAppId = defaultAppId
        self.name = name
        self.description = description
        self.modelId = modelId
        self.theme = theme
        self.icon = icon
        self.deploymentId = deploymentId
        self.tenantId = tenantId
    }
}
