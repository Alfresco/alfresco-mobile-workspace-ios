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

class WorkflowListViewModel: NSObject {
    
    let isLoading = Observable<Bool>(true)
    var size = 0
    var total = 0
    var page = 0
    var requestInProgress = false
    var shouldRefreshList = true
    var rawWorkflows: [WorkflowNode] = []
    var services: CoordinatorServices
    var isTasksConfigured = false
    let filters = WorkflowFilters.getWorkflowFilters()
    var selectedFilter = WorkflowFilters.defaultFilter()

    init(services: CoordinatorServices) {
        self.services = services
    }
    
    func isEmpty() -> Bool {
        return rawWorkflows.isEmpty
    }
    
    func numberOfItems(in section: Int) -> Int {
        return rawWorkflows.count
    }

    func listNodes() -> [WorkflowNode] {
        return rawWorkflows
    }

    func listNode(for indexPath: IndexPath) -> WorkflowNode? {
        if !rawWorkflows.isEmpty && rawWorkflows.count > indexPath.row {
            return rawWorkflows[indexPath.row]
        }
        return nil
    }
    
    func titleForSectionHeader(at indexPath: IndexPath) -> String {
        return ""
    }
    
    func shouldDisplaTaskListLoadingIndicator() -> Bool {
        if total > rawWorkflows.count {
            return true
        }
        return false
    }
    
    func shouldAllowToFetchNewTasks() -> Bool {
        if total > rawWorkflows.count || rawWorkflows.isEmpty || total == 0 && requestInProgress == false {
            return true
        }
        return false
    }
    
    func emptyList() -> EmptyListProtocol {
        return EmptyWorkflows()
    }
    
    func tasksNotConfigured() -> EmptyListProtocol {
        return WorkflowsNotConfigured()
    }
    
    var localizedFilterNames: [String] {
        return filters.map({$0.localizedName ?? ""})
    }
    
    // MARK: - Workflows List
    
    func workflowList(completionHandler: @escaping (_ workflows: [WorkflowNode], _ error: Error?) -> Void) {
        
        if shouldAllowToFetchNewTasks() {
            self.isLoading.value = true
            requestInProgress = true
            services.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
                AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
                
                let params = ProcessListParams(state: self.selectedFilter.state, page: self.page)
                ProcessAPI.getProcessList(params: params) {[weak self] data, error in
                    guard let sSelf = self else { return }
                    sSelf.isLoading.value = false
                    if data != nil {
                        let processes = data?.data ?? []
                        let processNodes = WorkflowNodeOperations.processNodes(for: processes)
                        if sSelf.shouldRefreshList {
                            sSelf.rawWorkflows.removeAll()
                        }
                        sSelf.shouldRefreshList = false
                        sSelf.rawWorkflows.append(contentsOf: processNodes)
                        sSelf.size = data?.size ?? 0
                        sSelf.total = data?.total ?? 0
                        sSelf.page = sSelf.total > sSelf.size ? sSelf.page + 1 : sSelf.page
                        sSelf.requestInProgress = false
                        completionHandler(processNodes, nil)
                    } else {
                        completionHandler([], error)
                    }
                }
            })
        }
    }
}
