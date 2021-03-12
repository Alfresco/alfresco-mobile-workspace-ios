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
import AlfrescoContent

class ProfileService {
    static var repository = ApplicationBootstrap.shared().repository
    static var accountService = repository.service(of: AccountService.identifier) as? AccountService

    static func getAvatar(completionHandler: @escaping ((UIImage?) -> Void)) -> UIImage? {
        let defaultImage = UIImage(named: "ic-account-circle")
        guard let accountIdentifier = accountService?.activeAccount?.identifier
        else { return defaultImage }

        if let avatar = DiskService.getAvatar(for: accountIdentifier) {
            return avatar
        } else {
            featchAvatar(completionHandler: completionHandler)
        }

        return defaultImage
    }

    static func featchAvatar(completionHandler: @escaping ((UIImage?) -> Void)) {
        accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            guard let accountIdentifier = self.accountService?.activeAccount?.identifier else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            PeopleAPI.getAvatarImage(personId: accountIdentifier) { (data, error) in
                if let error = error {
                    AlfrescoLog.error(error)
                } else if let data = data {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            completionHandler(image)
                            DiskService.saveAvatar(image, for: accountIdentifier)
                        }
                    }
                }
            }
        })
    }

    static func fetchProfileInformation(completion: @escaping ((PersonEntry?, Error?) -> Void)) {
        accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            guard let identifier = self.accountService?.activeAccount?.identifier else { return }
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            PeopleAPI.getPerson(personId: identifier) { (personEntry, error) in
                completion(personEntry, error)
            }
        })
    }

    static func featchPersonalFilesID() {
        let nodeOperations = NodeOperations(accountService: accountService)
        nodeOperations.fetchNodeDetails(for: APIConstants.my) { (result, error) in
            if let node = result {
                UserProfile.personalFilesID = node.entry._id
            } else if let error = error {
                AlfrescoLog.error(error)
            }
        }
    }
}
