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

class WorkflowViewModel: NSObject {
    var workflow: WorkflowNode?
    var workflowName: String? {
        return workflow?.name
    }
    
    var userName: String? {
        let apsUserID = UserProfile.apsUserID
        if apsUserID == assigneeUserId {
            return LocalizationConstants.EditTask.meTitle
        } else {
            return workflow?.startedBy?.userName
        }
    }
    
    var assigneeUserId: Int {
        return workflow?.startedBy?.assigneeID ?? -1
    }
    
    var started: Date? {
        return workflow?.started
    }
    
    func getCreatedDate(for date: Date?) -> String? {
        if let createdDate = date?.dateString(format: "dd MMM yyyy hh:mm:ss a") {
            return createdDate
        } else {
            return nil
        }
    }
}
