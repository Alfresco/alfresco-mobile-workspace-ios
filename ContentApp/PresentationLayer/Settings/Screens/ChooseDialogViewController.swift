//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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

let kChooseItemCellHeight: CGFloat = 44.0

class ChooseDialogViewController: SystemThemableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    var viewModel: ChooseDialogViewModelProtocol?
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = dialogCornerRadius
        addLocalization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let numberOfItems = viewModel?.items.count ?? 2
        collectionViewHeightConstraint.constant = CGFloat(numberOfItems) * kChooseItemCellHeight
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
        collectionView.reloadData()
    }

    // MARK: - Helpers

    func addLocalization() {
        titleLabel.text = viewModel?.titleDialog
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

// MARK: - UICollectionView Delegates

extension ChooseDialogViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = self.viewModel else {
            return UICollectionViewCell()
        }
        let identifier = String(describing: ChooseItemCollectionViewCell.self)
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                               for: indexPath) as? ChooseItemCollectionViewCell
        cell?.item = viewModel.items[indexPath.row]
        cell?.applyTheme(coordinatorServices?.themingService?.activeTheme)
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width, height: 44)
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let item = self.viewModel?.items[indexPath.row] else { return }
        viewModel?.select(item: item)
        viewModel?.perfomAction(for: item)
        collectionView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Storyboard Instantiable

extension ChooseDialogViewController: StoryboardInstantiable { }
