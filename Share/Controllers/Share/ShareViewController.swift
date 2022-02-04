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
