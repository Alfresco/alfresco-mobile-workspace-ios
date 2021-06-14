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

    private let sectionCellHeight: CGFloat = 1.0
    private let listBrowseCellHeight: CGFloat = 44.0

    var listViewModel: BrowseViewModel?
    weak var browseScreenCoordinatorDelegate: BrowseScreenCoordinatorDelegate?
    weak var tabBarScreenDelegate: TabBarScreenDelegate?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addSettingsButton(action: #selector(settingsButtonTapped), target: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAvatarInSettingsButton()
        collectionView.reloadData()
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    // MARK: - IBActions

    @objc func settingsButtonTapped() {
        tabBarScreenDelegate?.showSettingsScreen()
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension BrowseViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return listViewModel?.list[section].count ?? 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return listViewModel?.list.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let node = listViewModel?.list[indexPath.section][indexPath.row] else {
            return UICollectionViewCell()

        }

        let identifier = String(describing: BrowseStaticNodeCollectionViewCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                                      for: indexPath) as? BrowseStaticNodeCollectionViewCell
        cell?.node = node
        cell?.applyTheme(coordinatorServices?.themingService?.activeTheme)
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: listBrowseCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let node = listViewModel?.list[indexPath.section][indexPath.row] else { return }
        browseScreenCoordinatorDelegate?.showTopLevelFolderScreen(from: node)
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let identifier = String(describing: BrowseSectionCollectionReusableView.self)
            guard let headerView =
                    collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                    withReuseIdentifier: identifier,
                                                                    for: indexPath) as? BrowseSectionCollectionReusableView else {
                fatalError("Invalid BrowseSectionCollectionReusableView type")
            }
            headerView.applyTheme(coordinatorServices?.themingService?.activeTheme)

            return headerView
        default: return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.bounds.width,
                      height: (section == 0) ? 0 : sectionCellHeight)
    }
}

// MARK: - Storyboard Instantiable

extension BrowseViewController: StoryboardInstantiable { }
