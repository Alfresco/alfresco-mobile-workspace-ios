//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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

class TestSearchViewModel: XCTestCase {

    override func setUp() {
        // initialize common code here
    }
    
    override func tearDown() {
        // release objects here
    }
 
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSearchViewModel_WhenValidTimeDifferenceProvided_ShouldReturnFalse() {
        let services = CoordinatorServices()
        let searchModel = SearchModel(with: services)
        let searchViewModel = SearchViewModel(model: searchModel)
        let apiInterval = ConfigurationManager.shared.getAdvanceSearchAPIInterval()
        let result = searchViewModel.isTimeExceedsForAdvanceSearchConfig(apiInterval: apiInterval)
        XCTAssertFalse(result)
    }
    
    func testSearchViewModel_WhenInValidTimeDifferenceProvided_ShouldReturnTrue() {
        let services = CoordinatorServices()
        let searchModel = SearchModel(with: services)
        let searchViewModel = SearchViewModel(model: searchModel)
        let apiInterval = 1
        let result = searchViewModel.isTimeExceedsForAdvanceSearchConfig(apiInterval: apiInterval)
        XCTAssertTrue(result)
    }
}
