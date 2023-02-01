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

class RecentModel: ListComponentModelProtocol {
    internal var supportedNodeTypes: [NodeType] = []
    private var services: CoordinatorServices
    private var groupedLists: [ListNode] = []

    var delegate: ListComponentModelDelegate?
    var rawListNodes: [ListNode] = [] {
        didSet {
            createSectionArray(rawListNodes)
        }
    }

    init(services: CoordinatorServices) {
        self.services = services
    }

    func isEmpty() -> Bool {
        return rawListNodes.isEmpty
    }
    
    func numberOfItems(in section: Int) -> Int {
        return groupedLists.count
    }

    func listNodes() -> [ListNode] {
        return groupedLists
    }

    func listNode(for indexPath: IndexPath) -> ListNode? {
        if !groupedLists.isEmpty && groupedLists.count > indexPath.row {
            return groupedLists[indexPath.row]
        }
        return nil
    }

    func titleForSectionHeader(at indexPath: IndexPath) -> String {
        if let listNode = self.listNode(for: indexPath) {
            if listNode.guid == listNodeSectionIdentifier {
                return listNode.title
            }
        }
        return ""
    }

    func fetchItems(with requestPagination: RequestPagination, completionHandler: @escaping PagedResponseCompletionHandler) {
        recentsList(with: requestPagination,
                    completionHandler: completionHandler)
    }

    // MARK: - Private methods

    func recentsList(with paginationRequest: RequestPagination?,
                     completionHandler: @escaping PagedResponseCompletionHandler) {
        services.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            let recentFilesRequest = SearchRequestBuilder.recentFilesRequest(pagination: paginationRequest)
            SearchAPI.recentFiles(recentFilesRequest: recentFilesRequest) { (result, error) in
                var listNodes: [ListNode] = []
                if let entries = result?.list?.entries {
                    listNodes = ResultsNodeMapper.map(entries)
                } else {
                    if let error = error {
                        AlfrescoLog.error(error)
                    }
                }
                let paginatedResponse = PaginatedResponse(results: listNodes,
                                                          error: error,
                                                          requestPagination: paginationRequest,
                                                          responsePagination: result?.list?.pagination)
                completionHandler(paginatedResponse)
            }
        })
    }

    private func createSectionArray(_ results: [ListNode]) {
        groupedLists = []
        for element in results {
            if let date = element.modifiedAt {
                var groupType: GroupedListType = .today
                if date.isInToday {
                    groupType = .today
                } else if date.isInYesterday {
                    groupType = .yesterday
                } else if date.isInThisWeek {
                    groupType = .thisWeek
                } else if date.isInLastWeek {
                    groupType = .lastWeek
                } else {
                    groupType = .older
                }
                add(element: element, type: groupType)
            } else {
                add(element: element, type: .today)
            }
        }
    }

    private func add(element: ListNode, type: GroupedListType) {
        let section = GroupedList(type: type)
        var newGroupList = true
        for element in groupedLists {
            if element.guid == listNodeSectionIdentifier &&
                element.title == section.titleGroup {
                newGroupList = false
            }
        }

        if newGroupList {
            let sectionNode = ListNode(guid: listNodeSectionIdentifier,
                                       title: section.titleGroup,
                                       path: "",
                                       nodeType: .unknown)
            groupedLists.append(sectionNode)
        }
        groupedLists.append(element)
    }
}

// MARK: - Event observable

extension RecentModel: EventObservable {

    func handle(event: BaseNodeEvent, on queue: EventQueueType) {
        if let publishedEvent = event as? FavouriteEvent {
            handleFavorite(event: publishedEvent)
        } else if let publishedEvent = event as? MoveEvent {
            handleMove(event: publishedEvent)
        } else if let publishedEvent = event as? OfflineEvent {
            handleOffline(event: publishedEvent)
        }
    }

    private func handleFavorite(event: FavouriteEvent) {
        let node = event.node
        for listNode in rawListNodes where listNode.guid == node.guid {
            listNode.favorite = node.favorite
        }
    }

    private func handleMove(event: MoveEvent) {
        let node = event.node
        switch event.eventType {
        case .moveToTrash:
            if node.nodeType == .file {
                if let indexOfMovedNode = rawListNodes.firstIndex(where: { listNode in
                    listNode.guid == node.guid
                }) {
                    rawListNodes.remove(at: indexOfMovedNode)
                    delegate?.needsDisplayStateRefresh()
                }
            } else {
                delegate?.needsDataSourceReload()
            }
        case .restore, .moveToFolder, .updated:
            delegate?.needsDataSourceReload()
        default: break
        }
    }

    private func handleOffline(event: OfflineEvent) {
        let node = event.node

        if let indexOfOfflineNode = rawListNodes.firstIndex(where: { listNode in
            listNode.guid == node.guid
        }) {
            rawListNodes[indexOfOfflineNode] = node

            let indexPath = IndexPath(row: indexOfOfflineNode, section: 0)
            delegate?.forceDisplayRefresh(for: indexPath)
        }
    }
}

// MARK: - Offline search
extension RecentModel {
    func fetchOfflineItems(completionHandler: @escaping PagedResponseCompletionHandler) {
    }
}
