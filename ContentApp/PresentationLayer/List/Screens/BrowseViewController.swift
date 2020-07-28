//
//  BrowseViewController.swift
//  ContentApp
//
//  Created by Florin Baincescu on 24/07/2020.
//  Copyright © 2020 Florin Baincescu. All rights reserved.
//

import UIKit

class BrowseViewController: SystemThemableViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var listViewModel: BrowseViewModel?
    weak var browseScreenCoordinatorDelegate: BrowseScreenCoordinatorDelegate?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
    }

    // MARK: - Helpers

    override func applyComponentsThemes() {
        guard let currentTheme = self.themingService?.activeTheme else { return }

        view.backgroundColor = currentTheme.backgroundColor
        navigationController?.navigationBar.tintColor = currentTheme.primaryVariantColor
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = currentTheme.backgroundColor
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
