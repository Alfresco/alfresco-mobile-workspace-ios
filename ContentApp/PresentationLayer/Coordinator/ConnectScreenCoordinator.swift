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

protocol ConnectScreenCoordinatorDelegate: class {
    func showAdvancedSettingsScreen()
    func showAimsScreen()
}

class ConnectScreenCoordinator: Coordinator {
    private let presenter: SplashViewController
    private var connectViewController: ConnectViewController?
    private var containerViewNavigationController: UINavigationController?
    private var advancedSettingsCoordinator: AdvancedSettingsScreenCoordinator?
    private var aimsCoordinator: AimsScreenCoordinator?

    init(with presenter: SplashViewController) {
        self.presenter = presenter
    }

    func start() {
        let connectViewController = ConnectViewController.instantiateViewController()
        connectViewController.splashScreenDelegate = presenter
        connectViewController.connectScreenCoordinatorDelegate = self
        let containerViewNavigationController = UINavigationController(rootViewController: connectViewController)

        presenter.addChild(containerViewNavigationController)
        containerViewNavigationController.view.frame = CGRect(x: 0, y: 0, width: presenter.containerView.frame.size.width, height: presenter.containerView.frame.size.height)
        presenter.containerView.addSubview(containerViewNavigationController.view)
        containerViewNavigationController.didMove(toParent: presenter)

        self.connectViewController = connectViewController
        self.containerViewNavigationController = containerViewNavigationController
    }
}

extension ConnectScreenCoordinator: ConnectScreenCoordinatorDelegate {
    func showAdvancedSettingsScreen() {
        if let containerViewNavigationController = self.containerViewNavigationController {
            let advancedSettingsCoordinator = AdvancedSettingsScreenCoordinator(with: containerViewNavigationController)
            advancedSettingsCoordinator.start()

            self.advancedSettingsCoordinator = advancedSettingsCoordinator
        }
    }


    func showAimsScreen() {
        if let containerViewNavigationController = self.containerViewNavigationController {
            let aimsCoordinator = AimsScreenCoordinator(with: containerViewNavigationController)
            aimsCoordinator.start()

            self.aimsCoordinator = aimsCoordinator
        }
    }
}
