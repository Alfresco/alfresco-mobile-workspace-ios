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
import AlfrescoAuth

class AIMSAuthenticationProvider: AuthenticationProviderProtocol {
    let credential: AlfrescoCredential

    init(with credential: AlfrescoCredential) {
        self.credential = credential
    }

    func authorizationHeader() -> String {
        return String("Bearer \(credential.accessToken)")
    }

    func areCredentialsValid() -> Bool {
        guard let accesTokenExpiresIn = credential.accessTokenExpiresIn else { return false }
        let tokenExpireDate = Date(timeIntervalSince1970: TimeInterval(accesTokenExpiresIn))
        //Substract sessionExpirationTimeIntervalCheck time
        let currentDateThreshold = tokenExpireDate.addingTimeInterval(-TimeInterval(kSessionExpirationTimeIntervalCheck))

        if Date().compare(currentDateThreshold) == .orderedDescending ||
            Date().compare(tokenExpireDate) == .orderedDescending {
            return false
        }

        return true
    }

}
