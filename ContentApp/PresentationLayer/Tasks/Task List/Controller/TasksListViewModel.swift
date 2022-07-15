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
    var groupedTasks: [TaskNode] = []
    var rawTasks: [TaskNode] = [] {
        didSet {
            createSectionArray(rawTasks)
        }
    }
    var services: CoordinatorServices
    init(services: CoordinatorServices) {
        self.services = services
    }
    
    func isEmpty() -> Bool {
        return rawTasks.isEmpty
    }
    
    func numberOfItems(in section: Int) -> Int {
        return groupedTasks.count
    }

    func listNodes() -> [TaskNode] {
        return groupedTasks
    }

    func listNode(for indexPath: IndexPath) -> TaskNode? {
        if !groupedTasks.isEmpty && groupedTasks.count > indexPath.row {
            return groupedTasks[indexPath.row]
        }
        return nil
    }
    
    func titleForSectionHeader(at indexPath: IndexPath) -> String {
        if let listNode = self.listNode(for: indexPath) {
            if listNode.guid == listNodeSectionIdentifier {
                return listNode.title
            }
        }
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
                
                TasksAPI.getTasksList(params: params) { data, error in
                    self.isLoading.value = false
                    if data != nil {
                        let task = data?.data ?? []
                        let taskNodes = TaskNodeOperations.processNodes(for: task)
                        if self.shouldRefreshList {
                            self.rawTasks.removeAll()
                        }
                        self.shouldRefreshList = false
                        self.rawTasks.append(contentsOf: taskNodes)
                        self.size = data?.size ?? 0
                        self.total = data?.total ?? 0
                        self.updatePageNumber()
                        self.requestInProgress = false
                        completionHandler(taskNodes, nil)
                    } else {
                        completionHandler([], error)
                    }
                }
            })
        }
    }
        
    func updatePageNumber() {
        if total > size {
            page = page + 1
        }
    }
    
    private func createSectionArray(_ results: [TaskNode]) {
        groupedTasks = []
        for element in results {
            if let date = element.created {
                var groupType: GroupedListType = .today
                if date.isInToday {
                    groupType = .today
                } else if date.isInYesterday {
                    groupType = .yesterday
                } else if date.isInThisWeek {
                    groupType = .thisWeek
                } else if date.isInLastWeek {
                    groupType = .lastWeek
                } else {
                    groupType = .older
                }
                add(element: element, type: groupType)
            } else {
                add(element: element, type: .today)
            }
        }
    }
    
    private func add(element: TaskNode, type: GroupedListType) {
        let section = GroupedList(type: type)
        var newGroupList = true
        for element in groupedTasks {
            if element.guid == listNodeSectionIdentifier &&
                element.title == section.titleGroup {
                newGroupList = false
            }
        }

        if newGroupList {
            let sectionNode = TaskNode(guid: listNodeSectionIdentifier, title: section.titleGroup)
            groupedTasks.append(sectionNode)
        }
        groupedTasks.append(element)
    }
}
