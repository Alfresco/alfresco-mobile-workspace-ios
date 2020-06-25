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
import AlfrescoAuth
import AlfrescoContentServices

typealias LogoutHandler = (APIError?) -> Void

protocol AccountProtocol: class {
    /// Account identifier string, eg. username
    var identifier: String { get }

    /// Path for which domain specific requests are built
    var apiBasePath: String { get }

    /// Persists the authentication parameters for this account across multiple app launches
    func persistAuthenticationParameters()

    /// Securely persist the authentication credentials across multiple app launches
    func persistAuthenticationCredentials()

    /// Persist the profile user
    func persistUserProfile(person: Person)

    /// Removes authentication parameters for this account
    func removeAuthenticationParameters()

    /// Removes authentication credentials for this account
    func removeAuthenticationCredentials()

    /// Removes user profile for this account
    func removeUserProfile()

    /// Removes disk folder for this account
    func removeDiskFolder()

    /// Returns a valid cached session or recreates one.
    /// - Parameter completionHandler: Authentication provider containing  session credentials
    func getSession(completionHandler: @escaping ((AuthenticationProviderProtocol) -> Void))

    /// Logs out of the current account session.
    /// - Parameters:
    ///   - onViewController: Optional view controller to show the log out context for some authentication types.
    ///   - completionHandler: Success or failure of the operation.
    func logOut(onViewController: UIViewController?, completionHandler: @escaping LogoutHandler)
}
