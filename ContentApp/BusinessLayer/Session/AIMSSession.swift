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
import AlfrescoContent
import JWTDecode

class AIMSSession {
    weak var delegate: AIMSAccountDelegate?

    var identifier: String {
        guard let token = credential?.accessToken else { return "" }

        do {
            let jwt = try decode(jwt: token)
            let claim = jwt.claim(name: "preferred_username")
            if let preferredusername = claim.string {
                return preferredusername
            }
        } catch {
            AlfrescoLog.error("Unable to decode account token for extracting account identifier")
        }

        return ""
    }

    private (set) var session: AlfrescoAuthSession?
    private var alfrescoAuth: AlfrescoAuth?
    private (set) var parameters: AuthenticationParameters
    private (set) var credential: AlfrescoCredential?

    private var refreshGroup = DispatchGroup()
    private var refreshGroupRequestCount = 0
    private var refreshInProgress = false

    private var refreshTimer: Timer?
    private var logoutHandler: LogoutHandler?

    init(with session: AlfrescoAuthSession, parameters: AuthenticationParameters, credential: AlfrescoCredential) {
        self.session = session
        self.parameters = parameters
        self.credential = credential
        let authConfig = parameters.authenticationConfiguration()
        self.alfrescoAuth = AlfrescoAuth.init(configuration: authConfig)
        scheduleSessionRefresh()
    }

    func persistAuthenticationCredentials() {
        do {
            if let authSession = session {
                let credentialData = try JSONEncoder().encode(credential)
                let sessionData = try NSKeyedArchiver.archivedData(withRootObject: authSession, requiringSecureCoding: true)

                _ = Keychain.set(value: credentialData, forKey: "\(identifier)-\(String(describing: AlfrescoCredential.self))")
                _ = Keychain.set(value: sessionData, forKey: "\(identifier)-\(String(describing: AlfrescoAuthSession.self))")
            }
        } catch {
            AlfrescoLog.error("Unable to persist credentials to Keychain.")
        }
    }

    func refreshSession(completionHandler: ((AlfrescoCredential) -> Void)?) {
        queueRefreshOperationRequest()

        if !refreshInProgress {
            refreshInProgress = true

            alfrescoAuth?.update(configuration: parameters.authenticationConfiguration())

            if let session = self.session {
                alfrescoAuth?.pkceRefresh(session: session, delegate: self)
            }
        }

        refreshGroup.notify(queue: DispatchQueue.main) {
            if let credential = self.credential {
                if let completionHandler = completionHandler {
                    completionHandler(credential)
                }
            }
        }
    }

    func invalidateSessionRefresh() {
        refreshTimer?.invalidate()
    }

    func logOut(onViewController viewController: UIViewController, completionHandler: @escaping LogoutHandler) {
        logoutHandler = completionHandler
        alfrescoAuth?.update(configuration: parameters.authenticationConfiguration())
        if let credential = self.credential, let session = self.session {
            alfrescoAuth?.logout(onViewController: viewController, delegate: self, session: session, forCredential: credential)
        }
    }

    func reSignIn(onViewController viewController: UIViewController) {
        alfrescoAuth?.update(configuration: parameters.authenticationConfiguration())
        alfrescoAuth?.pkceAuth(onViewController: viewController, delegate: self)
    }

    private func scheduleSessionRefresh() {
        if let accessTokenExpiresIn = self.credential?.accessTokenExpiresIn {
            let aimsAccesstokenRefreshInterval = TimeInterval(accessTokenExpiresIn) - Date().timeIntervalSince1970 - TimeInterval(kAIMSAccessTokenRefreshTimeBuffer)

            if aimsAccesstokenRefreshInterval < TimeInterval(kAIMSAccessTokenRefreshTimeBuffer) {
                return
            }
            refreshTimer?.invalidate()
            refreshTimer = Timer.scheduledTimer(withTimeInterval: aimsAccesstokenRefreshInterval, repeats: true, block: { [weak self] _ in
                guard let sSelf = self else { return }
                sSelf.refreshSession(completionHandler: nil)
            })
        }
    }

    private func queueRefreshOperationRequest() {
        refreshGroup.enter()
        refreshGroupRequestCount+=1
    }

    private func dequeueRefreshOperationRequests() {
        for _ in 0..<refreshGroupRequestCount {
            refreshGroup.leave()
        }

        refreshGroupRequestCount = 0
    }
}

extension AIMSSession: AlfrescoAuthDelegate {
    func didReceive(result: Result<AlfrescoCredential, APIError>, session: AlfrescoAuthSession?) {
        switch result {
        case .success(let credential):
            if let refreshedSession = session {
                self.session = refreshedSession
                self.credential = credential
            }
            persistAuthenticationCredentials()
            scheduleSessionRefresh()

            // Check if the new credentials are part of a resign-in action
            if refreshGroupRequestCount == 0 {
                delegate?.didReSignIn()
            }
        case .failure(let error):
            AlfrescoLog.error("Failed to refresh access token. Reason: \(error)")
            let errorDict = ["error": error]
            invalidateSessionRefresh()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kAPIUnauthorizedRequestNotification), object: nil, userInfo: errorDict)
        }
        refreshInProgress = false
        dequeueRefreshOperationRequests()
    }

    func didLogOut(result: Result<Int, APIError>) {
        if let handler = logoutHandler {
            switch result {
            case .success(_):
                AlfrescoLog.debug("Succesfully logged out.")
                session = nil
                invalidateSessionRefresh()
                handler(nil)
            case .failure(let error):
                AlfrescoLog.error("Failed to log out. Reason: \(error)")
                if error.responseCode != kLoginAIMSCancelWebViewErrorCode {
                    session = nil
                    invalidateSessionRefresh()
                }
                handler(error)
            }
        }
    }
}
