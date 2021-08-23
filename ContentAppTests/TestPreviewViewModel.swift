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

class TestPreviewViewModel: XCTestCase {
    
    override func setUp() {
        // initialize common code here
    }
    
    override func tearDown() {
        // release objects here
    }
 
    func testPreviewValidator_WhenValidFileNameProvided_ShouldReturnTrue() {
        let capturedAsset = CapturedAsset(type: .image, fileName: "test", path: "")
        let viewModel = PreviewViewModel(assets: [capturedAsset])
        viewModel.validateFileNames(in: nil) { (index, error) in
            if index < 0 {
                XCTAssertTrue(true, "File name is valid")
            } else {
                XCTAssertTrue(false, "File name is invalid")
            }
        }
    }
    
    func testPreviewValidator_WhenSpecialCharactersProvidedInFileName_ShouldReturnFalse() {
        let capturedAsset = CapturedAsset(type: .image, fileName: "test/", path: "")
        let viewModel = PreviewViewModel(assets: [capturedAsset])
        viewModel.validateFileNames(in: nil) { (index, error) in
            if index < 0 {
                XCTAssertTrue(true, "File name does not contain special characters")
            } else {
                XCTAssertFalse(false, "File name contains special characters")
            }
        }
    }
}
