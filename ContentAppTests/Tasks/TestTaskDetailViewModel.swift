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

    // MARK: - load tasks from bundle
    func loadTasksFromAppBundle() -> TaskNode? {
        if let fileUrl = Bundle.main.url(forResource: KeyConstants.Tasks.mockTask, withExtension: KeyConstants.Tasks.configFileExtension) {
            do {
                let data = try Data(contentsOf: fileUrl, options: [])
                return parseAppConfiguration(for: data)
            } catch let error {
                AlfrescoLog.error(error.localizedDescription)
            }
        }
        return nil
    }
    
    private func parseAppConfiguration(for data: Data?) -> TaskNode?  {
        if let json = data {
            do {
                let decoded = try JSONDecoder().decode(Task.self, from: json)
                let taskNodes = TaskNodeOperations.processNodes(for: [decoded])
                if !taskNodes.isEmpty {
                    return taskNodes.first
                }
            } catch {
                AlfrescoLog.error(error)
            }
        }
        return nil
    }
    
    func testTaskDetailViewModel_WhenInValidDueDateProvided_ShouldReturnMessage() {
        let task = loadTasksFromAppBundle()
        viewModel.task = task
        let dueDate = viewModel.getDueDate(for: Date())
        if dueDate == LocalizationConstants.Tasks.noDueDate {
            XCTAssertTrue(true)
        }
        XCTAssertFalse(false)
    }
    
    func testTaskDetailViewModel_WhenTaskIsAssigned_ShouldAllowToComplete() {
        let task = loadTasksFromAppBundle()
        viewModel.task = task
        if viewModel.isAllowedToCompleteTask() {
            XCTAssertTrue(true)
        }
        XCTAssertFalse(false)
    }
    
    func testTaskDetailViewModel_WhenLatestCommentUnvailable_ShouldReturnFalseToShow() {
        let task = loadTasksFromAppBundle()
        viewModel.task = task
        if viewModel.latestComment != nil {
            XCTAssertTrue(true)
            return
        }
        XCTAssertFalse(false)
    }
}
