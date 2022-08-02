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

class TestSearchListComponentViewModel: XCTestCase {

    func isApplyAllowed(fromValue: String?, toValue: String?) -> Bool {
        let minimumValue = (fromValue ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let maximumValue = (toValue ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if minimumValue.isEmpty && maximumValue.isEmpty {
            return false
        }
        
        return true
    }
    
    func testSearchListComponentViewModel_WhenValidDateProvided_ShouldReturnTrue() {
        let fromDate = "2022-08-10"
        let result = self.isApplyAllowed(fromValue: fromDate, toValue: nil)
        XCTAssertTrue(result)
    }
    
    func testSearchListComponentViewModel_WhenInValidDateProvided_ShouldReturnFalse() {
        let result = self.isApplyAllowed(fromValue: nil, toValue: nil)
        XCTAssertFalse(result)
    }
}



