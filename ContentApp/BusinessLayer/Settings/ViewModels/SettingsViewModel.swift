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
import AlfrescoContent
import AlfrescoAuth
import MaterialComponents.MaterialDialogs

protocol SettingsViewModelDelegate: class {
    func didUpdateDataSource()
    func logOutWithSuccess()
    func displayError(message: String)
}

class SettingsViewModel {
    var items: [[SettingsItem]] = []
    var userProfile: PersonEntry?
    var coordinatorServices: CoordinatorServices?
    weak var viewModelDelegate: SettingsViewModelDelegate?

    // MARK: - Init

    init(with coordinatorServices: CoordinatorServices?) {
        self.coordinatorServices = coordinatorServices
        reloadDataSource()
        reloadRequests()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleReSignIn(notification:)),
                                               name: Notification.Name(kReSignInNotification),
                                               object: nil)
    }

    // MARK: - Public methods

    func reloadRequests() {
        fetchAvatar()
        fetchProfileInformation()
    }

    func reloadDataSource() {
        items = []

        if let userProfile = userProfile?.entry {
           items.append([getProfileItem(from: userProfile)])
        } else {
            if let profileItem = getLocalProfileItem() {
                items.append([profileItem])
            }
        }
        if #available(iOS 13.0, *) {
            items.append([getThemeItem()])
        }
        items.append([getVersionItem()])

        self.viewModelDelegate?.didUpdateDataSource()
    }

    func performLogOutForCurrentAccount(in viewController: UIViewController) {
        let title = LocalizationConstants.Buttons.signOut
        let message = LocalizationConstants.Settings.signOutConfirmation
        let confirmButtonTitle = LocalizationConstants.Buttons.yes
        let cancelButtonTitle = LocalizationConstants.Buttons.cancel

        let confirmAction = MDCAlertAction(title: confirmButtonTitle) { [weak self] _ in
            guard let sSelf = self else { return }
            sSelf.logOutForCurrentAccount(in: viewController)
        }
        let cancelAction = MDCAlertAction(title: cancelButtonTitle) { _ in }

        if let viewController = viewController as? SystemThemableViewController {
            _ = viewController.showDialog(title: title,
                                          message: message,
                                          actions: [confirmAction, cancelAction]) {}
        }
    }

    // MARK: - ReSignin

    @objc private func handleReSignIn(notification: Notification) {
        reloadRequests()
    }

    // MARK: - Private methods

    private func logOutForCurrentAccount(in viewController: UIViewController) {
        let accountService = coordinatorServices?.accountService
        accountService?.logOutFromCurrentAccount(viewController: viewController,
                                                 completionHandler: { [weak self] (error) in
            guard let sSelf = self, let currentAccount = accountService?.activeAccount
            else { return }

            if error?.responseCode != kLoginAIMSCancelWebViewErrorCode {
                currentAccount.removeAuthenticationCredentials()
                currentAccount.removeAuthenticationParameters()
                currentAccount.removeDiskFolder()

                let listNodeDataAccessor = ListNodeDataAccessor()
                listNodeDataAccessor.removeAllNodes()

                UserProfile.removeUserProfile(withAccountIdentifier: currentAccount.identifier)
                sSelf.viewModelDelegate?.logOutWithSuccess()
            }
        })
    }

    private func getProfileItem(from userProfile: Person) -> SettingsItem {
        var profileName = userProfile.firstName
        if let lastName = userProfile.lastName {
            profileName = "\(profileName) \(lastName)"
        }
        if let displayName = userProfile.displayName {
            profileName = displayName
        }
        let avatar = localAvatarImage()

        UserProfile.persistUserProfile(person: userProfile)
        return SettingsItem(type: .account,
                            title: profileName,
                            subtitle: userProfile.email,
                            icon: avatar)
    }

    private func getLocalProfileItem() -> SettingsItem? {
        let avatar = localAvatarImage()
        return SettingsItem(type: .account,
                            title: UserProfile.getProfileName(),
                            subtitle: UserProfile.getEmail(),
                            icon: avatar)
    }

    private func getThemeItem() -> SettingsItem {
        let themingService = coordinatorServices?.themingService
        var themeName = LocalizationConstants.Theme.auto

        switch themingService?.getThemeMode() {
        case .light:
             themeName = LocalizationConstants.Theme.light
        case .dark:
            themeName = LocalizationConstants.Theme.dark
        default:
            themeName = LocalizationConstants.Theme.auto
        }
        return SettingsItem(type: .theme,
                            title: LocalizationConstants.Theme.theme,
                            subtitle: themeName,
                            icon: UIImage(named: "ic-theme"))
    }

    private func getVersionItem() -> SettingsItem {
        if let version = Bundle.main.releaseVersionNumber,
           let build = Bundle.main.buildVersionNumber {
            return SettingsItem(type: .label,
                                title: String(format: LocalizationConstants.Settings.appVersion,
                                              version, build),
                                subtitle: "",
                                icon: nil)
        }
        return SettingsItem(type: .label,
                            title: "",
                            subtitle: "",
                            icon: nil)
    }

    private func fetchAvatar() {
        ProfileService.featchAvatar { (_) in
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                sSelf.reloadDataSource()
            }
        }
    }

    private func fetchProfileInformation() {
        ProfileService.fetchProfileInformation { [weak self] (personEntry, error) in
            guard let sSelf = self else { return }
            if let error = error {
                AlfrescoLog.error(error)
                sSelf.viewModelDelegate?.displayError(message: LocalizationConstants.Settings.failedProfileInfo)
            } else {
                sSelf.userProfile = personEntry
                DispatchQueue.main.async {
                    sSelf.reloadDataSource()
                }
            }
        }
    }

    private func localAvatarImage() -> UIImage? {
        let accountService = coordinatorServices?.accountService
        guard let accountIdentifier = accountService?.activeAccount?.identifier
        else { return nil }
        return DiskService.getAvatar(for: accountIdentifier)
    }
}
