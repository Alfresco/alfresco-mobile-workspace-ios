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

class SettingsViewController: SystemThemableViewController {
    @IBOutlet weak var tableView: UITableView!

    weak var settingsScreenCoordinatorDelegate: SettingsScreenCoordinatorDelegate?

    var viewModel: SettingsViewModel?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension

        navigationController?.setNavigationBarHidden(false, animated: true)
        addLocalization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Snackbar.dimissAll()
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Helpers

    func addLocalization() {
        self.title = LocalizationConstants.ScreenTitles.settings
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }

        view.backgroundColor = currentTheme.surfaceColor
        let image = UIImage(color: currentTheme.surfaceColor,
                            size: navigationController?.navigationBar.bounds.size)
        navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = currentTheme.surfaceColor
        navigationController?.navigationBar.tintColor = currentTheme.onSurface60Color
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = currentTheme.surfaceColor
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: currentTheme.headline6TextStyle.font,
             NSAttributedString.Key.foregroundColor: currentTheme.onSurfaceColor]
    }
}

// MARK: - UITableView Delegate and Data Source

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items[section].count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = viewModel?.items[indexPath.section][indexPath.row] else {
            return UITableViewCell()
        }

        var cell: SettingsTablewViewCellProtocol?
        switch item.type {
        case .account:
            let identifier = String(describing: SettingsAccountTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                 for: indexPath) as? SettingsAccountTableViewCell
        case .theme, .dataPlan:
            let identifier = String(describing: SettingsItemTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                 for: indexPath) as? SettingsItemTableViewCell
        case .label:
            let identifier = String(describing: SettingsLabelTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                 for: indexPath) as? SettingsLabelTableViewCell
        }
        cell?.item = item
        cell?.delegate = self
        cell?.accessibilityIdentifier = item.type.rawValue
        cell?.applyTheme(with: coordinatorServices?.themingService)
        if (viewModel?.items.count ?? 0) - 1 == indexPath.section {
            cell?.shouldHideSeparator(hidden: true)
        } else {
            cell?.shouldHideSeparator(hidden: viewModel?.items[indexPath.section].last != item)
        }
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = viewModel?.items[indexPath.section][indexPath.row] else { return }
        switch item.type {
        case .theme:
            settingsScreenCoordinatorDelegate?.showThemesModeScreen()
        case .dataPlan:
            settingsScreenCoordinatorDelegate?.showDataPlanDialog()
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}

extension SettingsViewController: SettingsViewModelDelegate {
    func logOutWithSuccess() {
        self.settingsScreenCoordinatorDelegate?.showLoginScreen()
    }

    func displayError(message: String) {
    }

    func didUpdateDataSource() {
        applyComponentsThemes()
        tableView.reloadData()
    }
}

extension SettingsViewController: SettingsTableViewCellDelegate {
    func signOutButtonTapped(for item: SettingsItem) {
        self.viewModel?.performLogOutForCurrentAccount(in: self)
    }
}

// MARK: - Storyboard Instantiable

extension SettingsViewController: StoryboardInstantiable { }
