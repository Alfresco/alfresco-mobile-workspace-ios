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

protocol SettingsScreenCoordinatorDelegate: class {
    func showThemesModeScreen()
    func showLoginScreen()
}

class SettingsScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var settingsViewController: SettingsViewController?
    private var themesModeCoordinator: ThemesModeScreenCoordinator?

    init(with presenter: UINavigationController) {
        self.presenter = presenter
    }

    func start() {
        let viewController = SettingsViewController.instantiateViewController()
        let themingService = self.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        let accountService = self.serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService
        viewController.themingService = themingService
        let viewModel = SettingsViewModel(themingService: themingService, accountService: accountService)
        viewModel.viewModelDelegate = viewController
        viewController.viewModel = viewModel
        viewController.settingsScreenCoordinatorDelegate = self
        viewController.hidesBottomBarWhenPushed = true
        presenter.pushViewController(viewController, animated: true)
        settingsViewController = viewController
    }
}

extension SettingsScreenCoordinator: SettingsScreenCoordinatorDelegate {
    func showLoginScreen() {

    }

    func showThemesModeScreen() {
        if let settingsViewController = self.settingsViewController {
            let themesModeCoordinator = ThemesModeScreenCoordinator(with: self.presenter, settingsScreen: settingsViewController)
            themesModeCoordinator.start()
            self.themesModeCoordinator = themesModeCoordinator
        }
    }
}
