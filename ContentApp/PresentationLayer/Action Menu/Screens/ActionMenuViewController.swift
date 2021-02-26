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
import MaterialComponents.MaterialActivityIndicator

class ActionMenuViewController: SystemThemableViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewContraintHeight: NSLayoutConstraint!
    private var activityIndicator = MDCActivityIndicator()

    var actionMenuModel: ActionMenuViewModel?
    var nodeActionsModel: NodeActionsViewModel?

    let actionMenuCellHeight: CGFloat = 55.0

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.cornerRadius = UIConstants.cornerRadiusDialog
        view.isHidden = true

        actionMenuModel?.delegate = self
        activityIndicator.startAnimating()
        actionMenuModel?.fetchNodeInformation()
        view.addSubview(activityIndicator)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let numberOfActions = actionMenuModel?.numberOfActions() ?? 1
        collectionViewContraintHeight.constant = numberOfActions * actionMenuCellHeight
        activityIndicator.center = CGPoint(x: view.center.x,
                                           y: collectionViewContraintHeight.constant / 2)
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
        view.backgroundColor = currentTheme.primaryColorVariant
        activityIndicator.cycleColors = [currentTheme.primaryVariantT1Color]
    }
}

// MARK: - UIColectionView Delegates

extension ActionMenuViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        cell?.applyTheme(coordinatorServices?.themingService?.activeTheme)
        cell?.sectionSeparator.isHidden = !(actionMenuModel.shouldShowSectionSeparator(for: indexPath))
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width, height: actionMenuCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let action = actionMenuModel?.actions()[indexPath.section][indexPath.row] else { return }
        nodeActionsModel?.tapped(on: action, finished: { [weak self] in
            guard let sSelf = self else { return }
            sSelf.dismiss(animated: true)
        })
    }
}

// MARK: - ActionMenuViewModel Delegate

extension ActionMenuViewController: ActionMenuViewModelDelegate {
    func finishedLoadingActions() {
        let numberOfActions = actionMenuModel?.numberOfActions() ?? 1
        collectionViewContraintHeight.constant = numberOfActions * actionMenuCellHeight
        collectionView.reloadData()
        activityIndicator.stopAnimating()
    }
}

// MARK: - Storyboard Instantiable

extension ActionMenuViewController: StoryboardInstantiable { }
