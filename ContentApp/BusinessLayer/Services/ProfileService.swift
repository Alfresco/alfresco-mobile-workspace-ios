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
//  Unless required by applicable law or agreed: in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import AlfrescoAuth
import AlfrescoContentServices

class ProfileService {
    static var apiClient: APIClientProtocol?
    static var serviceRepository = ApplicationBootstrap.shared().serviceRepository
    static var accountService = serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService

    static func getAvatar(completionHandler: @escaping ((UIImage?) -> Void)) -> UIImage? {
        if let avatar = DiskServices.get(image: kProfileAvatarImageFileName, from: accountService?.activeAccount?.identifier ?? "") {
            return avatar
        } else {
            featchAvatar(completionHandler: completionHandler)
        }
        return UIImage(named: "account-circle")
    }

    static func featchAvatar(completionHandler: @escaping ((UIImage?) -> Void)) {
        accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            let sSelf = self
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

    static func fetchProfileInformation(completion: @escaping ((PersonEntry?, Error?) -> Void)) {
        accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentServicesAPI.customHeaders = authenticationProvider.authorizationHeader()
            PeopleAPI.getPerson(personId: kAPIPathMe) { (personEntry, error) in
                completion(personEntry, error)
            }
        })
    }
}
