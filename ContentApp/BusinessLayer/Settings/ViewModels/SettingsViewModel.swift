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

protocol SettingsViewModelDelegate: AnyObject {
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
                                               name: Notification.Name(KeyConstants.Notification.reSignin),
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
            items.append([getLocalProfileItem()])
        }

        items.append([getThemeItem(), getDataPlanItem()])
        items.append([getVersionItem()])

        self.viewModelDelegate?.didUpdateDataSource()
    }

    func performLogOutForCurrentAccount(in viewController: UIViewController) {
        let title = LocalizationConstants.Buttons.signOut
        let message = LocalizationConstants.Settings.signOutConfirmation
        let confirmButtonTitle = LocalizationConstants.General.yes
        let cancelButtonTitle = LocalizationConstants.General.cancel

        let confirmAction = MDCAlertAction(title: confirmButtonTitle) { [weak self] _ in
            guard let sSelf = self else { return }
            appDelegate()?.logoutActionFlow = true
            sSelf.logOutForCurrentAccount(in: viewController)
        }
        confirmAction.accessibilityIdentifier = "confirmActionButton"
        
        let cancelAction = MDCAlertAction(title: cancelButtonTitle) { _ in }
        cancelAction.accessibilityIdentifier = "cancelActionButton"

        if let viewController = viewController as? SystemThemableViewController {
            _ = viewController.showDialog(title: title,
                                          message: message,
                                          actions: [confirmAction, cancelAction]) {}
        }
    }

    // MARK: - ReSignin Notification

    @objc private func handleReSignIn(notification: Notification) {
        reloadRequests()
    }

    // MARK: - Get Settings Items

    private func getDataPlanItem() -> SettingsItem {
        let subtitle = (UserProfile.allowSyncOverCellularData) ?
            LocalizationConstants.Settings.syncWifiAndCellularData :
            LocalizationConstants.Settings.syncOnlyWifi
        return SettingsItem(type: .dataPlan,
                            title: LocalizationConstants.Settings.syncDataPlanTitle,
                            subtitle: subtitle)
    }

    private func getProfileItem(from userProfile: Person) -> SettingsItem {
        UserProfile.persistUserProfile(person: userProfile)
        return getLocalProfileItem()
    }

    private func getLocalProfileItem() -> SettingsItem {
        let avatar = localAvatarImage()
        return SettingsItem(type: .account,
                            title: UserProfile.displayName,
                            subtitle: UserProfile.email,
                            icon: avatar)
    }

    private func getThemeItem() -> SettingsItem {
        let themingService = coordinatorServices?.themingService
        var themeName = LocalizationConstants.Theme.auto

        switch themingService?.getThemeMode() {
        case .light: themeName = LocalizationConstants.Theme.light
        case .dark: themeName = LocalizationConstants.Theme.dark
        default: themeName = LocalizationConstants.Theme.auto
        }
        return SettingsItem(type: .theme,
                            title: LocalizationConstants.Theme.theme,
                            subtitle: themeName)
    }

    private func getVersionItem() -> SettingsItem {
        if let version = Bundle.main.releaseVersionNumber,
           let build = Bundle.main.buildVersionNumber {
            let title = String(format: LocalizationConstants.Settings.appVersion, version, build)
            return SettingsItem(type: .label,
                                title: title,
                                subtitle: "")
        }
        return SettingsItem(type: .label,
                            title: "",
                            subtitle: "")
    }

    // MARK: - Private methods

    private func logOutForCurrentAccount(in viewController: UIViewController) {
        let accountService = coordinatorServices?.accountService
        accountService?.logOutFromCurrentAccount(viewController: viewController,
                                                 completionHandler: { [weak self] (error) in
            guard let sSelf = self, let currentAccount = accountService?.activeAccount
            else { return }

            if error?.responseCode != ErrorCodes.AimsWebview.cancel {
                appDelegate()?.logoutActionFlow = false
                sSelf.coordinatorServices?.syncTriggersService?.invalidateTriggers()
                sSelf.coordinatorServices?.syncService?.stopSync()
                accountService?.delete(account: currentAccount)
                
                // delete pending uploading nodes if user is explicitly log out
                let listNodeDataAccessor = ListNodeDataAccessor()
                listNodeDataAccessor.removeAllPendingUploadNodes()
                sSelf.viewModelDelegate?.logOutWithSuccess()
            }
        })
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
        if let avatar = DiskService.getAvatar(for: accountIdentifier) {
            return avatar
        } else {
            return UIImage(named: "ic-account-circle")
        }
    }
}

// MARK: - MultipleChoiceViewModel Delegate

extension SettingsViewModel: MultipleChoiceViewModelDelegate {
    func chose(item: MultipleChoiceItem, for type: MultipleChoiceDialogType) {
        reloadDataSource()
    }
}
