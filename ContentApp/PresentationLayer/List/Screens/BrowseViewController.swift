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

class BrowseViewController: SystemSearchViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private var settingsButton = UIButton(type: .custom)

    var listViewModel: BrowseViewModel?
    weak var browseScreenCoordinatorDelegate: BrowseScreenCoordinatorDelegate?
    weak var tabBarScreenDelegate: TabBarScreenDelegate?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        addSettingsButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAvatarInSettingsButton()
        collectionView.reloadData()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
    }

    // MARK: - IBActions

    @objc func settingsButtonTapped() {
        tabBarScreenDelegate?.showSettingsScreen()
    }

    // MARK: - Helpers

    override func applyComponentsThemes() {
        guard let currentTheme = self.themingService?.activeTheme else { return }

        view.backgroundColor = currentTheme.backgroundColor
        navigationController?.navigationBar.tintColor = currentTheme.primaryVariantColor
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = currentTheme.backgroundColor
    }

    func configureNavigationBar() {
        definesPresentationContext = true
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    func addSettingsButton() {
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
}

// MARK: - UICollectionView DataSource & Delegate

extension BrowseViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listViewModel?.list[section].count ?? 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return listViewModel?.list.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let node = listViewModel?.list[indexPath.section][indexPath.row] else { return UICollectionViewCell() }
        let identifier = String(describing: BrowseStaticNodeCollectionViewCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? BrowseStaticNodeCollectionViewCell
        cell?.node = node
        cell?.applyTheme(themingService?.activeTheme)
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: listBrowseCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let node = listViewModel?.list[indexPath.section][indexPath.row] else { return }
        browseScreenCoordinatorDelegate?.showScreen(from: node)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let identifier = String(describing: BrowseSectionCollectionReusableView.self)
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier,
                                                                                   for: indexPath) as? BrowseSectionCollectionReusableView else {
                                                                                    fatalError("Invalid BrowseSectionCollectionReusableView type") }
            headerView.applyTheme(themingService?.activeTheme)
            return headerView
        default:
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: (section == 0) ? 0 : listBrowseSectionCellHeight)
    }
}

// MARK: - Storyboard Instantiable

extension BrowseViewController: StoryboardInstantiable { }
