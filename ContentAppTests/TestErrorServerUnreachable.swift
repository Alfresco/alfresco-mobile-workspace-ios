//
// Copyright (C) 2005-2026 Alfresco Software Limited.
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

class TestErrorServerUnreachable: XCTestCase {

    func testIsServerUnreachable_WhenDomainlessNSError_ShouldReturnFalseWithoutCrashing() {
        let error: Error = NSError()
        XCTAssertFalse(error.isServerUnreachable)
    }

    func testIsServerUnreachable_WhenURLErrorTimedOut_ShouldReturnTrue() {
        let error: Error = URLError(.timedOut)
        XCTAssertTrue(error.isServerUnreachable)
    }

    func testIsServerUnreachable_WhenNSErrorInURLDomain_ShouldReturnTrue() {
        let error: Error = NSError(domain: NSURLErrorDomain, code: URLError.cannotConnectToHost.rawValue)
        XCTAssertTrue(error.isServerUnreachable)
    }

    func testIsServerUnreachable_WhenWrappedInSynthetic500_ShouldReturnTrue() {
        let error: Error = ErrorResponse.error(500, nil, URLError(.cannotFindHost))
        XCTAssertTrue(error.isServerUnreachable)
    }

    func testIsServerUnreachable_WhenURLErrorIsNotTransportFailure_ShouldReturnFalse() {
        let error: Error = URLError(.badServerResponse)
        XCTAssertFalse(error.isServerUnreachable)
    }

    func testIsServerUnreachable_WhenOtherDomain_ShouldReturnFalse() {
        let error: Error = NSError(domain: "AlfrecoAuth", code: URLError.timedOut.rawValue)
        XCTAssertFalse(error.isServerUnreachable)
    }
}
