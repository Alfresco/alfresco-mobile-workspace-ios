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

import XCTest
@testable import ContentApp
@testable import AlfrescoContent

class TestTaskDetailViewModel: XCTestCase {
    lazy var viewModel = TaskPropertiesViewModel()
    var task: TaskNode?

    // MARK: - load tasks from bundle
    func loadTasksFromAppBundle(_ completionHandler: @escaping (_ task: TaskNode?) -> Void) {
        if let fileUrl = Bundle.main.url(forResource: KeyConstants.Tasks.mockTasks, withExtension: KeyConstants.Tasks.configFileExtension) {
            do {
                let data = try Data(contentsOf: fileUrl, options: [])
                parseAppConfiguration(for: data) { isDone in
                    completionHandler(isDone)
                }
            } catch let error {
                AlfrescoLog.error(error.localizedDescription)
            }
        }
    }
    
    private func parseAppConfiguration(for data: Data?, _ completionHandler: @escaping (_ task: TaskNode?) -> Void) {
        if let json = data {
            do {
                let decoded = try JSONDecoder().decode(Task.self, from: json)
                let taskNodes = TaskNodeOperations.processNodes(for: [decoded])
                if !taskNodes.isEmpty {
                    self.task = taskNodes.first
                    completionHandler(self.task)
                }
            } catch {
                AlfrescoLog.error(error)
            }
        }
    }
    
    func testTaskDetailViewModel_WhenValidDueDateProvided_ShouldReturnDate() {
        self.loadTasksFromAppBundle { task in
            
        }
    }
}
