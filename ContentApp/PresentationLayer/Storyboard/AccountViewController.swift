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

class AccountViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var signOutButton: MDCButton!

    weak var accountScreenCoordinatorDelegate: AccountScreenCoordinatorDelegate?
    var themingService: MaterialDesignThemingService?
    var viewModel = AccountViewModel()
    var heightCell: CGFloat = 64

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizationConstants.ScreenTitles.account
        addLocalization()
        addMaterialComponentsTheme()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        guard ThemeMode.get() == .auto else { return }
        switch newCollection.userInterfaceStyle {
        case .dark:
            self.themingService?.activateDarkTheme()
        case .light:
            self.themingService?.activateDefaultTheme()
        default: break
        }
        addMaterialComponentsTheme()
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

extension AccountViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let identifier = NSStringFromClass(AccountItemTableViewCell.self).components(separatedBy: ".").last,
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? AccountItemTableViewCell else {
            return UITableViewCell()
        }
        cell.applyThemingService(themingService)
        cell.item = viewModel.items[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.row]
        switch item.type {
        case .theme:
            accountScreenCoordinatorDelegate?.showThemesModeScreen()
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

extension AccountViewController: ThemesModeScrenDelegate {
    func dismiss() {
        tableView.reloadData()
    }

    func changeThemeMode() {
        viewModel.reload()
        addMaterialComponentsTheme()
    }
}

// MARK: - Storyboard Instantiable

extension AccountViewController: StoryboardInstantiable { }
