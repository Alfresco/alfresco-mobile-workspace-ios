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

protocol TabBarScreenDelegate: class {
    func showSettingsScreen()
}

class TabBarMainViewController: UITabBarController {

    var themingService: MaterialDesignThemingService?
    weak var tabBarCoordinatorDelegate: TabBarScreenCoordinatorDelegate?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarCoordinatorDelegate?.showRecentScreen()
        tabBarCoordinatorDelegate?.showFavoritesScreen()
        addLocalization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        addMaterialComponentsTheme()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        themingService?.configureNoAutoTheme()
        addMaterialComponentsTheme()
    }

    // MARK: - Helpers

    func addLocalization() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    func addMaterialComponentsTheme() {
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.tintColor = .label
        } else {
            navigationController?.navigationBar.tintColor = .black
        }

    }
}

// MARK: - TabBarScreen Delegate

extension TabBarMainViewController: TabBarScreenDelegate {
    func showSettingsScreen() {
        tabBarCoordinatorDelegate?.showSettingsScreen()
    }
}

// MARK: - Storyboard Instantiable

extension TabBarMainViewController: StoryboardInstantiable { }
