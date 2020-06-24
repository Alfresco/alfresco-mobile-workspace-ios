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

class RecentViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var settingsButton = UIButton(type: .custom)

    var themingService: MaterialDesignThemingService?
    weak var tabBarScreenDelegate: TabBarScreenDelegate?
    var viewModel: RecentViewModel?

    var settingsButtonHeight: CGFloat = 30

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewModelDelegate = self
        configureNavigationBar()
        addLocalization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addMaterialComponentsTheme()
        if let avatar = DiskServices.get(image: kProfileAvatarImageFileName, from: viewModel?.accountService?.activeAccount?.identifier ?? "") {
            settingsButton.setImage(avatar, for: .normal)
        }
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        themingService?.activateUserSelectedTheme()
        addMaterialComponentsTheme()
    }

    // MARK: - IBActions

    @objc func settingsButtonTapped() {
        tabBarScreenDelegate?.showSettingsScreen()
    }

    // MARK: - Helpers

    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.hidesSearchBarWhenScrolling = false

        settingsButton.frame = CGRect(x: 0.0, y: 0.0, width: settingsButtonHeight, height: settingsButtonHeight)
        settingsButton.setImage(UIImage(named: "account-circle"), for: .normal)
        if let avatar = DiskServices.get(image: kProfileAvatarImageFileName, from: viewModel?.accountService?.activeAccount?.identifier ?? "") {
            settingsButton.setImage(avatar, for: .normal)
            settingsButton.imageView?.contentMode = .scaleAspectFit
        }
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: UIControl.Event.touchUpInside)
        settingsButton.layer.cornerRadius = settingsButtonHeight / 2
        settingsButton.layer.masksToBounds = true

        let settingsBarButtonItem = UIBarButtonItem(customView: settingsButton)
        let currWidth = settingsBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: settingsButtonHeight)
        currWidth?.isActive = true
        let currHeight = settingsBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: settingsButtonHeight)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = settingsBarButtonItem

        tableView.contentInsetAdjustmentBehavior = .never
    }

    func addLocalization() {
        self.title = LocalizationConstants.ScreenTitles.recent
    }

    func addMaterialComponentsTheme() {
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.tintColor = .label
            navigationItem.leftBarButtonItem?.tintColor = .label
        } else {
            navigationController?.navigationBar.tintColor = .black
            navigationItem.leftBarButtonItem?.tintColor = .black
        }
    }
}

// MARK: - UITableView Delegates and DataSource

extension RecentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

// MARK: - Recent ViewModel Delegate

extension RecentViewController: RecentViewModelDelegate {
    func didUpdateAvatarImage(image: UIImage) {
        settingsButton.setImage(image, for: .normal)
    }

}

// MARK: - Storyboard Instantiable

extension RecentViewController: StoryboardInstantiable { }
