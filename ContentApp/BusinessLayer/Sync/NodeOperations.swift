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

import Foundation
import AlfrescoContent

class NodeOperations {
    var accountService: AccountService?

    required init(accountService: AccountService?) {
        self.accountService = accountService
    }

    func fetchNodeDetails(for guid: String,
                          completionHandler: @escaping ((_ data: NodeEntry?,
                                                         _ error: Error?) -> Void)) {
        accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            NodesAPI.getNode(nodeId: guid,
                             include: [kAPIIncludePathNode,
                                       kAPIIncludeIsFavoriteNode,
                                       kAPIIncludeAllowableOperationsNode,
                                       kAPIIncludeProperties],
                             relativePath: nil) { (result, error) in
                completionHandler(result, error)

            }
        })
    }
}
