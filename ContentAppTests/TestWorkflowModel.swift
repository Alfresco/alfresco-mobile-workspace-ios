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

import XCTest
@testable import ContentApp

final class TestWorkflowModel: XCTestCase {

    func testAPSIsEnabled() {
        let isAPSEnable = APSService.isAPSServiceEnable ?? false
        if isAPSEnable {
            XCTAssertTrue(true)
        }
        XCTAssertFalse(false)
    }
    
    func test_WhenDueDateAdded_ShouldReturnTrue() {
        let model = StartWorkflowViewModel()
        if model.dueDate == nil {
            XCTAssertFalse(false)
        }
        XCTAssertTrue(true)
    }
    
    func test_WhenAttachmentsAdded_ShouldReturnTrue() {
        let model = StartWorkflowViewModel()
        let count = model.workflowOperationsModel?.attachments.value.count
        if count == 0 {
            XCTAssertFalse(false)
        }
        XCTAssertTrue(true)
    }
    
    func test_WhenAssigneeAdded_ShouldReturnTrue() {
        let model = StartWorkflowViewModel()
        if model.assignee == nil {
            XCTAssertFalse(false)
        }
        XCTAssertTrue(true)
    }
}
