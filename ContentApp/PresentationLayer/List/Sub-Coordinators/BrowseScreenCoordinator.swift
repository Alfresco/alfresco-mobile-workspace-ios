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

protocol BrowseScreenCoordinatorDelegate: class {
    func showScreen(from browseNode: BrowseNode)
}

class BrowseScreenCoordinator: Coordinator {
    private let presenter: TabBarMainViewController
    private var browseViewController: BrowseViewController?
    private var navigationViewController: UINavigationController?
    private var staticFolderScreenCoordinator: StaticFolderScreenCoordinator?

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }

    func start() {
        let viewController = BrowseViewController.instantiateViewController()
        viewController.title = LocalizationConstants.ScreenTitles.browse
        viewController.themingService = self.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        viewController.listViewModel = BrowseViewModel()
        viewController.browseScreenCoordinatorDelegate = self
        let navigationViewController = UINavigationController(rootViewController: viewController)
        self.presenter.viewControllers?.append(navigationViewController)
        self.navigationViewController = navigationViewController
        self.browseViewController = viewController
    }
}

extension BrowseScreenCoordinator: BrowseScreenCoordinatorDelegate {
    func showScreen(from browseNode: BrowseNode) {
        if let navigationViewController = self.navigationViewController {
            let staticFolderScreenCoordinator = StaticFolderScreenCoordinator(with: navigationViewController, browseNode: browseNode)
            staticFolderScreenCoordinator.start()
            self.staticFolderScreenCoordinator = staticFolderScreenCoordinator
        }
    }
}
