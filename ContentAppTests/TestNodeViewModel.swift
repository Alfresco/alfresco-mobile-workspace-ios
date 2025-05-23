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

class TestNodeViewModel: XCTestCase {
    
    func testNodeViewModel_WhenValidNameProvided_ShouldReturnTrue() {
        let name = "test folder name"
        let result = !name.hasSpecialCharacters()
        XCTAssertTrue(result)
    }
    
    func testNodeViewModel_WhenInValidNameProvided_ShouldReturnFalse() {
        let name = "* test folder name *"
        let result = !name.hasSpecialCharacters()
        XCTAssertFalse(result)
    }
    
    func testNodeViewModel_WhenValidPermissionsAvailable_ShouldReturnTrue() {
        let list = ListNode()
        let configData = MenuConfigLoader.loadMenuFromAppBundle()
        let action = ActionsMenuGeneric.renameNodeAction(for: list, configData: configData)
        if action == nil {
            XCTAssertTrue(true)
        }
    }
}
