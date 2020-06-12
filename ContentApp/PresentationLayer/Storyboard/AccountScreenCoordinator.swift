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

protocol AccountScreenCoordinatorDelegate: class {
    func showThemesModeScreen()
}

class AcccountScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var accountViewController: AccountViewController?
    private var themesModeCoordinator: ThemesModeScreenCoordinator?

    init(with presenter: UINavigationController) {
        self.presenter = presenter
    }

    func start() {
        let viewController = AccountViewController.instantiateViewController()
        viewController.themingService = self.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        viewController.accountScreenCoordinatorDelegate = self
        presenter.pushViewController(viewController, animated: true)
        accountViewController = viewController
    }
}

extension AcccountScreenCoordinator: AccountScreenCoordinatorDelegate {
    func showThemesModeScreen() {
        if let accountViewController = self.accountViewController {
            let themesModeCoordinator = ThemesModeScreenCoordinator(with: self.presenter, accountScreen: accountViewController)
            themesModeCoordinator.start()
            self.themesModeCoordinator = themesModeCoordinator
        }
    }
}
