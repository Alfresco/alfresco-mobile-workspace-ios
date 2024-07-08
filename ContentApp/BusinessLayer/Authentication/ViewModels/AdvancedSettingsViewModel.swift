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

class AdvancedSettingsViewModel {
    var authParameters = AuthenticationParameters.parameters()

    func resetAuthParameters() {
        authParameters = AuthenticationParameters()
    }

    func saveFields(https: Bool, port: String?, path: String?, realm: String?, clientID: String?, authType: AvailableAuthType?, authTypeID: String?) {
        authParameters.https = https
        authParameters.port = port ?? ""
        authParameters.path = path ?? ""
        authParameters.realm = realm ?? ""
        authParameters.clientID = clientID ?? ""
        authParameters.authType = authType ?? AvailableAuthType.aimsAuth
        authParameters.authTypeID = authTypeID ?? ""
        authParameters.save()
    }
}
