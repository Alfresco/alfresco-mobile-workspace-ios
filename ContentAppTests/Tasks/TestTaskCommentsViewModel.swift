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

class TestTaskCommentsViewModel: XCTestCase {
    lazy var viewModel = TaskCommentsViewModel()

    // MARK: - load tasks from bundle
    func loadCommentsFromAppBundle() -> [TaskCommentModel]? {
        if let fileUrl = Bundle.main.url(forResource: KeyConstants.Tasks.mockComments, withExtension: KeyConstants.Tasks.configFileExtension) {
            do {
                let data = try Data(contentsOf: fileUrl, options: [])
                return parseAppConfiguration(for: data)
            } catch let error {
                AlfrescoLog.error(error.localizedDescription)
            }
        }
        return nil
    }
    
    private func parseAppConfiguration(for data: Data?) -> [TaskCommentModel]?  {
        if let json = data {
            do {
                let decoded = try JSONDecoder().decode(Comments.self, from: json)
                let comments = TaskCommentOperations.processComments(for: decoded.data)
                return comments

            } catch {
                AlfrescoLog.error(error)
            }
        }
        return nil
    }
    
    func testTaskCommentsViewModel_WhenTextIsProvided_ShouldReturnTrue() {
        if let comments = loadCommentsFromAppBundle() {
            viewModel.comments.value = comments
            let isAllowed = viewModel.isAddCommentAllowed(for: "test comment").isAllowed
            if isAllowed {
                XCTAssertTrue(true)
                return
            }
            XCTAssertTrue(false)
        }
    }
}
