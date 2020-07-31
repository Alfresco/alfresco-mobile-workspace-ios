//
// Copyright (C) 2005-2020 Alfresco Software Limited.
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
import UIKit
import AlfrescoAuth
import AlfrescoContentServices

class RecentViewModel: PageFetchingViewModel, ListViewModelProtocol {
    var listRequest: SearchRequest?
    var groupedLists: [GroupedList] = []
    var accountService: AccountService?

    // MARK: - Init

    required init(with accountService: AccountService?, listRequest: SearchRequest?) {
        self.accountService = accountService
        self.listRequest = listRequest
    }

    // MARK: - Public methods

    func recentsList(with paginationRequest: RequestPagination?) {
        pageFetchingGroup.enter()

        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self, let accountIdentifier = sSelf.accountService?.activeAccount?.identifier else { return }
            AlfrescoContentServicesAPI.customHeaders = authenticationProvider.authorizationHeader()
            SearchAPI.search(queryBody: SearchRequestBuilder.recentRequest(accountIdentifier, pagination: paginationRequest)) { (result, error) in
                var listNodes: [ListNode]?
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

                sSelf.handlePaginatedResponse(response: paginatedResponse)
            }
        })
    }

    func shouldDisplaySettingsButton() -> Bool {
        return true
    }

    // MARK: - ListViewModelProtocol

    func isEmpty() -> Bool {
        return groupedLists.isEmpty
    }

    func shouldDisplaySections() -> Bool {
        return true
    }

    func numberOfSections() -> Int {
        return groupedLists.count
    }

    func numberOfItems(in section: Int) -> Int {
        return groupedLists[section].list.count
    }

    func listNode(for indexPath: IndexPath) -> ListNode {
        return groupedLists[indexPath.section].list[indexPath.row]
    }

    func titleForSectionHeader(at indexPath: IndexPath) -> String {
        return groupedLists[indexPath.section].titleGroup
    }

    func shouldDisplayListLoadingIndicator() -> Bool {
        return self.shouldDisplayNextPageLoadingIndicator
    }

    func refreshList() {
        recentsList(with: nil)
    }

    override func updatedResults(results: [ListNode]) {
        groupedLists = []
        addInGroupList(self.results)
    }

    override func fetchItems(with requestPagination: RequestPagination, userInfo: Any?, completionHandler: @escaping PagedResponseCompletionHandler) {
        recentsList(with: requestPagination)
    }

    override func handlePage(results: [ListNode]?, pagination: Pagination?, error: Error?) {
        updateResults(results: results, pagination: pagination, error: error)
    }

    // MARK: - Private methods

    private func add(element: ListNode, inGroupType type: GroupedListType) {
        for groupedList in groupedLists where groupedList.type == type {
            groupedList.list.append(element)
            return
        }
        groupedLists.append(GroupedList(type: type, list: [element]))
    }

    private func addInGroupList(_ results: [ListNode]) {
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
                self.add(element: element, inGroupType: groupType)
            } else {
                groupedLists.first?.list.append(element)
            }
        }
    }
}
