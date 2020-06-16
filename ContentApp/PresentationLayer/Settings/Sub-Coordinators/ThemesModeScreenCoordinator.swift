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
import MaterialComponents.MaterialDialogs

class ThemesModeScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var themeModeViewController: ThemesModeViewController?
    private var settingsViewController: SettingsViewController

    init(with presenter: UINavigationController, settingsScreen: SettingsViewController) {
        self.presenter = presenter
        self.settingsViewController = settingsScreen
    }

    func start() {
        let dialogTransitionController = MDCDialogTransitionController()
        let viewController = ThemesModeViewController.instantiateViewController()
        viewController.themingService = self.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        viewController.delegate = self.settingsViewController
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = dialogTransitionController
        presenter.present(viewController, animated: true)
        themeModeViewController = viewController
    }
}
