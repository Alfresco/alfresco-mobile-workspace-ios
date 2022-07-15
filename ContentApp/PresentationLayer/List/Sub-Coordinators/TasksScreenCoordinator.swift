//
// Copyright (C) 2005-2022 Alfresco Software Limited.
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

class TasksScreenCoordinator: PresentingCoordinator {

    private let presenter: TabBarMainViewController
    private var tasksViewController: TasksListViewController?
    private var navigationViewController: UINavigationController?

    init(with presenter: TabBarMainViewController) {
        self.presenter = presenter
    }
    
    override func start() {
        let storyboard = UIStoryboard(name: "Tasks", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "TasksListViewController") as? TasksListViewController {
            viewController.title = LocalizationConstants.ScreenTitles.tasks
            
            viewController.coordinatorServices = coordinatorServices
            viewController.tabBarScreenDelegate = presenter
            
            let navigationViewController = UINavigationController(rootViewController: viewController)
            presenter.viewControllers?.append(navigationViewController)
            self.navigationViewController = navigationViewController
            tasksViewController = viewController
        }
    }
    
    func scrollToTopOrPopToRoot() {
        if navigationViewController?.viewControllers.count == 1 {
            tasksViewController?.scrollToTop()
        } else {
            navigationViewController?.popToRootViewController(animated: true)
        }
        tasksViewController?.cancelSearchMode()
    }
}
