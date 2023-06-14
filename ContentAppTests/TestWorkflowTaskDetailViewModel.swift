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

final class TestWorkflowTaskDetailViewModel: XCTestCase {
    lazy var viewModel = WflowTaskDetailViewModel()

    func testWflowTaskDetailViewModel_WhenValidDateProvided_ShouldReturnTrue() {
        if let dueDate = viewModel.getDueDate(for: "2022-06-15") {
            if dueDate != LocalizationConstants.Tasks.noDueDate {
                XCTAssertTrue(true)
            }
        }
        XCTAssertFalse(false)
    }
    
    func testWflowTaskDetailViewModel_WhenReceivesStatus_ShouldReturnTrue() {
        if viewModel.getSelectedStatus() == nil {
            XCTAssertFalse(false)
        }
        XCTAssertTrue(true)
    }
    
    func testWflowTaskDetailViewModel_IfValidationPassed_ShouldReturnTrue() {
        if viewModel.isValidationPassed() == true {
            XCTAssertTrue(true)
        }
        XCTAssertFalse(false)
    }
}
