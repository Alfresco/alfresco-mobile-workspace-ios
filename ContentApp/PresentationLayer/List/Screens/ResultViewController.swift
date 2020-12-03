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
import MaterialComponents.MaterialChips
import MaterialComponents.MaterialChips_Theming
import MaterialComponents.MDCChipView
import MaterialComponents.MDCChipView_MaterialTheming
import AlfrescoContent

protocol ResultViewControllerDelegate: class {
    func recentSearchTapped(string: String)
    func elementListTapped(elementList: ListNode)
    func chipTapped(chip: SearchChipItem)
    func fetchNextSearchResultsPage(for index: IndexPath)
}

class ResultViewController: SystemThemableViewController {
    var resultsListController: ListComponentViewController?
    @IBOutlet weak var chipsCollectionView: UICollectionView!
    @IBOutlet weak var recentSearchCollectionView: UICollectionView!
    @IBOutlet weak var recentSearchesView: UIView!
    @IBOutlet weak var recentSearchesTitle: UILabel!
    @IBOutlet weak var progressView: MDCProgressView!

    weak var resultScreenDelegate: ResultViewControllerDelegate?

    var resultsViewModel: ResultsViewModel?
    var recentSearchesViewModel = RecentSearchesViewModel()
    var searchChipsViewModel = SearchChipsViewModel()
    weak var listItemActionDelegate: ListItemActionDelegate?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let listComponentViewController = ListComponentViewController.instantiateViewController()
        listComponentViewController.listActionDelegate = self
        listComponentViewController.listDataSource = resultsViewModel
        listComponentViewController.coordinatorServices = coordinatorServices
        resultsViewModel?.pageUpdatingDelegate = listComponentViewController

