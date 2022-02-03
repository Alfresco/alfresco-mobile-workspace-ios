//
// Copyright (C) 2005-2022 Alfresco Software Limited.
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
import Social
import MobileCoreServices
import UniformTypeIdentifiers
import AlfrescoAuth
import AlfrescoCore
import AlfrescoContent
import JWTDecode
import FastCoding
import MaterialComponents.MaterialDialogs


@objc(ShareExtensionViewController)
class ShareViewController: UIViewController {
//    private (set) var parameters = AuthenticationParameters.parameters()
//    private (set) lazy var alfrescoAuth: AlfrescoAuth = {
//        let authConfig = parameters.authenticationConfiguration()
//        return AlfrescoAuth(configuration: authConfig)
//    }()
//
//    private (set) var session: AlfrescoAuthSession?
//    var apiClient: APIClientProtocol?
//    private (set) var credential: AlfrescoCredential?
//    private var refreshGroup = DispatchGroup()
//    private var refreshGroupRequestCount = 0
//    private var refreshInProgress = false
//    private var refreshTimer: Timer?
//    private let refreshTimeBuffer = 20.0
//    private var logoutHandler: LogoutHandler?
//
//
    lazy var viewModel = ShareViewModel()
    
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Jai Shri Ram. JHMPPWPBJASHJH")
       // handleSharedFile()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.checkForUserSession()
        }
    }
    
    // MARK: - Check for user session
    func checkForUserSession() {
        let userDefaults = UserDefaults(suiteName: KeyConstants.AppGroup.name)
        if let activeAccountIdentifier = userDefaults?.value(forKey: KeyConstants.Save.activeAccountIdentifier) as? String {
            let parameters = AuthenticationParameters.parameters(for: activeAccountIdentifier)

            // Check account type whether it's Basic or AIMS
            if let activeAccountPassword = Keychain.string(forKey: activeAccountIdentifier) {
                let basicAuthCredential = BasicAuthCredential(username: activeAccountIdentifier, password: activeAccountPassword)
                let account = BasicAuthAccount(with: parameters, credential: basicAuthCredential)
                registerAndPresent(account: account)
                
            } else if let activeAccountSessionData = Keychain.data(forKey: "\(activeAccountIdentifier)-\(String(describing: AlfrescoAuthSession.self))"),
                let activeAccountCredentialData = Keychain.data(forKey: "\(activeAccountIdentifier)-\(String(describing: AlfrescoCredential.self))") {
                do {
                    let decoder = JSONDecoder()

                    if let aimsSession = FastCoder.object(with: activeAccountSessionData) as? AlfrescoAuthSession {
                        let aimsCredential = try decoder.decode(AlfrescoCredential.self, from: activeAccountCredentialData)

                        let accountSession = AIMSSession(with: aimsSession, parameters: parameters, credential: aimsCredential)
                        let account = AIMSAccount(with: accountSession)
                        registerAndPresent(account: account)
                    }
                } catch {
                    AlfrescoLog.error("Unable to deserialize session information")
                }
            } else {
                showAlertToRegisterInTheApp()
            }
        } else {
            showAlertToRegisterInTheApp()
        }
    }
    
    private func showAlertToRegisterInTheApp() {
        let title = LocalizationConstants.Dialog.sessionUnavailableTitle
        let message = LocalizationConstants.Dialog.sessionUnavailableMessage
        let confirmAction = MDCAlertAction(title: LocalizationConstants.General.ok) { [weak self] _ in
            guard let sSelf = self else { return }
            sSelf.openMainApp()
        }
        confirmAction.accessibilityIdentifier = "confirmActionButton"
        _ = self.showDialog(title: title,
                                       message: message,
                                       actions: [confirmAction],
                                       completionHandler: {})
    }
    
    private func openMainApp() {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: { _ in
            guard let url = URL(string: KeyConstants.AppGroup.appURLString) else { return }
            _ = self.openURL(url)
        })
    }
    
    @objc private func handleUnauthorizedAPIAccess() {
        let title = LocalizationConstants.Dialog.sessionExpiredTitle
        let message = LocalizationConstants.Dialog.sessionExpiredMessage

        let confirmAction = MDCAlertAction(title: LocalizationConstants.Buttons.signin) { [weak self] _ in
            guard let sSelf = self else { return }
            //if let viewController = viewController {
            //    sSelf.accountService?.activeAccount?.reSignIn(onViewController: viewController)
            //}
        }
        confirmAction.accessibilityIdentifier = "confirmActionButton"
        
        let cancelAction = MDCAlertAction(title: LocalizationConstants.General.cancel) { _ in
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
        cancelAction.accessibilityIdentifier = "cancelActionButton"

        _ = self.showDialog(title: title,
                                       message: message,
                                       actions: [confirmAction, cancelAction],
                                       completionHandler: {})
    }
    
    private func registerAndPresent(account: AccountProtocol) {
        AlfrescoContentAPI.basePath = account.apiBasePath
        self.viewModel.accountService?.register(account: account)
        self.viewModel.accountService?.activeAccount = account
        getFilesAndFolder()
    }
    
    func getFilesAndFolder() {
        print("Get Files and Folders")
//        let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
//        if let controller = storyboard.instantiateViewController(withIdentifier: "BrowseViewController") as? BrowseViewController {
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        print("loginButtonAction")
        let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "BrowseViewController") as? BrowseViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func reSignIn() {
        //alfrescoAuth.update(configuration: (parameters.authenticationConfiguration()))
       // alfrescoAuth.pkceAuth(onViewController: self, delegate: self)
    }
        
    private func handleSharedFile() {
        // extracting the path to the URL that is being shared
        let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        let contentType = kUTTypeData as String
        for provider in attachments {
            // Check if the content type is the same as we expected
            if provider.hasItemConformingToTypeIdentifier(contentType) {
                provider.loadItem(forTypeIdentifier: contentType,
                                  options: nil) { [unowned self] (data, error) in
                    // Handle the error here if you want
                    guard error == nil else { return }
                    
                    if let url = data as? URL,
                       let imageData = try? Data(contentsOf: url) {
                        //self.save(imageData, key: "imageData", value: imageData)
                      //  self.viewModel.appURLString += "imageData"
                    } else {
                        // Handle this situation as you prefer
                        fatalError("Impossible to save image")
                    }
                }}
        }
    }
      
    private func save(_ data: Data, key: String, value: Any) {
      // You must use the userdefaults of an app group, otherwise the main app don't have access to it.
        let userDefaults = UserDefaults(suiteName: KeyConstants.AppGroup.name)
        userDefaults?.set(data, forKey: key)
        // self.dismissController()
    }
    
    func dismissController() {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    func pushToNextController() {
//        let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
//        if let controller = storyboard.instantiateViewController(withIdentifier: "ShareViewControllerList") as? ShareViewControllerList {
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
    }
    
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
    
    
    
    
    
    
    

    
    
}

// MARK: - AlfrescoAuth Delegate

/*
extension ShareViewController: AlfrescoAuthDelegate {
    func didReceive(result: Result<AlfrescoCredential?, APIError>,
                    session: AlfrescoAuthSession?) {
        if let credential = self.credential {
            persist(oldCredentials: credential)
        }
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
                // re sign in user
                //delegate?.didReSignIn(check: self.oldIdentifier())
            }
        case .failure(let error):
            
            AlfrescoLog.error("Failed to refresh access token. Reason: \(error)")
            let errorDict = ["error": error]
            invalidateSessionRefresh()
            let notification = NSNotification.Name(rawValue: KeyConstants.Notification.unauthorizedRequest)
            NotificationCenter.default.post(name: notification,
                                            object: nil,
                                            userInfo: errorDict)
        }
        refreshInProgress = false
        dequeueRefreshOperationRequests()
    }

    func didLogOut(result: Result<Int, APIError>, session: AlfrescoAuthSession?) {
        if let handler = logoutHandler {
            switch result {
            case .success(_):
                AlfrescoLog.debug("Succesfully logged out.")
                if let refreshedSession = session {
                    self.session = refreshedSession
                }
                invalidateSessionRefresh()
                handler(nil)
            case .failure(let error):
                AlfrescoLog.error("Failed to log out. Reason: \(error)")
                if error.responseCode != ErrorCodes.AimsWebview.cancel {
                    self.session = nil
                    invalidateSessionRefresh()
                }
                handler(error)
            }
        }
    }
    
    // MARK: - Public Helpers
    func persistAuthenticationCredentials() {
        do {
            if let authSession = session {
                let credentialData = try JSONEncoder().encode(credential)
                let sessionData = FastCoder.data(withRootObject: authSession)
                let sessionKey = "\(identifier)-\(String(describing: AlfrescoAuthSession.self))"

                if let ecodedSessionData = sessionData {
                    _ = Keychain.set(value: ecodedSessionData,
                                     forKey: sessionKey)
                }

                let credentialKey = "\(identifier)-\(String(describing: AlfrescoCredential.self))"

                _ = Keychain.set(value: credentialData,
                                 forKey: credentialKey)
            }
        } catch {
            AlfrescoLog.error("Unable to persist credentials to Keychain.")
        }
    }

    func persist(oldCredentials: AlfrescoCredential) {
        do {
            let credentialData = try JSONEncoder().encode(oldCredentials)
            let credentialKey = "oldCredentials-\(String(describing: AlfrescoCredential.self))"
            _ = Keychain.set(value: credentialData, forKey: credentialKey)
        } catch {
            AlfrescoLog.error("Unable to persist credentials to Keychain.")
        }
    }

    func oldIdentifier() -> String {
        if let data = Keychain.data(forKey: "oldCredentials-\(String(describing: AlfrescoCredential.self))") {
            do {
                let decoder = JSONDecoder()
                let aimsCredential = try decoder.decode(AlfrescoCredential.self, from: data)
                return extractUsername(from: aimsCredential.accessToken)
            } catch {
                AlfrescoLog.error("Unable to deserialize session information")
            }
        }
        return ""
    }
    
    func scheduleSessionRefresh() {
        if let accessTokenExpiresIn = self.credential?.accessTokenExpiresIn {
            let aimsAccesstokenRefreshInterval = TimeInterval(accessTokenExpiresIn)
                - Date().timeIntervalSince1970 - TimeInterval(refreshTimeBuffer)

            if aimsAccesstokenRefreshInterval < TimeInterval(refreshTimeBuffer) {
                return
            }
            refreshTimer?.invalidate()
            refreshTimer = Timer.scheduledTimer(withTimeInterval: aimsAccesstokenRefreshInterval,
                                                repeats: true,
                                                block: { [weak self] _ in
                guard let sSelf = self else { return }
                sSelf.refreshSession(completionHandler: nil)
            })
        }
    }
    
    func invalidateSessionRefresh() {
        refreshTimer?.invalidate()
    }

    private func dequeueRefreshOperationRequests() {
        for _ in 0..<refreshGroupRequestCount {
            refreshGroup.leave()
        }
        refreshGroupRequestCount = 0
    }
    
    private func extractUsername(from accessToken: String?) -> String {
        guard let token = accessToken else { return "" }

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
}
*/
