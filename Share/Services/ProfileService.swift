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

import UIKit
import AlfrescoAuth
import AlfrescoContent

class ProfileService {
    static var repository = ApplicationBootstrap.shared().repository
    static var accountService = repository.service(of: AccountService.identifier) as? AccountService

    static func featchPersonalFilesID() {
        let nodeOperations = NodeOperations(accountService: accountService)
        nodeOperations.fetchNodeDetails(for: APIConstants.my) { (result, error) in
            if let node = result {
                UserProfile.personalFilesID = node.entry._id
            } else if let error = error {
                AlfrescoLog.error(error)
            }
        }
    }
    
    // MARK: - APS Profile Id
    static func fetchAPSProfileDetails() {
        let nodeOperations = NodeOperations(accountService: accountService)
        nodeOperations.fetchAPSUserDetails { result, error in
            if let result = result {
                UserProfile.apsUserID = result.id
            } else if let error = error {
                AlfrescoLog.error(error)
            }
        }
    }
}