        if let listComponentView = listComponentViewController.view {
            listComponentView.translatesAutoresizingMaskIntoConstraints = false

            view.insertSubview(listComponentView, aboveSubview: chipsCollectionView)
            listComponentView.topAnchor.constraint(equalTo: chipsCollectionView.bottomAnchor,
                                                   constant: 5).isActive = true
            listComponentView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,
                                                    constant: 0).isActive = true
            listComponentView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                                     constant: 0).isActive = true
            listComponentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                      constant: 0).isActive = true
        }
        resultsListController = listComponentViewController
        resultsListController?.listItemActionDelegate = self.listItemActionDelegate

        // Set up progress view
        progressView.progress = 0
        progressView.mode = .indeterminate

        addLocalization()
        addChipsCollectionViewFlowLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.isHidden = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultsListController?.viewWillAppear(animated)

        let activeTheme = coordinatorServices?.themingService?.activeTheme
        progressView.progressTintColor = activeTheme?.primaryT1Color
        progressView.trackTintColor = activeTheme?.primary30T1Color
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        chipsCollectionView.reloadData()
        recentSearchCollectionView.reloadData()
        resultsListController?.willTransition(to: newCollection, with: coordinator)

        let activeTheme = coordinatorServices?.themingService?.activeTheme
        progressView.progressTintColor = activeTheme?.primaryT1Color
        progressView.trackTintColor = activeTheme?.primary30T1Color
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        resultsListController?.collectionView.collectionViewLayout.invalidateLayout()
        recentSearchCollectionView?.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Public Helpers

    func startLoading() {
        progressView.startAnimating()
        progressView.setHidden(false, animated: false)
    }

    func stopLoading() {
        progressView.stopAnimating()
        progressView.setHidden(true, animated: false)
        resultsListController?.refreshControl?.endRefreshing()
    }

    func clearDataSource() {
        resultsViewModel?.clear()
        recentSearchesView.isHidden = false
    }

    func updateRecentSearches() {
        recentSearchesViewModel.reloadRecentSearch()
        recentSearchesTitle.text = (recentSearchesViewModel.searches.isEmpty) ?
            LocalizationConstants.Search.noRecentSearch : LocalizationConstants.Search.recentSearch
        stopLoading()
        recentSearchCollectionView.reloadData()
    }

    func updateChips(_ array: [SearchChipItem]) {
        searchChipsViewModel.chips = array
        chipsCollectionView.reloadData()
    }

    func reloadChips(_ array: [Int]) {
        guard array.count != 0 else { return }
        var items: [IndexPath] = []
        for indexChip in array {
            items.append(IndexPath(row: indexChip, section: 0))
        }
        chipsCollectionView.reloadItems(at: items)
    }

    // MARK: - Helpers

    func addLocalization() {
        recentSearchesTitle.text = LocalizationConstants.Search.noRecentSearch
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }

        recentSearchesTitle.applyStyleSubtitle2OnSurface(theme: currentTheme)
        view.backgroundColor = currentTheme.surfaceColor
        recentSearchesView.backgroundColor = currentTheme.surfaceColor
    }

    func addChipsCollectionViewFlowLayout() {
        let layout = MDCChipCollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: chipSearchCellMinimWidth,
                                          height: chipSearchCellMinimHeight)
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        chipsCollectionView.collectionViewLayout = layout
        chipsCollectionView.register(MDCChipCollectionViewCell.self,
                                     forCellWithReuseIdentifier: "MDCChipCollectionViewCell")
        chipsCollectionView.allowsMultipleSelection = true
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension ResultViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case recentSearchCollectionView:
            return recentSearchesViewModel.searches.count
        case chipsCollectionView:
            return searchChipsViewModel.chips.count
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case recentSearchCollectionView:
            let reuseIdentifier = String(describing: RecentSearchCollectionViewCell.self)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                          for: indexPath) as? RecentSearchCollectionViewCell
            cell?.search = recentSearchesViewModel.searches[indexPath.row]
            cell?.applyTheme(coordinatorServices?.themingService?.activeTheme)
            return cell ?? UICollectionViewCell()
        case chipsCollectionView:
            let reuseIdentifier = String(describing: MDCChipCollectionViewCell.self)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                          for: indexPath) as? MDCChipCollectionViewCell
            let chip = searchChipsViewModel.chips[indexPath.row]
            cell?.chipView.titleLabel.text = chip.name
            cell?.chipView.isSelected = chip.selected
            if chip.selected {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
                cell?.isSelected = true
            }
            if let themeService = coordinatorServices?.themingService {
                if chip.selected {
                    let scheme = themeService.containerScheming(for: .searchChipSelected)
                    let backgroundColor = themeService.activeTheme?.primary15T1Color

                    cell?.chipView.applyOutlinedTheme(withScheme: scheme)
                    cell?.chipView.setBackgroundColor(backgroundColor, for: .selected)
                } else {
                    let scheme = themeService.containerScheming(for: .searchChipUnselected)
                    let backgroundColor = themeService.activeTheme?.surfaceColor
                    let borderColor = themeService.activeTheme?.onSurface15Color

                    cell?.chipView.applyOutlinedTheme(withScheme: scheme)
                    cell?.chipView.setBackgroundColor(backgroundColor, for: .normal)
                    cell?.chipView.setBorderColor(borderColor, for: .normal)
                }
            }
            return cell ?? UICollectionViewCell()
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case recentSearchCollectionView:
            resultScreenDelegate?.recentSearchTapped(string: recentSearchesViewModel.searches[indexPath.row])
        case chipsCollectionView:
            let chip = searchChipsViewModel.chips[indexPath.row]
            chip.selected = true
            if let themeService = coordinatorServices?.themingService {
                let cell = collectionView.cellForItem(at: indexPath) as? MDCChipCollectionViewCell

                let scheme = themeService.containerScheming(for: .searchChipSelected)
                let backgroundColor = themeService.activeTheme?.primary15T1Color

                cell?.chipView.applyOutlinedTheme(withScheme: scheme)
                cell?.chipView.setBackgroundColor(backgroundColor, for: .selected)
            }
            resultScreenDelegate?.chipTapped(chip: chip)
            resultsListController?.scrollToSection(0)
        default: break
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath) {
        switch collectionView {
        case chipsCollectionView:
            let chip = searchChipsViewModel.chips[indexPath.row]
            chip.selected = false
            if let themeService = coordinatorServices?.themingService {
                let cell = collectionView.cellForItem(at: indexPath) as? MDCChipCollectionViewCell

                let scheme = themeService.containerScheming(for: .searchChipUnselected)
                let backgroundColor = themeService.activeTheme?.surfaceColor
                let borderColor = themeService.activeTheme?.onSurface15Color

                cell?.chipView.applyOutlinedTheme(withScheme: scheme)
                cell?.chipView.setBackgroundColor(backgroundColor, for: .normal)
                cell?.chipView.setBorderColor(borderColor, for: .normal)
            }
            resultScreenDelegate?.chipTapped(chip: chip)
            resultsListController?.scrollToSection(0)
        default: break
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case recentSearchCollectionView:
            return CGSize(width: self.view.bounds.width,
                          height: recentSearchCellHeight)
        case chipsCollectionView:
            if let cell = collectionView.cellForItem(at: indexPath) as? MDCChipCollectionViewCell {
                return CGSize(width: cell.chipView.frame.size.width,
                              height: chipSearchCellMinimHeight)
            }
            return CGSize(width: chipSearchCellMinimWidth,
                          height: chipSearchCellMinimHeight)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
}

// MARK: - ListComponentActionDelegate

extension ResultViewController: ListComponentActionDelegate {
    func elementTapped(node: ListNode) {
        resultScreenDelegate?.elementListTapped(elementList: node)
    }

    func didUpdateList(error: Error?, pagination: Pagination?) {
        stopLoading()
        recentSearchesView.isHidden = (pagination == nil && error == nil) ? false : true
    }

    func fetchNextListPage(for itemAtIndexPath: IndexPath) {
        self.resultScreenDelegate?.fetchNextSearchResultsPage(for: itemAtIndexPath)
    }
}

// MARK: - Storyboard Instantiable

extension ResultViewController: StoryboardInstantiable { }
