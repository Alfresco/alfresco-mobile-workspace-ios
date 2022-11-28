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

class MultipleChoiceDialogViewController: SystemThemableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    var viewModel: MultipleChoiceViewModelProtocol?
    let multipleChoiceItemCellHeight: CGFloat = 44.0
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = UIConstants.cornerRadiusDialog
        addLocalization()
        setAccessibility()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let numberOfItems = CGFloat(viewModel?.items.count ?? 2)
        collectionViewHeightConstraint.constant = numberOfItems * multipleChoiceItemCellHeight
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
        cancelButton.setTitle(LocalizationConstants.General.cancel, for: .normal)
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        titleLabel.applyStyleSubtitle1OnSurface(theme: currentTheme)
        cancelButton.setTitleColor(currentTheme.primaryT1Color, for: .normal)
        cancelButton.titleLabel?.font = currentTheme.buttonTextStyle.font
        view.backgroundColor = currentTheme.surfaceColor
    }

    private func calculatePreferredSize(_ size: CGSize) {
        let targetSize = CGSize(width: size.width,
                                height: UIView.layoutFittingCompressedSize.height)
        preferredContentSize = view.systemLayoutSizeFitting(targetSize)
    }
    
    private func setAccessibility() {
        titleLabel.accessibilityLabel = titleLabel.text
        titleLabel.accessibilityIdentifier = "title-label"
        cancelButton.accessibilityLabel = LocalizationConstants.General.cancel
        cancelButton.accessibilityIdentifier = "cancel-button"
        
        if let tTitleLabel = titleLabel, let tCollectionView = collectionView, let tCancelButton = cancelButton {
            self.view.accessibilityElements = [tTitleLabel, tCollectionView, tCancelButton]
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionView Delegates

extension MultipleChoiceDialogViewController: UICollectionViewDataSource,
                                              UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = self.viewModel else {
            return UICollectionViewCell()
        }
        let identifier = String(describing: MultipleChoiceItemCollectionViewCell.self)
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                               for: indexPath) as? MultipleChoiceItemCollectionViewCell
        cell?.item = viewModel.items[indexPath.row]
        cell?.accessibilityIdentifier = "multipleChoiceItemCell\(indexPath.row)"
        cell?.applyTheme(coordinatorServices?.themingService?.activeTheme)
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width, height: multipleChoiceItemCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let item = self.viewModel?.items[indexPath.row] else { return }
        viewModel?.perfomAction(for: item, completion: { [weak self] in
            guard let sSelf = self else { return }
            sSelf.viewModel?.select(item: item)
            collectionView.reloadData()
            sSelf.dismiss(animated: true, completion: nil)
        })
    }
}

// MARK: - Storyboard Instantiable

extension MultipleChoiceDialogViewController: StoryboardInstantiable { }
