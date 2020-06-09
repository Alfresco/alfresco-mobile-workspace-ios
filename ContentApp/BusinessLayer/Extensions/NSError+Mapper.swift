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
import AlfrescoCore
import AlfrescoAuth

extension APIError {

    func mapToMessage() -> String {

        let genericError = String(format: LocalizationConstants.Errors.generic, self.responseCode)
        switch self.responseCode {
        case 1000..<1999: //AlfrescoCore
           return genericError
        case ModuleErrorType.errorIssuerNil.code:
            return LocalizationConstants.Errors.checkConnectURL
        case ModuleErrorType.errorAuthenticationServiceNotFound.code:
            return LocalizationConstants.Errors.noAuthAlfrescoURL
        case ModuleErrorType.errorUsernameNotEmpty.code, ModuleErrorType.errorPasswordNotEmpty.code:
            return self.localizedDescription
        case 401:
            return LocalizationConstants.Errors.wrongCredentials
        default:
            return genericError
        }
    }
}
