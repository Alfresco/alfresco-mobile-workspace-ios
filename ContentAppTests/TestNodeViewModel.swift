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
    
    func loadMenuFromAppBundle() -> MobileConfigData? {
        if let fileUrl = Bundle.main.url(forResource: KeyConstants.MenuConfiguration.featuresMobile,
                                         withExtension: KeyConstants.Tasks.configFileExtension) {
            do {
                let data = try Data(contentsOf: fileUrl)
                return parseMenuAppConfiguration(for: data)
            } catch {
                AlfrescoLog.error("Failed to load menu configuration: \(error.localizedDescription)")
            }
        }
        return nil
    }

    private func parseMenuAppConfiguration(for data: Data) -> MobileConfigData? {
        do {
            let decoded = try JSONDecoder().decode(MobileConfigData.self, from: data)
            return decoded
        } catch {
            AlfrescoLog.error("JSON Decoding Error: \(error.localizedDescription)")
        }
        return nil
    }

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
        let configData = loadMenuFromAppBundle()
        let action = ActionsMenuGeneric.renameNodeAction(for: list, configData: configData)
        if action == nil {
            XCTAssertTrue(true)
        }
    }
}
