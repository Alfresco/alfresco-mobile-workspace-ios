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

import UIKit

struct WFlowProcessDefinitions {
    var processId: String?
    var name: String?
    var description: String?
    var key: String?
    var category: String?
    var version: Int?
    var deploymentId: String?
    var tenantId: String?
    var hasStartForm: Bool?
    
    enum CodingKeys: String, CodingKey {
        case processId = "id"
        case name, description, key, category, version
        case deploymentId, tenantId, hasStartForm
    }
    
    init(processId: String?,
         name: String?,
         description: String?,
         key: String?,
         category: String?,
         version: Int?,
         deploymentId: String?,
         tenantId: String?,
         hasStartForm: Bool?) {
        
        self.processId = processId
        self.name = name
        self.description = description
        self.key = key
        self.category = category
        self.version = version
        self.deploymentId = deploymentId
        self.tenantId = tenantId
        self.hasStartForm = hasStartForm
    }
}
