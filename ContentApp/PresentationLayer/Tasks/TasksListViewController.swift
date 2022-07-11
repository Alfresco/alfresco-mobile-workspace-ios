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

class TasksListViewController: SystemSearchViewController {

    weak var tabBarScreenDelegate: TabBarScreenDelegate?
    var tableView = UITableView()
    
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        addSettingsButton(action: #selector(settingsButtonTapped), target: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAvatarInSettingsButton()
        tableView.reloadData()
        AnalyticsManager.shared.pageViewEvent(for: self.title)
    }
    
    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        tableView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
       // collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - IBActions

    @objc func settingsButtonTapped() {
        tabBarScreenDelegate?.showSettingsScreen()
    }
    
    // MARK: - Coordinator Public Methods

    func scrollToTop() {
        // listController?.scrollToSection(0)
    }
}
