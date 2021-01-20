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
    var renditionTimer: Timer?

    // MARK: - Init

    required init(accountService: AccountService?) {
        self.accountService = accountService
    }

    // MARK: - Public interface

    func sessionForCurrentAccount(completionHandler: @escaping ((AuthenticationProviderProtocol) -> Void)) {
        accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()

            completionHandler(authenticationProvider)
        })
    }

    func fetchNodeChildren(for guid: String,
                           pagination: RequestPagination,
                           relativePath: String? = nil,
                           completion: @escaping ((_ data: NodeChildAssociationPaging?,
                                                   _ error: Error?) -> Void)) {
        sessionForCurrentAccount { _ in
            NodesAPI.listNodeChildren(nodeId: guid,
                                      skipCount: pagination.skipCount,
                                      maxItems: pagination.maxItems,
                                      include: [kAPIIncludeIsFavoriteNode,
                                                kAPIIncludePathNode,
                                                kAPIIncludeAllowableOperationsNode,
                                                kAPIIncludeProperties],
                                      relativePath: relativePath) { (result, error) in
                completion(result, error)
            }
        }
    }

    func fetchNodeIsFavorite(for guid: String,
                             completion: @escaping ((_ data: FavoriteEntry?,
                                                            _ error: Error?) -> Void)) {
        sessionForCurrentAccount { _ in
            FavoritesAPI.getFavorite(personId: kAPIPathMe,
                                     favoriteId: guid) { (result, error) in
                completion(result, error)
            }
        }
    }

    func fetchNodeDetails(for guid: String,
                          relativePath: String? = nil,
                          completion: @escaping ((_ data: NodeEntry?,
                                                         _ error: Error?) -> Void)) {
        sessionForCurrentAccount { _ in
            NodesAPI.getNode(nodeId: guid,
                             include: [kAPIIncludePathNode,
                                       kAPIIncludeIsFavoriteNode,
                                       kAPIIncludeAllowableOperationsNode,
                                       kAPIIncludeProperties],
                             relativePath: relativePath) { (result, error) in
                completion(result, error)

            }
        }
    }

    func downloadContent(for node: ListNode,
                         to destinationURL: URL,
                         completionHandler: @escaping (URL?, APIError?) -> Void) -> DownloadRequest? {
        let requestBuilder = NodesAPI.getNodeContentWithRequestBuilder(nodeId: node.guid)
        let downloadURL = URL(string: requestBuilder.URLString)

        if let url = downloadURL {
            return downloadContent(from: url,
                                   to: destinationURL,
                                   completionHandler: completionHandler)
        }

        return nil
    }

    func downloadContent(from url: URL,
                         to destinationURL: URL,
                         completionHandler: @escaping (URL?, APIError?) -> Void) -> DownloadRequest? {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (destinationURL, [.removePreviousFile])
        }

        return Alamofire.download(url,
                                  parameters: nil,
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

    // MARK: - Rendition

    func fetchRenditionURL(for nodeId: String,
                           completionHandler: @escaping (URL?, _ isImageRendition: Bool) -> Void) {
        sessionForCurrentAccount { [weak self] _ in
            RenditionsAPI.listRenditions(nodeId: nodeId) { [weak self] (renditionPaging, _) in
                guard let sSelf = self,
                      let renditionEntries = renditionPaging?.list?.entries else {
                    completionHandler(nil, false)
                    return
                }

                sSelf.getRenditionURL(from: renditionEntries,
                                      nodeId: nodeId,
                                      renditionId: RenditionType.pdf.rawValue) { url in
                    if url != nil {
                        completionHandler(url, false)
                    } else {
                        sSelf.getRenditionURL(from: renditionEntries, nodeId: nodeId,
                                              renditionId: RenditionType.imagePreview.rawValue) { url in
                            completionHandler(url, true)
                        }
                    }
                }
            }
        }
    }

    private func renditionURL(for renditionId: String,
                              nodeId: String,
                              ticket: String?) -> URL? {
        guard let ticket = ticket,
              let basePathURL = accountService?.activeAccount?.apiBasePath,
              let renditionURL = URL(string: basePathURL + "/" +
                                        String(format: kAPIPathGetRenditionContent,
                                               nodeId,
                                               renditionId,
                                               ticket))
        else { return nil }
        return renditionURL
    }

    private func getRenditionURL(from list: [RenditionEntry],
                                 nodeId: String,
                                 renditionId: String,
                                 completionHandler: @escaping RenditionCompletionHandler) {
        let rendition = list.filter { (rendition) -> Bool in
            rendition.entry._id == renditionId
        }.first

        if let rendition = rendition {
            let ticket = accountService?.activeAccount?.getTicket()
            if rendition.entry.status == .created {
                completionHandler(renditionURL(for: renditionId,
                                               nodeId: nodeId,
                                               ticket: ticket))
            } else {
                let renditiontype = RenditionBodyCreate(_id: renditionId)

                sessionForCurrentAccount { [weak self] _ in
                    guard let sSelf = self else { return }

                    RenditionsAPI.createRendition(nodeId: nodeId,
                                                  renditionBodyCreate: renditiontype) {  (_, error) in
                        if error != nil {
                            AlfrescoLog.error("Unexpected error while creating rendition for node: \(nodeId)")
                        } else {
                            sSelf.retryRenditionCall(for: renditionId,
                                                     nodeId: nodeId,
                                                     ticket: ticket,
                                                     completionHandler: completionHandler)
                        }
                    }
                }
            }
        } else {
            completionHandler(nil)
        }
    }

    private func retryRenditionCall(for renditionId: String,
                                    nodeId: String,
                                    ticket: String?,
                                    completionHandler: @escaping RenditionCompletionHandler) {
        var retries = RenditionServiceConfiguration.maxRetries

        renditionTimer =
            Timer.scheduledTimer(withTimeInterval: RenditionServiceConfiguration.retryDelay,
                                 repeats: true) { [weak self] (timer) in
                guard let sSelf = self else { return }

                retries -= 1

                if retries == 0 {
                    timer.invalidate()
                    completionHandler(nil)
                }

                sSelf.sessionForCurrentAccount { _ in
                    RenditionsAPI.getRendition(nodeId: nodeId,
                                               renditionId: renditionId) { (rendition, _) in
                        if rendition?.entry.status == .created {
                            timer.invalidate()
                            completionHandler(sSelf.renditionURL(for: renditionId,
                                                                 nodeId: nodeId,
                                                                 ticket: ticket))
                        }
                    }
                }
            }
    }
}
