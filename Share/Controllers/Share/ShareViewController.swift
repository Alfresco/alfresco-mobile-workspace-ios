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
import MobileCoreServices
import AlfrescoAuth
import AlfrescoCore
import AlfrescoContent
import FastCoding
import MaterialComponents.MaterialDialogs

@objc(ShareExtensionViewController)
class ShareViewController: SystemThemableViewController {
    lazy var viewModel = ShareViewModel()
    private var browseScreenCoordinator: BrowseScreenCoordinator?
    
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        clearLocalDatabaseIfNecessary()
        clearDatabaseOnLogout()
        activateTheme()
        handleSharedFile()
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            self.checkForUserSession()
        }
    }
    
    private func activateTheme() {
        viewModel.themingService?.activateAutoTheme(for: UIScreen.main.traitCollection.userInterfaceStyle)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.hidesBackButton = true
    }
    
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = viewModel.themingService?.activeTheme else { return }
        view.backgroundColor = currentTheme.surfaceColor
    }
    
    // MARK: - Check for user session
    func checkForUserSession() {
        if self.viewModel.connectivityService?.hasInternetConnection() == false {
            showAlertInternetUnavailable()
            return
        }
        if let activeAccountIdentifier = UserDefaultsModel.value(for: KeyConstants.Save.activeAccountIdentifier) as? String {
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
    
    private func registerAndPresent(account: AccountProtocol) {
        AlfrescoContentAPI.basePath = account.apiBasePath
        AlfrescoProcessAPI.basePath = account.processAPIBasePath

        viewModel.accountService?.register(account: account)
        viewModel.accountService?.activeAccount = account
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
           self.showBrowseScreen()
        }
    }
    
    private func handleSharedFile() {
        let fetchGroup = DispatchGroup()
        let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        let contentType = kUTTypeData as String
        var urlsArray = [URL]()
        for provider in attachments {
            fetchGroup.enter()
            if provider.hasItemConformingToTypeIdentifier(contentType) {
                provider.loadItem(forTypeIdentifier: contentType,
                                  options: nil) { (data, error) in
                    // Handle the error here if you want
                    guard error == nil else { return }
                    if let url = data as? URL {
                        urlsArray.append(url)
                        fetchGroup.leave()
                    } else if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                        provider.loadItem(forTypeIdentifier: "public.file-url" as String,
                                          options: nil) { (data, error) in
                            // Handle the error here if you want
                            guard error == nil else { return }
                            if let url = data as? URL {
                                urlsArray.append(url)
                                fetchGroup.leave()
                            } else {
        //                         Handle this situation as you prefer
                                Snackbar.display(with: LocalizationConstants.AppExtension.unsupportedFileFormat,
                                                 type: .approve,
                                                 presentationHostViewOverride: self.view,
                                                 finish: nil)
                            }
                        }
                    }
                }
            }
        }
        
        fetchGroup.notify(queue: CameraKit.cameraWorkerQueue) {
            self.saveData(data: urlsArray)
        }
    }
    
    func saveData(data: [URL]) {
        if let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false) {
            UserDefaultsModel.set(value: encodedData, for: KeyConstants.AppGroup.sharedFiles)
        }
    }
}

// MARK: - Show Personal Files
extension ShareViewController {
    
    func showBrowseScreen() {
        if let navigationViewController = self.navigationController {
            let browseNode = BrowseNode(type: .myLibraries)
            let staticScreenCoordinator =
            BrowseScreenCoordinator(with: navigationViewController,
                                                      browseNode: browseNode)
            staticScreenCoordinator.start()
            self.browseScreenCoordinator = staticScreenCoordinator
        }
    }
}
