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

class ActionMenuViewController: SystemThemableViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewContraintHeight: NSLayoutConstraint!

    var actionMenuModel: ActionMenuViewModel?
    var nodeActionsModel: NodeActionsViewModel?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let numberOfActions = actionMenuModel?.numberOfActions() ?? 1
        collectionViewContraintHeight.constant = numberOfActions * actionMenuCellHeight
        view.isHidden = false
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

    // MARK: - Private Utils

    private func calculatePreferredSize(_ size: CGSize) {
        let targetSize = CGSize(width: size.width,
                                height: UIView.layoutFittingCompressedSize.height)
        preferredContentSize = view.systemLayoutSizeFitting(targetSize)
        collectionView.contentOffset = .zero
    }
}

// MARK: - UIColectionView Delegates

extension ActionMenuViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return actionMenuModel?.actions()?[section].count ?? 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return actionMenuModel?.actions()?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let actionMenuModel = self.actionMenuModel,
              let action = actionMenuModel.actions()?[indexPath.section][indexPath.row] else {
            return UICollectionViewCell()
        }
        let identifier = String(describing: ActionMenuCollectionViewCell.self)
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                               for: indexPath) as? ActionMenuCollectionViewCell
        cell?.action = action
        cell?.applyTheme(themingService?.activeTheme)
        cell?.sectionSeparator.isHidden = !(actionMenuModel.shouldShowSectionSeparator(for: indexPath))
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: actionMenuCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let action = actionMenuModel?.actions()?[indexPath.section][indexPath.row] else { return }
        nodeActionsModel?.tapped(on: action.type, finished: { [weak self] in
            guard let sSelf = self else { return }
            sSelf.dismiss(animated: true, completion: nil)
        })
    }
}

// MARK: - Storyboard Instantiable

extension ActionMenuViewController: StoryboardInstantiable { }
