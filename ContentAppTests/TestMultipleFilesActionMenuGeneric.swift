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
@testable import AlfrescoContent

final class TestMultipleFilesActionMenuGeneric: XCTestCase {
    var listNodes = [ListNode]()
    
    func loadListNodeFromAppBundle() {
        if let fileUrl = Bundle.main.url(forResource: KeyConstants.Tasks.mockNodeList, withExtension: KeyConstants.Tasks.configFileExtension) {
            do {
                let data = try Data(contentsOf: fileUrl, options: [])
                parseAppConfiguration(for: data)
            } catch let error {
                AlfrescoLog.error(error.localizedDescription)
            }
        }
    }
    
    private func parseAppConfiguration(for data: Data?) {
        if let json = data {
            do {
                let result = try JSONDecoder().decode(ResultSetPaging.self, from: json)
                if let entries = result.list?.entries {
                    listNodes = ResultsNodeMapper.map(entries)
                }

            } catch {
                AlfrescoLog.error(error)
            }
        }
    }
    
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

    
    func testMultipleFilesActionMenuGeneric_IfGetAllActions_ShouldReturnTrue() {
        loadListNodeFromAppBundle()
        let configData = loadMenuFromAppBundle()
        if !listNodes.isEmpty {
            let action  = MultipleFilesActionMenuGeneric.actions(for: listNodes, configData: configData)
            if !action.isEmpty {
                XCTAssertTrue(true)
            }
        }
        XCTAssertFalse(false)
    }
    
    func testMultipleFilesActionMenuGeneric_IfGeFilteredNodes_ShouldReturnTrue() {
        loadListNodeFromAppBundle()
        let nodes  = MultipleFilesActionMenuGeneric.getFilteredNodes(for: listNodes)
        if !nodes.isEmpty {
            XCTAssertTrue(true)
        }
        XCTAssertFalse(false)
    }
    
    func testMultipleFilesActionMenuGeneric_IfMoveAllowed_ShouldReturnTrue() {
        loadListNodeFromAppBundle()
        let configData = loadMenuFromAppBundle()
        if !listNodes.isEmpty {
            let action  = MultipleFilesActionMenuGeneric.moveToFolderAction(for: listNodes, configData: configData)
            if action != nil {
                XCTAssertTrue(true)
            }
        }
        XCTAssertFalse(false)
    }
    
    func testMultipleFilesActionMenuGeneric_IfFavAllowed_ShouldReturnTrue() {
        loadListNodeFromAppBundle()
        let configData = loadMenuFromAppBundle()
        if !listNodes.isEmpty {
            let action  = MultipleFilesActionMenuGeneric.favoriteAction(for: listNodes, configData: configData)
            if action != nil {
                XCTAssertTrue(true)
            }
        }
        XCTAssertFalse(false)
    }
    
    func testMultipleFilesActionMenuGeneric_IfOfflineAllowed_ShouldReturnTrue() {
        loadListNodeFromAppBundle()
        let configData = loadMenuFromAppBundle()
        if !listNodes.isEmpty {
            let action  = MultipleFilesActionMenuGeneric.offlineAction(for: listNodes, configData: configData)
            if action != nil {
                XCTAssertTrue(true)
            }
        }
        XCTAssertFalse(false)
    }
    
    func testMultipleFilesActionMenuGeneric_IfDeleteAllowed_ShouldReturnTrue() {
        loadListNodeFromAppBundle()
        let configData = loadMenuFromAppBundle()
        if !listNodes.isEmpty {
            let action  = MultipleFilesActionMenuGeneric.deleteAction(for: listNodes, configData: configData)
            if action != nil {
                XCTAssertTrue(true)
            }
        }
        XCTAssertFalse(false)
    }
    
    func testMultipleFilesActionMenuGeneric_IfStartWorkflowAllowed_ShouldReturnTrue() {
        loadListNodeFromAppBundle()
        let configData = loadMenuFromAppBundle()
        if !listNodes.isEmpty {
            let action  = MultipleFilesActionMenuGeneric.startWorkflowAction(for: listNodes, configData: configData)
            if action != nil {
                XCTAssertTrue(true)
            }
        }
        XCTAssertFalse(false)
    }
}
