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

class TaskAssigneeViewModel: NSObject {
    var services: CoordinatorServices?
    var isSearchByName = true
    let rowViewModels = Observable<[RowViewModel]>([])
    let isLoading = Observable<Bool>(false)
    var minimumCharactersToSearch = 1
    var searchTimer: Timer?
    var searchText: String?
    var users = Observable<[TaskNodeAssignee]>([])
    var isWorkflowSearch = false

    var searchByNameImage: UIImage? {
        if isSearchByName {
            return UIImage(named: "ic-radio-checked")
        } else {
            return UIImage(named: "ic-radio-unchecked")
        }
    }
    
    var searchByEmailImage: UIImage? {
        if isSearchByName {
            return UIImage(named: "ic-radio-unchecked")
        } else {
            return UIImage(named: "ic-radio-checked")
        }
    }
    
    var heightOfRadioButtonsView: CGFloat {
        if isWorkflowSearch {
            return 0
        } else {
            return 60.0
        }
    }
    
    var isHideRadioButtonView: Bool {
        if isWorkflowSearch {
            return true
        } else {
            return false
        }
    }
    
    var placeholder: String {
        if isWorkflowSearch {
            if isSearchByName {
                return LocalizationConstants.Workflows.placeholderSearchUser
            } else {
                return LocalizationConstants.Workflows.placeholderSearchGroup
            }
        } else {
            return LocalizationConstants.EditTask.searchPlaceholder
        }
    }
    
    // MARK: - GET Search user
    func searchUser(with filter: String?, email: String?, completionHandler: @escaping (_ assignee: [TaskNodeAssignee], _ error: Error?) -> Void) {
        guard services?.connectivityService?.hasInternetConnection() == true else { return }
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            TasksAPI.searchUser(filter: filter, email: email) { data, error in
                
                let assignee = self.processData(data: data, error).assignee
                let error = self.processData(data: data, error).error
                completionHandler(assignee, error)
                self.isLoading.value = false
            }
        })
    }
    
    // MARK: - GET Search Group
    func searchGroup(with filter: String?, completionHandler: @escaping (_ assignee: [TaskNodeAssignee], _ error: Error?) -> Void) {
        guard services?.connectivityService?.hasInternetConnection() == true else { return }
        self.isLoading.value = true
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            ProcessAPI.searchGroup(filter: filter) { data, error in
                
                let assignee = self.processData(data: data, error).assignee
                let error = self.processData(data: data, error).error
                completionHandler(assignee, error)
                self.isLoading.value = false
            }
        })
    }
    
    private func processData(data: TaskAssigneeUserList?, _ error: Error?) -> (assignee: [TaskNodeAssignee], error: Error?) {
        if data != nil {
            AnalyticsManager.shared.apiTracker(name: Event.API.apiSearchUser.rawValue, fileSize: 0, success: true)
            if let taskAssignee = data?.data {
                let assignee = TaskNodeOperations.processTaskAssignee(for: taskAssignee)
                return(assignee, nil)
            } else {
                return([], nil)
            }
        } else {
            AnalyticsManager.shared.apiTracker(name: Event.API.apiSearchUser.rawValue, fileSize: 0, success: false)
            return([], nil)
        }
    }
}
