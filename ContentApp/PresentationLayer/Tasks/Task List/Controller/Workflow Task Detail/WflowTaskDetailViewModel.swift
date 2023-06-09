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

import Foundation
import AlfrescoContent

class WflowTaskDetailViewModel: NSObject {
    var services: CoordinatorServices?
    let isLoading = Observable<Bool>(true)
    let rowViewModels = Observable<[RowViewModel]>([])
    var viewAllAttachmentsAction: (() -> Void)?
    var task: TaskNode?
    var didRefreshWorkflowList: (() -> Void)?
    var attachments = Observable<[ListNode]>([])
    var didSelectTaskAttachment: ((ListNode) -> Void)?
    
    var taskId: String {
        return task?.taskID ?? ""
    }
    var processDetails: StartFormFields?
    var formFields = [Field]()
    
    // MARK: - Workflow Task details

    func workflowTaskDetails(completionHandler: @escaping (_ error: Error?) -> Void) {
        guard services?.connectivityService?.hasInternetConnection() == true else { return }
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            TasksAPI.getTaskForm(taskId: self.taskId) {[weak self] data, fields, error in
                guard let sSelf = self else { return }
                sSelf.isLoading.value = false

                if data != nil {
                    sSelf.processDetails = data
                    sSelf.formFields = fields
                    completionHandler(nil)
                } else {
                    completionHandler(error)
                }
            }
        })
    }
}
