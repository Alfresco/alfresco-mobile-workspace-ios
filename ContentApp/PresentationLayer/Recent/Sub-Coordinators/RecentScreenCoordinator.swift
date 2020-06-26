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

class RecentScreenCoordinator: Coordinator {
    private let presenter: TabBarMainViewController
    private var recentViewController: RecentViewController?
    private var navigationViewController: UINavigationController?

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }

    func start() {
        let viewController = RecentViewController.instantiateViewController()
        viewController.themingService = self.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        let accountService = self.serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService
        viewController.viewModel = RecentViewModel(accountService: accountService)
        viewController.tabBarScreenDelegate = presenter
        viewController.tabBarItem = UITabBarItem(title: LocalizationConstants.ScreenTitles.recent,
                                                 image: UIImage(named: "recent-selected"), selectedImage: UIImage(named: "recent-unselecte"))
        let navigationViewController = UINavigationController(rootViewController: viewController)
        presenter.viewControllers = [navigationViewController]
        self.navigationViewController = navigationViewController
        self.recentViewController = viewController
    }
}
