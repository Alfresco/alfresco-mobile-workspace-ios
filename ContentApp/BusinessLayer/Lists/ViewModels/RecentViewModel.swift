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

class RecentViewModel: ListViewModelProtocol {
    var listRequest: SearchRequest?
    var groupedLists: [GroupedList] = []
    var accountService: AccountService?
    var apiClient: APIClientProtocol?
    weak var delegate: ListViewModelDelegate?

    // MARK: - Init

    required init(with accountService: AccountService?, listRequest: SearchRequest?) {
        self.accountService = accountService
        self.listRequest = listRequest
    }

    // MARK: - Public methods

    func recentsList() {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self, let accountIdentifier = sSelf.accountService?.activeAccount?.identifier else { return }
            AlfrescoContentServicesAPI.customHeaders = authenticationProvider.authorizationHeader()
            SearchAPI.search(queryBody: SearchRequestBuilder.recentRequest(accountIdentifier)) { (result, error) in
                if let entries = result?.list?.entries {
                    sSelf.addInGroupList(ResultsNodeMapper.map(entries))
                    DispatchQueue.main.async {
                        sSelf.delegate?.handleList()
                    }
                } else {
                    if let error = error {
                        AlfrescoLog.error(error)
                    }
                    DispatchQueue.main.async {
                        sSelf.delegate?.handleList()
                    }
                }
            }
        })
    }

    func fetchNextRecentsResultPage(for index: IndexPath) {
    }

    func reloadRequest() {
        groupedLists = self.emptyGroupedLists()
        recentsList()
    }

    func shouldDisplaySections() -> Bool {
        return true
    }

    func shouldDisplaySettingsButton() -> Bool {
        return true
    }

    // MARK: - Private methods

    private func emptyGroupedLists() -> [GroupedList] {
        return []
    }

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
