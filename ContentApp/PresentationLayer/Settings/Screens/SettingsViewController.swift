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

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    weak var settingsScreenCoordinatorDelegate: SettingsScreenCoordinatorDelegate?
    var themingService: MaterialDesignThemingService?
    var viewModel: SettingsViewModel?
    var heightCell: CGFloat = 64

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = heightCell
        navigationController?.setNavigationBarHidden(false, animated: true)
        addLocalization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addMaterialComponentsTheme()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        themingService?.activateUserSelectedTheme()
        addMaterialComponentsTheme()
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Snackbar.dimissAll()
    }

    // MARK: - Helpers

    func addLocalization() {
        self.title = LocalizationConstants.ScreenTitles.settings
    }

    func addMaterialComponentsTheme() {
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
            cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? SettingsAccountTableViewCell
        case .theme:
            let identifier = String(describing: SettingsItemTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? SettingsItemTableViewCell
        case .label:
            let identifier = String(describing: SettingsLabelTableViewCell.self)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? SettingsLabelTableViewCell
        }
        cell?.item = item
        cell?.delegate = self
        cell?.applyThemingService(themingService)
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
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            let snackbar = Snackbar(with: message, type: .error, buttonTitle: LocalizationConstants.Buttons.retry)
            if let theme = sSelf.themingService?.activeTheme {
                snackbar.applyTheme(theme: theme)
            }
            snackbar.show {
                sSelf.viewModel?.reloadRequests()
            }
        }
    }

    func didUpdateDataSource() {
        tableView.reloadData()
    }
}

extension SettingsViewController: SettingsTableViewCellDelegate {
    func signOutButtonTapped(for item: SettingsItem) {
        self.viewModel?.performLogOutForCurrentAccount(in: self)
    }
}

extension SettingsViewController: ThemesModeScrenDelegate {
    func changeThemeMode() {
        viewModel?.reloadDataSource()
        addMaterialComponentsTheme()
    }
}

// MARK: - Storyboard Instantiable

extension SettingsViewController: StoryboardInstantiable { }
