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

import UIKit
import AlfrescoContentServices
import AlfrescoAuth

protocol ListViewModelProtocol {
    var accountService: AccountService? { get set }
    var apiClient: APIClientProtocol? { get set }

    var listRequest: SearchRequest? { get set }
    var groupedLists: [GroupedList] { get set }
    var viewModelDelegate: ListViewModelDelegate? { get set }

    init(with accountService: AccountService?, listRequest: SearchRequest?)
    func getAvatar(completionHandler: @escaping ((UIImage?) -> Void)) -> UIImage?
    func reloadRequest()
    func shouldDisplaySections() -> Bool
    func shouldDisplaySettingsButton() -> Bool
}

protocol ListViewModelDelegate: class {
    func handleList()
}

extension ListViewModelProtocol {
    func getAvatar(completionHandler: @escaping ((UIImage?) -> Void)) -> UIImage? {
        if let avatar = DiskServices.get(image: kProfileAvatarImageFileName, from: accountService?.activeAccount?.identifier ?? "") {
            return avatar
        } else {
            accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
                var sSelf = self
                guard let currentAccount = sSelf.accountService?.activeAccount else { return }
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
