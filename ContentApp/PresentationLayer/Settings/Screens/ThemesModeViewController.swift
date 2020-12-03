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

protocol ThemesModeScrenDelegate: class {
    func changeThemeMode()
}

class ThemesModeViewController: SystemThemableViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    weak var delegate: ThemesModeScrenDelegate?
    var viewModel = ThemeModesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = dialogCornerRadius
        viewModel.themingService = coordinatorServices?.themingService
        addLocalization()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculatePreferredSize(view.bounds.size)
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        calculatePreferredSize(size)
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        tableView.reloadData()
    }

    // MARK: - Helpers

    func addLocalization() {
        titleLabel.text = LocalizationConstants.Theme.theme
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme =  coordinatorServices?.themingService?.activeTheme else { return }
        titleLabel.applyStyleSubtitle1OnSurface(theme: currentTheme)
        view.backgroundColor = currentTheme.surfaceColor
    }

    private func calculatePreferredSize(_ size: CGSize) {
        let targetSize = CGSize(width: size.width, height: UIView.layoutFittingCompressedSize.height)
        preferredContentSize = view.systemLayoutSizeFitting(targetSize)
    }
}

// MARK: - UITableView Delegate and DataSource

extension ThemesModeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let identifier = NSStringFromClass(ThemeModeTableViewCell.self).components(separatedBy: ".").last,
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                     for: indexPath) as? ThemeModeTableViewCell else {
            return UITableViewCell()
        }
        cell.applyThemingService(coordinatorServices?.themingService?.activeTheme)
        cell.item = viewModel.items[indexPath.row]
        if viewModel.items[indexPath.row] == coordinatorServices?.themingService?.getThemeMode() {
            cell.selectRadioButton()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.saveThemeMode(viewModel.items[indexPath.row],
                                themingService: coordinatorServices?.themingService)
        tableView.reloadData()
        delegate?.changeThemeMode()
        self.dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return settingsThemeCellHeight
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

// MARK: - Storyboard Instantiable

extension ThemesModeViewController: StoryboardInstantiable { }
