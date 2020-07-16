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

protocol ResultScreenDelegate: class {
    func recentSearchTapped(string: String)
    func elementListTapped(elementList: ListElementProtocol)
    func chipTapped(chip: SearchChipItem)
}

class ResultViewController: SystemThemableViewController {
    @IBOutlet weak var activityIndicatorSuperview: UIView!

    @IBOutlet weak var resultsListCollectionView: UICollectionView!

    @IBOutlet weak var chipsCollectionView: UICollectionView!

    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListTitle: UILabel!
    @IBOutlet weak var emptyListSubtitle: UILabel!
    @IBOutlet weak var emptyListImageView: UIImageView!

    @IBOutlet weak var recentSearchesView: UIView!
    @IBOutlet weak var recentSearchesTitle: UILabel!
    @IBOutlet weak var recentSearchCollectionView: UICollectionView!

    weak var resultScreenDelegate: ResultScreenDelegate?
    var activityIndicator: ActivityIndicatorView?
    var resultsList: [ListElementProtocol] = []
    var recentSearches: [String] = []
    var searchChips: [SearchChipItem] = []

    var nodeHeighCell: CGFloat = 64.0
    var siteHeighCell: CGFloat = 48.0
    var recentSearchHeighCell: CGFloat = 48.0
    var chipHeighCell: CGFloat = 30.0
    var chipWidthCell: CGFloat = 70.0

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        emptyListView.isHidden = true
        registerListElementCell()
        addLocalization()
        addChipsCollectionViewFlowLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator = ActivityIndicatorView(currentTheme: themingService?.activeTheme,
                                                  configuration: ActivityIndicatorConfiguration(title: LocalizationConstants.Search.searching,
                                                                                                radius: 12,
                                                                                                strokeWidth: 2,
                                                                                                cycleColors: [themingService?.activeTheme?.activityIndicatorSearchViewColor ?? .black]))
        if let activityIndicator = activityIndicator {
            activityIndicatorSuperview.addSubview(activityIndicator)
            activityIndicatorSuperview.isHidden = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.isHidden = false
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        activityIndicator?.reload(from: size)
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        resultsListCollectionView.reloadData()
        chipsCollectionView.reloadData()
        recentSearchCollectionView.reloadData()
    }

    // MARK: - Public Helpers

    func startLoading() {
        activityIndicatorSuperview.isHidden = false
        activityIndicator?.state = .isLoading
    }

    func stopLoading() {
        activityIndicatorSuperview.isHidden = true
        activityIndicator?.state = .isIdle
    }

