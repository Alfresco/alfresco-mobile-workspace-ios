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
import JWTDecode

class AIMSAccount: AccountProtocol {
    var identifier: String {
        guard let token = credential.accessToken else { return "" }

        do {
            let jwt = try decode(jwt: token)
            let claim = jwt.claim(name: "email")
            if let email = claim.string {
                return email
            }
        } catch {
            AlfrescoLog.error("Unable to decode account token for extracting account identifier")
        }

        return ""
    }
    var session: AccountSessionProtocol
    var authParams: AuthenticationParameters
    var credential: AlfrescoCredential

    init(with session: AccountSessionProtocol, authParams: AuthenticationParameters, credential: AlfrescoCredential) {
        self.session = session
        self.authParams = authParams
        self.credential = credential
    }
}
