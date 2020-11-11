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
import AlfrescoContent

class ListViewController: SystemSearchViewController {
    var listController: ListComponentViewController?
    var listViewModel: ListViewModelProtocol?

    weak var tabBarScreenDelegate: TabBarScreenDelegate?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let listComponentViewController = ListComponentViewController.instantiateViewController()
        listComponentViewController.listActionDelegate = self
        listComponentViewController.listDataSource = listViewModel
        listComponentViewController.coordinatorServices = self.coordinatorServices
        listViewModel?.pageUpdatingDelegate = listComponentViewController

        if let listComponentView = listComponentViewController.view {
            listComponentView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(listComponentView)

            NSLayoutConstraint.activate([
                listComponentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                listComponentView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0),
                listComponentView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0),
                listComponentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
            ])

        }
        listController = listComponentViewController
        listController?.listItemActionDelegate = self.listItemActionDelegate

        configureNavigationBar()
        if listViewModel?.shouldDisplaySettingsButton() ?? false {
            addSettingsButton(action: #selector(settingsButtonTapped), target: self)
        }

        listController?.startLoading()
        listViewModel?.refreshList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listController?.viewWillAppear(animated)
        addAvatarInSettingsButton()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        listController?.willTransition(to: newCollection, with: coordinator)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        listController?.collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - IBActions

    @objc func settingsButtonTapped() {
        tabBarScreenDelegate?.showSettingsScreen()
    }

    // MARK: - Coordinator Public Methods

    func scrollToTop() {
        listController?.scrollToSection(0)
    }
}

// MARK: - ListComponentActionDelegate

extension ListViewController: ListComponentActionDelegate {
    func elementTapped(node: ListNode) {
    }

    func didUpdateList(error: Error?, pagination: Pagination?) {
        listController?.stopLoading()
    }

    func fetchNextListPage(for itemAtIndexPath: IndexPath) {
        listViewModel?.fetchNextListPage(index: itemAtIndexPath, userInfo: nil)
    }
}
