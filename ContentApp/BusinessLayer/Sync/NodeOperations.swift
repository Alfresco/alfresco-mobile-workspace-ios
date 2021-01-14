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
import AlfrescoCore
import Alamofire

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

    func downloadContent(for node: ListNode,
                         to destinationURL: URL,
                         completionHandler: @escaping (URL?, APIError?) -> Void) -> DownloadRequest? {
        let requestBuilder = NodesAPI.getNodeContentWithRequestBuilder(nodeId: node.guid)
        let downloadURL = URL(string: requestBuilder.URLString)

        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (destinationURL, [.removePreviousFile])
        }

        if let url = downloadURL {
            return Alamofire.download(url,
                                      parameters: requestBuilder.parameters,
                                      headers: AlfrescoContentAPI.customHeaders,
                                      to: destination).response { response in
                                        if let destinationUrl = response.destinationURL,
                                           let httpURLResponse = response.response {
                                            if (200...299).contains(httpURLResponse.statusCode) {
                                                completionHandler(destinationUrl, nil)
                                            } else {
                                                let error = APIError(domain: "",
                                                                     code: httpURLResponse.statusCode)
                                                completionHandler(nil, error)
                                            }
                                        } else {
                                            if response.error?.code == NSURLErrorNetworkConnectionLost ||
                                                response.error?.code == NSURLErrorCancelled {
                                                completionHandler(nil, nil)
                                            } else {
                                                let error = APIError(domain: "",
                                                                     error: response.error)
                                                completionHandler(nil, error)
                                            }
                                        }
                                      }
        }

        return nil
    }
}
