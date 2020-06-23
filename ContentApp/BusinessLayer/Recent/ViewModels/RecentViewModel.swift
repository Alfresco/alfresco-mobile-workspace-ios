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

protocol RecentViewModelDelegate: class {
    func didUpdateAvatarImage(image: UIImage)
}

class RecentViewModel {
    var items: [[SettingsItem]] = []
    var accountService: AccountService?
    weak var viewModelDelegate: RecentViewModelDelegate?
    var apiClient: APIClientProtocol?

    // MARK: - Init

    init(accountService: AccountService?) {
        self.accountService = accountService
        fetchAvatar()
    }

    // MARK: - Private methods

    private func fetchAvatar() {
        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
            guard let sSelf = self, let currentAccount = sSelf.accountService?.activeAccount else { return }
            sSelf.apiClient = APIClient(with: currentAccount.apiBasePath + "/")
            _ = sSelf.apiClient?.send(GetContentServicesAvatarProfile(with: authenticationProvider.authorizationHeader()), completion: { (result) in
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            sSelf.viewModelDelegate?.didUpdateAvatarImage(image: image)
                            DiskServices.save(image: image, named: kProfileAvatarImageFileName, inDirectory: currentAccount.identifier)
                        }
                    }
                case .failure(let error):
                    AlfrescoLog.error(error)
                }
            })
        })
    }

}
