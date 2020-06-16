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

protocol AimsScreenCoordinatorDelegate: class {
    func showNeedHelpSheet()
}

class AimsScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private let splashScreen: SplashViewController
    private var aimsViewController: AimsViewController?
    private var needHelpCoordinator: NeedHelpCoordinator?

    init(with presenter: UINavigationController, splashScreen: SplashViewController) {
        self.presenter = presenter
        self.splashScreen = splashScreen
    }

    func start() {
        let viewController = AimsViewController.instantiateViewController()
        viewController.aimsScreenCoordinatorDelegate = self
        viewController.themingService = self.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        viewController.viewModel = AimsViewModel(with: self.serviceRepository.service(of: AuthenticationService.serviceIdentifier) as? AuthenticationService,
                                                 accountService: self.serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService)
        viewController.splashScreenDelegate = self.splashScreen
        presenter.pushViewController(viewController, animated: kPushAnimation)
        aimsViewController = viewController
    }
}

extension AimsScreenCoordinator: AimsScreenCoordinatorDelegate {
    func showNeedHelpSheet() {
        let needHelpCoordinator = NeedHelpCoordinator(with: presenter, model: NeedHelpAIMSModel())
        needHelpCoordinator.start()
        self.needHelpCoordinator = needHelpCoordinator
    }
}
