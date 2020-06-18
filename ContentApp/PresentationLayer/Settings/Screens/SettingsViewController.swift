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
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var signOutButton: MDCButton!

    weak var settingsScreenCoordinatorDelegate: SettingsScreenCoordinatorDelegate?
    var themingService: MaterialDesignThemingService?
    var viewModel: SettingsViewModel?
    var heightCell: CGFloat = 64

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = LocalizationConstants.ScreenTitles.settings
        self.viewModel?.delegate = self
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

    // MARK: - IBActions

    @IBAction func signOutButtonnTapped(_ sender: MDCButton) {
    }

    // MARK: - Helpers

    func addLocalization() {
        signOutButton.isUppercaseTitle = false
        signOutButton.setTitle(LocalizationConstants.Buttons.signOut, for: .normal)
    }

    func addMaterialComponentsTheme() {
        guard let themingService = self.themingService else {
            return
        }
        signOutButton.applyContainedTheme(withScheme: themingService.containerScheming(for: .signOutButton))
    }
}

// MARK: - UITableView Delegate and Data Source

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let identifier = NSStringFromClass(SettingsItemTableViewCell.self).components(separatedBy: ".").last,
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? SettingsItemTableViewCell,
            let item = viewModel?.items[indexPath.row] else {
            return UITableViewCell()
        }
        cell.applyThemingService(themingService)
        cell.item = item
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = viewModel?.items[indexPath.row] else { return }
        switch item.type {
        case .theme:
            settingsScreenCoordinatorDelegate?.showThemesModeScreen()
        default: break
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightCell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

extension SettingsViewController: ThemesModeScrenDelegate {
    func changeThemeMode() {
        viewModel?.reloadDataSource()
        addMaterialComponentsTheme()
    }
}

extension SettingsViewController: SettingsViewModelDelegate {
    func dataSourceReloaded() {
        tableView.reloadData()
    }
}

// MARK: - Storyboard Instantiable

extension SettingsViewController: StoryboardInstantiable { }
