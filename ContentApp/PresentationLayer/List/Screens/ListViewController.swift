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
import AlfrescoContentServices

class ListViewController: SystemSearchViewController {
    var listController: ListComponentViewController!
    var listViewModel: ListViewModelProtocol?

    weak var tabBarScreenDelegate: TabBarScreenDelegate?

    private var settingsButton = UIButton(type: .custom)

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let listComponentViewController = ListComponentViewController.instantiateViewController()
        listComponentViewController.listActionDelegate = self
        listComponentViewController.listDataSource = listViewModel
        listComponentViewController.themingService = self.themingService
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
        listController?.folderDrillDownScreenCoordinatorDelegate = self.folderDrillDownScreenCoordinatorDelegate

        configureNavigationBar()
        addSettingsButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAvatarInSettingsButton()
        listController.startLoading()
        listViewModel?.refreshList()
    }

    // MARK: - IBActions

    @objc func settingsButtonTapped() {
        tabBarScreenDelegate?.showSettingsScreen()
    }

    // MARK: - Coordinator Public Methods

    func scrollToTop() {
        listController.scrollToSection(0)
    }

    // MARK: - Helpers

    func configureNavigationBar() {
        definesPresentationContext = true
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    func addSettingsButton() {
        guard listViewModel?.shouldDisplaySettingsButton() == true else { return }
        settingsButton.frame = CGRect(x: 0.0, y: 0.0, width: accountSettingsButtonHeight, height: accountSettingsButtonHeight)
        addAvatarInSettingsButton()
        settingsButton.imageView?.contentMode = .scaleAspectFill
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: UIControl.Event.touchUpInside)
        settingsButton.layer.cornerRadius = accountSettingsButtonHeight / 2
        settingsButton.layer.masksToBounds = true

        let settingsBarButtonItem = UIBarButtonItem(customView: settingsButton)
        let currWidth = settingsBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: accountSettingsButtonHeight)
        currWidth?.isActive = true
        let currHeight = settingsBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: accountSettingsButtonHeight)
        currHeight?.isActive = true

        self.navigationItem.leftBarButtonItem = settingsBarButtonItem
    }

    func addAvatarInSettingsButton() {
        let avatarImage = ProfileService.getAvatar(completionHandler: { [weak self] image in
            guard let sSelf = self else { return }

            if let fetchedImage = image {
                sSelf.settingsButton.setImage(fetchedImage, for: .normal)
            }
        })
        settingsButton.setImage(avatarImage, for: .normal)
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = self.themingService?.activeTheme else { return }

        view.backgroundColor = currentTheme.backgroundColor
        navigationController?.navigationBar.tintColor = currentTheme.primaryVariantColor
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = currentTheme.backgroundColor
    }
}

// MARK: - ListComponentActionDelegate

extension ListViewController: ListComponentActionDelegate {
    func elementTapped(node: ListNode) {
    }

    func didUpdateList(error: Error?, pagination: Pagination?) {
        listController.stopLoading()
    }

    func fetchNextListPage(for itemAtIndexPath: IndexPath) {
        listViewModel?.fetchNextListPage(index: itemAtIndexPath, userInfo: nil)
    }
}
