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

protocol AdvancedSettingsScreenCoordinatorDelegate: class {
    func dismiss()
    func showNeedHelpSheet()
}

class AdvancedSettingsScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var advancedSettingsViewController: AdvancedSettingsViewController?
    private var needHelpCoordinator: NeedHelpCoordinator?

    init(with presenter: UINavigationController) {
        self.presenter = presenter
    }

    func start() {
        let themingService = repository.service(of: MaterialDesignThemingService.identifier) as? MaterialDesignThemingService
        let viewController = AdvancedSettingsViewController.instantiateViewController()
        viewController.themingService = themingService
        viewController.advSettingsScreenCoordinatorDelegate = self
        advancedSettingsViewController = viewController
        presenter.pushViewController(viewController, animated: true)
    }
}

extension AdvancedSettingsScreenCoordinator: AdvancedSettingsScreenCoordinatorDelegate {
    func showNeedHelpSheet() {
        let needHelpCoordinator = NeedHelpCoordinator(with: presenter, model: NeedHelpAdvancedSettingsModel())
        needHelpCoordinator.start()
        self.needHelpCoordinator = needHelpCoordinator
    }

    func dismiss() {
        self.presenter.popViewController(animated: true)
    }
}
