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
    var resultsList: [ListElementProtocol] = []
    var accountService: AccountService?
    var apiClient: APIClientProtocol?
    weak var viewModelDelegate: ListViewModelDelegate?

    // MARK: - Init

    required init(with accountService: AccountService?, listRequest: SearchRequest?) {
        self.accountService = accountService
        self.listRequest = listRequest
        recentsList()
    }

    func recentsList() {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self, let accountIdentifier = sSelf.accountService?.activeAccount?.identifier else { return }
            AlfrescoContentServicesAPI.customHeaders = authenticationProvider.authorizationHeader()
            SearchAPI.search(queryBody: SearchRequestBuilder.recentRequest(accountIdentifier)) { (result, error) in
                if let entries = result?.list?.entries {
                    sSelf.resultsList = ListNode.nodes(entries)
                    DispatchQueue.main.async {
                        sSelf.viewModelDelegate?.handleList(results: sSelf.resultsList)
                    }
                } else {
                    if let error = error {
                        AlfrescoLog.error(error)
                    }
                    DispatchQueue.main.async {
                        sSelf.viewModelDelegate?.handleList(results: [])
                    }
                }
            }
        })
    }

    func getAvatar(completionHandler: @escaping ((UIImage?) -> Void)) -> UIImage? {
        if let avatar = DiskServices.get(image: kProfileAvatarImageFileName, from: accountService?.activeAccount?.identifier ?? "") {
            return avatar
        } else {
            accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
                guard let sSelf = self, let currentAccount = sSelf.accountService?.activeAccount else { return }
                sSelf.apiClient = APIClient(with: currentAccount.apiBasePath + "/", session: URLSession(configuration: .ephemeral))
                _ = sSelf.apiClient?.send(GetContentServicesAvatarProfile(with: authenticationProvider.authorizationHeader()), completion: { (result) in
                    switch result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                completionHandler(image)
                                DiskServices.save(image: image, named: kProfileAvatarImageFileName, inDirectory: currentAccount.identifier)
                            }
                        }
                    case .failure(let error):
                        AlfrescoLog.error(error)
                    }
                })
            })
        }

        return UIImage(named: "account-circle")
    }
}