    func updateDataSource(_ results: [ListElementProtocol]?) {
        if resultsList.count > 0 {
            resultsListCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        if let results = results {
            resultsList = results
            emptyListView.isHidden = !results.isEmpty
            recentSearchesView.isHidden = true
        } else {
            resultsList = []
            emptyListView.isHidden = true
            recentSearchesView.isHidden = false
        }
        stopLoading()
        resultsListCollectionView.reloadData()
    }

    func updateRecentSearches(_ array: [String]) {
        if recentSearches.count > 0 {
            recentSearchCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        recentSearchesTitle.text = (array.isEmpty) ? LocalizationConstants.Search.noRecentSearch : LocalizationConstants.Search.recentSearch
        recentSearches = array
        stopLoading()
        recentSearchCollectionView.reloadData()
    }

    func updateChips(_ array: [SearchChipItem]) {
        searchChips = array
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

    func registerListElementCell() {
        let identifier = String(describing: ListElementCollectionViewCell.self)
        resultsListCollectionView?.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
    }

    func addLocalization() {
        emptyListTitle.text = LocalizationConstants.Search.title
        emptyListSubtitle.text = LocalizationConstants.Search.subtitle
        recentSearchesTitle.text = LocalizationConstants.Search.noRecentSearch
    }

    override func applyComponentsThemes() {
        guard let currentTheme = self.themingService?.activeTheme else { return }
        emptyListTitle.font = currentTheme.emptyListTitleLabelFont
        emptyListTitle.textColor = currentTheme.emptyListTitleLabelColor
        emptyListSubtitle.font = currentTheme.emptyListSubtitleLabelFont
        emptyListSubtitle.textColor = currentTheme.emptyListSubtitleLabelColor
        recentSearchesTitle.font = currentTheme.recentSearcheTitleLabelFont
        recentSearchesTitle.textColor = currentTheme.recentSearchesTitleLabelColor
    }

    func addChipsCollectionViewFlowLayout() {
        let layout = MDCChipCollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        chipsCollectionView.collectionViewLayout = layout
        chipsCollectionView.register(MDCChipCollectionViewCell.self, forCellWithReuseIdentifier: "MDCChipCollectionViewCell")
        chipsCollectionView.allowsMultipleSelection = true
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension ResultViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case recentSearchCollectionView:
            return recentSearches.count
        case resultsListCollectionView:
            return resultsList.count
        case chipsCollectionView:
            return searchChips.count
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case resultsListCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ListElementCollectionViewCell.self),
                                                          for: indexPath) as? ListElementCollectionViewCell
            cell?.element = resultsList[indexPath.row]
            cell?.applyThemingService(themingService?.activeTheme)
            return cell ?? UICollectionViewCell()
        case recentSearchCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RecentSearchCollectionViewCell.self),
                                                          for: indexPath) as? RecentSearchCollectionViewCell
            cell?.search = recentSearches[indexPath.row]
            cell?.applyThemingService(themingService?.activeTheme)
            return cell ?? UICollectionViewCell()
        case chipsCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MDCChipCollectionViewCell.self),
                                                          for: indexPath) as? MDCChipCollectionViewCell
            let chip = searchChips[indexPath.row]
            cell?.chipView.titleLabel.text = chip.name
            cell?.chipView.isSelected = chip.selected
            if chip.selected {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
                cell?.isSelected = true
            }
            if let themeService = self.themingService {
                cell?.chipView.applyOutlinedTheme(withScheme: themeService.containerScheming(for: (chip.selected) ? .searchChipSelected : .searchChipUnselected))
            }
            return cell ?? UICollectionViewCell()
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case recentSearchCollectionView:
            resultScreenDelegate?.recentSearchTapped(string: recentSearches[indexPath.row])
        case resultsListCollectionView:
            resultScreenDelegate?.elementListTapped(elementList: resultsList[indexPath.row])
        case chipsCollectionView:
            let chip = searchChips[indexPath.row]
            chip.selected = true
            if let themeService = self.themingService {
                let cell = collectionView.cellForItem(at: indexPath) as? MDCChipCollectionViewCell
                cell?.chipView.applyOutlinedTheme(withScheme: themeService.containerScheming(for: .searchChipSelected))
            }
            resultScreenDelegate?.chipTapped(chip: chip)
        default: break
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch collectionView {
        case chipsCollectionView:
            let chip = searchChips[indexPath.row]
            chip.selected = false
            if let themeService = self.themingService {
                let cell = collectionView.cellForItem(at: indexPath) as? MDCChipCollectionViewCell
                cell?.chipView.applyOutlinedTheme(withScheme: themeService.containerScheming(for: .searchChipUnselected))
            }
            resultScreenDelegate?.chipTapped(chip: chip)
        default: break
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case recentSearchCollectionView:
            return CGSize(width: self.view.bounds.width, height: recentSearchHeighCell)
        case resultsListCollectionView:
            let element = resultsList[indexPath.row]
            return CGSize(width: self.view.bounds.width, height: (element.path.isEmpty) ? siteHeighCell : nodeHeighCell)
        case chipsCollectionView:
            return CGSize(width: chipWidthCell, height: chipHeighCell)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
}

// MARK: - Storyboard Instantiable

extension ResultViewController: StoryboardInstantiable { }
