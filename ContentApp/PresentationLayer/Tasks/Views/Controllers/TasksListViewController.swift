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

    private let searchButtonAspectRatio: CGFloat = 30.0
    weak var tabBarScreenDelegate: TabBarScreenDelegate?
    var tableView = UITableView()
    private var searchController: UISearchController?
    private var resultsViewController: SearchTasksViewController?

    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        addSettingsButton(action: #selector(settingsButtonTapped), target: self)
        searchController = createSearchController()
        navigationItem.searchController = searchController
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
    
    private func createSearchController() -> UISearchController {
        
        let storyboard = UIStoryboard(name: "Tasks", bundle: nil)
        let rvc = storyboard.instantiateViewController(withIdentifier: "SearchTasksViewController") as? SearchTasksViewController
        rvc?.coordinatorServices = coordinatorServices

        let searchController = UISearchController(searchResultsController: resultsViewController)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.smartQuotesType = .no
        searchController.searchBar.isAccessibilityElement = true
        searchController.searchBar.accessibilityIdentifier = "searchBar"
        return searchController
    }
}
