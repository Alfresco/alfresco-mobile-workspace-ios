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
                                      include: [APIConstants.Include.isFavorite,
                                                APIConstants.Include.path,
                                                APIConstants.Include.allowableOperations,
                                                APIConstants.Include.properties],
                                      relativePath: relativePath,
                                      includeSource: true) { (result, error) in
                completion(result, error)
            }
        }
    }

    func fetchNodeIsFavorite(for guid: String,
                             completion: @escaping ((_ data: FavoriteEntry?,
                                                            _ error: Error?) -> Void)) {
        sessionForCurrentAccount { _ in
            FavoritesAPI.getFavorite(personId: APIConstants.me,
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
                             include: [APIConstants.Include.path,
                                       APIConstants.Include.isFavorite,
                                       APIConstants.Include.allowableOperations,
                                       APIConstants.Include.properties],
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
                         to destinationURL: URL? = nil,
                         completionHandler: @escaping (URL?, APIError?) -> Void) -> DownloadRequest? {
        var destination: DownloadRequest.DownloadFileDestination?
        if let destinationUrl = destinationURL {
            destination = { _, _ in
                return (destinationUrl, [.removePreviousFile])
            }
        }

        return Alamofire.download(url,
                                  parameters: nil,
                                  headers: AlfrescoContentAPI.customHeaders,
                                  to: destination).response { response in
            if let destinationUrl = response.destinationURL ?? response.temporaryURL,
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
    
    func createNode(nodeId: String,
                    name: String,
                    description: String?,
                    nodeExtension: String,
                    fileData: Data,
                    autoRename: Bool,
                    completionHandler: @escaping (ListNode?, Error?) -> Void) {
        let nodeBody = NodeBodyCreate(name: name + "." + nodeExtension,
                                      nodeType: "cm:content",
                                      aspectNames: nil,
                                      properties: nodeProperties(for: name,
                                                                 description: description),
                                      permissions: nil,
                                      definition: nil,
                                      relativePath: nil,
                                      association: nil,
                                      secondaryChildren: nil,
                                      targets: nil)
        NodesAPI.createNode(nodeId: nodeId,
                            nodeBody: nodeBody,
                            fileData: fileData,
                            autoRename: autoRename,
                            description: description) { (nodeEntry, error) in
            if let node = nodeEntry?.entry {
                let listNode = NodeChildMapper.create(from: node)
                completionHandler(listNode, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }

    func createNode(nodeId: String,
                    name: String,
                    description: String?,
                    autoRename: Bool,
                    completionHandler: @escaping (ListNode?, Error?) -> Void) {
        let nodeBody = NodeBodyCreate(name: name,
                                      nodeType: "cm:folder",
                                      aspectNames: nil,
                                      properties: nodeProperties(for: name,
                                                                 description: description),
                                      permissions: nil,
                                      definition: nil,
                                      relativePath: nil,
                                      association: nil,
                                      secondaryChildren: nil,
                                      targets: nil)
        let requestBuilder = NodesAPI.createNodeWithRequestBuilder(nodeId: nodeId,
                                                                   nodeBodyCreate: nodeBody,
                                                                   autoRename: autoRename,
                                                                   include: nil,
                                                                   fields: nil)
        requestBuilder.execute { (result, error) in
            if let error = error {
                completionHandler(nil, error)
            } else if let node = result?.body?.entry {
                let listNode = NodeChildMapper.create(from: node)
                listNode.allowableOperations = [.update, .create, .updatePermissions, .delete]
                completionHandler(listNode, nil)
            }
        }
    }

    func updateNode(nodeId: String,
                    name: String,
                    description: String?,
                    autoRename: Bool,
                    isFolder: Bool,
                    completionHandler: @escaping (ListNode?, Error?) -> Void) {
        
        var nodeType = "cm:content"
        if isFolder {
            nodeType = "cm:folder"
        }
        let nodeBody = NodeBodyUpdate(name: name,
                                            nodeType: nodeType,
                                            aspectNames: nil,
                                            properties: nodePropertiesToUpdate(for: name, description: description),
                                            permissions: nil)
        let requestBuilder = NodesAPI.updateNodeWithRequestBuilder(nodeId: nodeId, nodeBodyUpdate: nodeBody)
        
        requestBuilder.execute { (result, error) in
            if let error = error {
                completionHandler(nil, error)
            } else if let node = result?.body?.entry {
                let listNode = NodeChildMapper.create(from: node)
                completionHandler(listNode, nil)
            }
        }
    }
    
    func fetchContentURL(for node: ListNode?) -> URL? {
        guard let ticket = accountService?.activeAccount?.getTicket(),
              let basePathURL = accountService?.activeAccount?.apiBasePath,
              let listNode = node,
              let previewURL = URL(string: basePathURL + "/" +
                                    String(format: APIConstants.Path.getNodeContent, listNode.guid, ticket))
        else { return nil }
        return previewURL
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
                                        String(format: APIConstants.Path.getRenditionContent,
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

    private func nodeProperties(for name: String, description: String?) -> JSONValue {
        if let description = description {
            return JSONValue(dictionaryLiteral:
                                ("cm:title", JSONValue(stringLiteral: name)),
                             ("cm:description", JSONValue(stringLiteral: description)))
        } else {
            return JSONValue(dictionaryLiteral:
                                ("cm:title", JSONValue(stringLiteral: name)))
        }
    }
    
    private func nodePropertiesToUpdate(for name: String, description: String?) -> [String: String] {
        if let description = description {
            return ["cm:title": name,
                    "cm:description": description]
        } else {
            return ["cm:title": name]
        }
    }
    
    // MARK: - Fetch APS User Details
    func fetchAPSUserDetails(completion: @escaping ((_ result: UserData?, _ error: Error?) -> Void)) {
        sessionForCurrentAccount { _ in
            AlfrescoContent.UserProfile.getUserProfile { result, error in
                completion(result, error)
            }
        }
    }
}
