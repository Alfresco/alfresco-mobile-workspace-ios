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
import AlfrescoContent

class WorkflowTaskStatusViewModel: NSObject {
    let isLoading = Observable<Bool>(false)
    var services: CoordinatorServices?
    var taskId: String?
    var workflowStatus: String?
    var comment: String?
    var workflowStatusOptions = [Option]()
    var selectedWorkflowStatusOption: RadioListOptions?
    var isAllowedToEditStatus = false
    var statusTitle: String? {
        if let name = selectedWorkflowStatusOption?.name {
            return name
        } else if !workflowStatusOptions.isEmpty {
            if let index = workflowStatusOptions.firstIndex(where: {$0.id == "empty"}) {
                return workflowStatusOptions[index].name
            }
        }
        return nil
    }
    
    var didSaveStatusAndComment: ((_ status: Option?, _ comment: String?) -> Void)?
    
    func getStatusOptions() -> [RadioListOptions] {
        var arrayOptions = [RadioListOptions]()
        for option in workflowStatusOptions where option.id != "empty" {
            let listOption = RadioListOptions(optionId: option.id, name: option.name)
            arrayOptions.append(listOption)
        }
        return arrayOptions
    }
    
}
