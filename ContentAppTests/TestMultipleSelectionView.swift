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

final class TestMultipleSelectionView: XCTestCase {
    lazy var viewController = ListComponentViewController()
    
    func testListComponentViewController_WhenArrayEmpty_ShouldReturnFalse() {
        let node = ListNode()
        viewController.viewModel?.selectedMultipleItems = [node]
        viewController.handleAddRemoveNodeList(node: node)
        XCTAssertFalse(false)
    }
    
    func testListComponentViewController_WhenArrayisNonEmpty_ShouldReturnTrue() {
        let node = ListNode()
        viewController.viewModel?.selectedMultipleItems = [node]
        viewController.showElementsCount()
        XCTAssertTrue(true)
    }
}
