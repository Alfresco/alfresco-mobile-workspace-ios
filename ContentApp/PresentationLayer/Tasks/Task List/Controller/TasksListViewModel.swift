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

class TasksListViewModel: NSObject {
    let isLoading = Observable<Bool>(true)
    var size = 0
    var total = 0
    var page = 0
    var requestInProgress = false
    var shouldRefreshList = true
    var rawTasks: [TaskNode] = []
    var services: CoordinatorServices
    
    init(services: CoordinatorServices) {
        self.services = services
    }
    
    func isEmpty() -> Bool {
        return rawTasks.isEmpty
    }
    
    func numberOfItems(in section: Int) -> Int {
        return rawTasks.count
    }

    func listNodes() -> [TaskNode] {
        return rawTasks
    }

    func listNode(for indexPath: IndexPath) -> TaskNode? {
        if !rawTasks.isEmpty && rawTasks.count > indexPath.row {
            return rawTasks[indexPath.row]
        }
        return nil
    }
    
    func titleForSectionHeader(at indexPath: IndexPath) -> String {
        return ""
    }
    
    func shouldDisplaTaskListLoadingIndicator() -> Bool {
        if total > rawTasks.count {
            return true
        }
        return false
    }
    
    func shouldAllowToFetchNewTasks() -> Bool {
        if total > rawTasks.count || rawTasks.isEmpty || total == 0 && requestInProgress == false {
            return true
        }
        return false
    }
    
    func emptyList() -> EmptyListProtocol {
        return EmptyTasks()
    }
    
    func tasksNotConfigured() -> EmptyListProtocol {
        return TasksNotConfigured()
    }

    // MARK: - Task List
    
    func taskList(with params: TaskListParams, completionHandler: @escaping (_ taskNodes: [TaskNode], _ error: Error?) -> Void) {
        
        if shouldAllowToFetchNewTasks() {
            self.isLoading.value = true
            requestInProgress = true
            services.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
                AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
                
                TasksAPI.getTasksList(params: params) {[weak self] data, error in
                    guard let sSelf = self else { return }
                    sSelf.isLoading.value = false
                    if data != nil {
                        let task = data?.data ?? []
                        let taskNodes = TaskNodeOperations.processNodes(for: task)
                        if sSelf.shouldRefreshList {
                            sSelf.rawTasks.removeAll()
                        }
                        sSelf.shouldRefreshList = false
                        sSelf.rawTasks.append(contentsOf: taskNodes)
                        sSelf.size = data?.size ?? 0
                        sSelf.total = data?.total ?? 0
                        sSelf.page = sSelf.total > sSelf.size ? sSelf.page + 1 : sSelf.page
                        sSelf.requestInProgress = false
                        completionHandler(taskNodes, nil)
                    } else {
                        completionHandler([], error)
                    }
                }
            })
        }
    }
}
