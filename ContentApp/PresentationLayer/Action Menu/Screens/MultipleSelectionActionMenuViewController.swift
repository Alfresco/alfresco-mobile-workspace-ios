//
// Copyright (C) 2005-2023 Alfresco Software Limited.
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
import MaterialComponents.MaterialActivityIndicator

class MultipleSelectionActionMenuViewController: SystemThemableViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewContraintHeight: NSLayoutConstraint!
    var actionMenuModel: MultipleSelectionActionMenuViewModel?
    let actionMenuCellHeight: CGFloat = 55.0
    var didSelectAction: ((ActionMenu) -> Void)?

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionMenuModel?.delegate = self
        view.layer.cornerRadius = UIConstants.cornerRadiusDialog
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

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        let contentInset = collectionView.contentInset
        collectionView.contentInset = contentInset
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        calculatePreferredSize(size)

        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.collectionView?.collectionViewLayout.invalidateLayout()
        }
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
    }
    
    // MARK: - Private Utils

    private func calculatePreferredSize(_ size: CGSize) {
        let targetSize = CGSize(width: size.width,
                                height: UIView.layoutFittingCompressedSize.height)
        preferredContentSize = view.systemLayoutSizeFitting(targetSize)
        collectionView.contentOffset = .zero
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        view.backgroundColor = currentTheme.surfaceColor
    }
}

// MARK: - UIColectionView Delegates

extension MultipleSelectionActionMenuViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return actionMenuModel?.actions()[section].count ?? 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return actionMenuModel?.actions().count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let actionMenuModel = self.actionMenuModel else {
            return UICollectionViewCell()
        }
        let action = actionMenuModel.actions()[indexPath.section][indexPath.row]
        let identifier = String(describing: ActionMenuCollectionViewCell.self)
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                               for: indexPath) as? ActionMenuCollectionViewCell
        cell?.action = action
        cell?.accessibilityIdentifier = action.type.rawValue
        cell?.applyTheme(coordinatorServices?.themingService?.activeTheme)
        cell?.sectionSeparator.isHidden = !(actionMenuModel.shouldShowSectionSeparator(for: indexPath))
        
        if action.type == .node {
            cell?.setHeaderForMultiSelectionActionMenuCell()
        }
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: actionMenuCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let action = actionMenuModel?.actions()[indexPath.section][indexPath.row] else { return }
        self.dismiss(animated: true)
        self.didSelectAction?(action)
    }
}

// MARK: - ActionMenuViewModel Delegate

extension MultipleSelectionActionMenuViewController: ActionMenuViewModelDelegate {
    func finishedLoadingActions() {
        let numberOfActions = actionMenuModel?.numberOfActions() ?? 1
        collectionViewContraintHeight.constant = numberOfActions * actionMenuCellHeight
        collectionView.reloadData()
    }
}

// MARK: - Storyboard Instantiable

extension MultipleSelectionActionMenuViewController: StoryboardInstantiable { }
