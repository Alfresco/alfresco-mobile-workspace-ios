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
    
    func testIsShowConfigurationView_WhenEmptyConfigArrayProvided_ShouldReturnFalse() {
        let services = CoordinatorServices()
        let searchModel = SearchModel(with: services)
        let searchViewModel = SearchViewModel(model: searchModel)
        let configurations = [String]()
        let result = searchViewModel.isShowAdvanceFilterView(array: configurations)
        XCTAssertFalse(result)
    }
    
    func testIsShowConfigurationView_WhenNonEmptyConfigArrayProvided_ShouldReturnTrue() {
        let services = CoordinatorServices()
        let searchModel = SearchModel(with: services)
        let searchViewModel = SearchViewModel(model: searchModel)
        let configurations = ["Default", "Folder"]
        let result = searchViewModel.isShowAdvanceFilterView(array: configurations)
        XCTAssertTrue(result)
    }
    
    func testDefaultFilterName_WhenDefaultValueProvided_ShouldReturnActualName() {
        let services = CoordinatorServices()
        let searchModel = SearchModel(with: services)
        let searchViewModel = SearchViewModel(model: searchModel)
        let defaultSearchFilter = searchViewModel.defaultSearchFilter()
        let name = searchViewModel.selectedFilterName(for: defaultSearchFilter)
        var result = false
        if name == LocalizationConstants.AdvanceSearch.title {
            result = true
        }
        XCTAssertTrue(result)
    }
}
