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
import DropDown

protocol ResultViewControllerDelegate: AnyObject {
    func recentSearchTapped(string: String)
    func elementListTapped(elementList: ListNode)
    func chipTapped(chip: SearchChipItem)
    func resetSearchFilterTapped()
}

class ResultViewController: SystemThemableViewController {
    @IBOutlet weak var chipsCollectionView: UICollectionView!
    @IBOutlet weak var recentSearchCollectionView: UICollectionView!
    @IBOutlet weak var recentSearchesView: UIView!
    @IBOutlet weak var recentSearchesTitle: UILabel!
    @IBOutlet weak var progressView: MDCProgressView!
    @IBOutlet weak var configurationView: UIView!
    @IBOutlet weak var categoryNameView: UIView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var resetFilterButton: UIButton!
    @IBOutlet weak var heightConfigurationViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var configurationImageView: UIImageView!
    weak var resultScreenDelegate: ResultViewControllerDelegate?
    weak var listItemActionDelegate: ListItemActionDelegate?
    lazy var dropDown = DropDown()
    private var presenter: UINavigationController?
    var resultsListController: ListComponentViewController?
    var pageController: ListPageController?
    var resultsViewModel: SearchViewModel?
    var recentSearchesViewModel = RecentSearchesViewModel()
    
    private var searchChipsViewModel = SearchChipsViewModel()
    private let recentSearchCellHeight: CGFloat = 44.0
    private let chipSearchCellMinimHeight: CGFloat = 32.0
    private let chipSearchCellMinimWidth: CGFloat = 52.0
    private let configurationViewHeight: CGFloat = 50.0
    private let textChipMaxCharacters = 20
    private var animationIndex = 0

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let listComponentViewController = ListComponentViewController.instantiateViewController()
        listComponentViewController.listActionDelegate = self
        listComponentViewController.coordinatorServices = coordinatorServices
        listComponentViewController.pageController = pageController
        listComponentViewController.viewModel = resultsViewModel
        pageController?.delegate = listComponentViewController

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
        setupBindings()
        setupDropDownView()
        self.pageController?.resultPageDelegate = self
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
    
    @IBAction func chooseCategoryButtonAction(_ sender: Any) {
        dropDown.show()
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
        pageController?.clear()
        recentSearchesView.isHidden = false
    }

    func updateRecentSearches() {
        recentSearchesViewModel.reloadRecentSearch()
        recentSearchesTitle.text = (recentSearchesViewModel.searches.isEmpty) ?
            LocalizationConstants.Search.noRecentSearch : LocalizationConstants.Search.recentSearch
        recentSearchCollectionView.reloadData()
    }

    func updateChips(_ array: [SearchChipItem]) {
        searchChipsViewModel.chips = array
        chipsCollectionView.reloadData()
    }

    func reloadChips(_ array: [Int]) {
        guard !array.isEmpty else { return }
        var items: [IndexPath] = []
        for indexChip in array {
            items.append(IndexPath(row: indexChip, section: 0))
        }
        chipsCollectionView.reloadItems(at: items)
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
        /* observing advance search filter */
        self.resultsViewModel?.searchFilterObservable.addObserver(fireNow: false, { ( _ ) in
            self.buildDropDownDataSource()
            self.resetSelectedSearchFilter() // reset selected search filter
        })
    }

    // MARK: - Helpers

    func addLocalization() {
        recentSearchesTitle.text = LocalizationConstants.Search.noRecentSearch
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }

        categoryNameLabel.applyStyleHeadLineBoldOnSurface(theme: currentTheme)
        configurationImageView.tintColor = currentTheme.onSurfaceColor
        recentSearchesTitle.applyStyleSubtitle2OnSurface(theme: currentTheme)
        view.backgroundColor = currentTheme.surfaceColor
        dropDown.backgroundColor = currentTheme.surfaceColor
        dropDown.selectionBackgroundColor = currentTheme.primary15T1Color
        dropDown.textColor = currentTheme.onSurfaceColor
        dropDown.selectedTextColor = currentTheme.onSurfaceColor
        recentSearchesView.backgroundColor = currentTheme.surfaceColor
        resetFilterButton.tintColor = currentTheme.onSurfaceColor
    }

    func addChipsCollectionViewFlowLayout() {
        chipsCollectionView.register(MDCChipCollectionViewCell.self,
                                     forCellWithReuseIdentifier: "MDCChipCollectionViewCell")
        chipsCollectionView.allowsMultipleSelection = true
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        collectionViewFlowLayout.estimatedItemSize = CGSize(width: chipSearchCellMinimWidth,
                                                            height: chipSearchCellMinimHeight)
        collectionViewFlowLayout.scrollDirection = .horizontal
        chipsCollectionView.collectionViewLayout = collectionViewFlowLayout
    }
}

// MARK: - Drop Down
extension ResultViewController {
    func setupDropDownView() {
        dropDown.anchorView = categoryNameView
        dropDown.bottomOffset = CGPoint(x: 0, y: (dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.cornerRadius = 6
        dropDown.width = 200
    }
    
    func buildDropDownDataSource() {
        let searchFilters = resultsViewModel?.localizedFilterNames ?? []
        if resultsViewModel?.isShowAdvanceFilterView(array: searchFilters) == false {
            heightConfigurationViewConstraint.constant = 0
            self.view.updateConstraints()
            self.configurationView.alpha = 0
        } else {
            heightConfigurationViewConstraint.constant = configurationViewHeight
            self.view.updateConstraints()
            self.configurationView.alpha = 1
            dropDown.dataSource = searchFilters
            dropDown.reloadAllComponents()
            dropDown.selectionAction = { (index: Int, item: String) in
                self.resultsViewModel?.searchModel.selectedSearchFilter = self.resultsViewModel?.searchFilters[index]
                self.updateCategory()
            }
        }
    }
    
    private func updateCategory() {
        if let selectedConfig = self.resultsViewModel?.searchModel.selectedSearchFilter, let searchFilters = resultsViewModel?.searchFilters {
            if let index = searchFilters.firstIndex(where: {$0.name == selectedConfig.name}) {
                dropDown.selectRow(at: index)
                categoryNameLabel.text = resultsViewModel?.selectedFilterName(for: selectedConfig)
                resultsViewModel?.resetAdvanceSearch() // reset categories for selected value
                resetChipCollectionView()
                pageController?.refreshList() // refresh list by calling search api
                showResetFilterButton()
            }
        }
    }
    
    private func showResetFilterButton() {
        let isShowResetFilter = resultsViewModel?.isShowResetFilter ?? false
        if isShowResetFilter {
            resetFilterButton.alpha = 1
        } else {
            resetFilterButton.alpha = 0
        }
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
            cell?.accessibilityIdentifier = "recentSearchItem\(indexPath.row)"
            cell?.applyTheme(coordinatorServices?.themingService?.activeTheme)
            return cell ?? UICollectionViewCell()
        case chipsCollectionView:
            let reuseIdentifier = String(describing: MDCChipCollectionViewCell.self)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                          for: indexPath) as? MDCChipCollectionViewCell
            let chip = searchChipsViewModel.chips[indexPath.row]
            let selectedValue = chip.selectedValue
            if selectedValue.isEmpty {
                cell?.chipView.titleLabel.text = chip.name
            } else {
                cell?.chipView.titleLabel.text = chip.selectedValue
            }
            
            let text = cell?.chipView.titleLabel.text ?? ""
            if text.count >= textChipMaxCharacters && chip.componentType == .text {
                let shortString = String(text.prefix(textChipMaxCharacters))
                cell?.chipView.titleLabel.text = String(format: "%@...", shortString)
            }
            
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
            switch chip.type {
            case .file:
                cell?.accessibilityIdentifier = "filesChip"
            case .folder:
                cell?.accessibilityIdentifier = "foldersChip"
            case .library:
                cell?.accessibilityIdentifier = "librariesChip"
            case .node:
                cell?.accessibilityIdentifier = "nodeChip"
            case .none:
                cell?.accessibilityIdentifier = "noneChip"
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
            self.selectChipCollectionCell(for: indexPath)
        default: break
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath) {
        switch collectionView {
        case chipsCollectionView:
            let chip = searchChipsViewModel.chips[indexPath.row]
            let componentType = chip.componentType
            if componentType == nil {
                self.deSelectChipCollectionCell(for: indexPath)
            } else {
                self.selectChipCollectionCell(for: indexPath)
            }
        default: break
        }
    }
    
    private func selectChipCollectionCell(for indexPath: IndexPath) {
        let chip = searchChipsViewModel.chips[indexPath.row]
        let componentType = chip.componentType
        chip.selected = true
        if let themeService = coordinatorServices?.themingService {
            let cell = chipsCollectionView.cellForItem(at: indexPath) as? MDCChipCollectionViewCell

            let scheme = themeService.containerScheming(for: .searchChipSelected)
            let backgroundColor = themeService.activeTheme?.primary15T1Color

            cell?.chipView.applyOutlinedTheme(withScheme: scheme)
            cell?.chipView.setBackgroundColor(backgroundColor, for: .selected)
        }
        self.chipTapped(for: chip)
        if componentType != nil {
            self.resultsViewModel?.selectedCategory = self.resultsViewModel?.getSelectedCategory(for: chip.componentType)
            self.resultsViewModel?.selectedChip = chip
            self.showSelectedComponent(for: chip)
        }
        reloadChipCollectionWithoutScroll()
    }
    
    private func deSelectChipCollectionCell(for indexPath: IndexPath) {
        let chip = searchChipsViewModel.chips[indexPath.row]
        chip.selected = false
        self.resultsViewModel?.selectedCategory = self.resultsViewModel?.getSelectedCategory(for: chip.componentType)
        self.resultsViewModel?.selectedChip = chip
        if let themeService = coordinatorServices?.themingService {
            if let cell = chipsCollectionView.cellForItem(at: indexPath) as? MDCChipCollectionViewCell {
                let scheme = themeService.containerScheming(for: .searchChipUnselected)
                let backgroundColor = themeService.activeTheme?.surfaceColor
                let borderColor = themeService.activeTheme?.onSurface15Color

                cell.chipView.applyOutlinedTheme(withScheme: scheme)
                cell.chipView.setBackgroundColor(backgroundColor, for: .normal)
                cell.chipView.setBorderColor(borderColor, for: .normal)
            }
        }
        self.chipTapped(for: chip)
    }
    
    private func chipTapped(for chip: SearchChipItem) {
        let searchFilters = resultsViewModel?.searchFilters ?? []
        if searchFilters.isEmpty || chip.componentType == nil {
            resultScreenDelegate?.chipTapped(chip: chip)
            resultsListController?.scrollToSection(0)
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

    func didUpdateList(in listComponentViewController: ListComponentViewController,
                       error: Error?,
                       pagination: Pagination?) {
        stopLoading()
        recentSearchesView.isHidden = (pagination == nil && error == nil) ? false : true
    }

    func performListAction() {
        // Do nothing
    }
}

// MARK: - Advance Search Components
extension ResultViewController {
    func showSelectedComponent(for chip: SearchChipItem) {
        if chip.componentType == .text {
            showTextSelectorComponent()
        } else if chip.componentType == .checkList {
            showListSelectorComponent(isRadio: false)
        } else if chip.componentType == .radio {
            showListSelectorComponent(isRadio: true)
        } else if chip.componentType == .contentSizeRange {
            showNumberRangeSelectorComponent()
        } else if chip.componentType == .contentSize {
            showSliderSelectorComponent()
        } else if chip.componentType == .createdDateRange {
            showCalendarSelectorComponent()
        } else if chip.componentType == .facetField || chip.componentType == .facetQuery || chip.componentType == .facetInterval {
            showFacetSelectorComponent(componentType: chip.componentType, name: chip.selectedValue)
        }
    }
    
    /// Text Component
    private func showTextSelectorComponent() {
        if let selectedCategory = resultsViewModel?.getSelectedCategory() {
            let viewController = SearchTextComponentViewController.instantiateViewController()
            let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
            bottomSheet.dismissOnDraggingDownSheet = false
            bottomSheet.delegate = self
            viewController.coordinatorServices = coordinatorServices
            viewController.textViewModel.selectedCategory = selectedCategory
            viewController.callback = { (category, query, isBackButtonTapped) in
                if isBackButtonTapped {
                    self.resetChip()
                } else {
                    let selectedValue = category?.component?.settings?.selectedValue
                    self.updateSelectedChip(with: selectedValue, and: query)
                }
            }
            self.present(bottomSheet, animated: true, completion: nil)
        }
    }
    
    /// List or Radio Component
    private func showListSelectorComponent(isRadio: Bool) {
        if let selectedCategory = resultsViewModel?.getSelectedCategory() {
            let viewController = SearchListComponentViewController.instantiateViewController()
            let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
            bottomSheet.dismissOnDraggingDownSheet = false
            bottomSheet.delegate = self
            viewController.coordinatorServices = coordinatorServices
            viewController.listViewModel.isRadioList = isRadio
            viewController.listViewModel.selectedCategory = selectedCategory
            viewController.callback = { (category, query, isBackButtonTapped) in
                if isBackButtonTapped {
                    self.resetChip()
                } else {
                    let selectedValue = category?.component?.settings?.selectedValue
                    self.updateSelectedChip(with: selectedValue, and: query)
                }
            }
            self.present(bottomSheet, animated: true, completion: nil)
        }
    }
    
    /// Number Range Component
    private func showNumberRangeSelectorComponent() {
        if let selectedCategory = resultsViewModel?.getSelectedCategory() {
            let viewController = SearchNumberRangeComponentViewController.instantiateViewController()
            let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
            bottomSheet.dismissOnDraggingDownSheet = false
            bottomSheet.delegate = self
            viewController.coordinatorServices = coordinatorServices
            viewController.numberRangeViewModel.selectedCategory = selectedCategory
            viewController.callback = { (category, query, isBackButtonTapped) in
                if isBackButtonTapped {
                    self.resetChip()
                } else {
                    let selectedValue = category?.component?.settings?.selectedValue
                    self.updateSelectedChip(with: selectedValue, and: query)
                }
            }
            self.present(bottomSheet, animated: true, completion: nil)
        }
    }
    
    /// Slider Component
    private func showSliderSelectorComponent() {
        if let selectedCategory = resultsViewModel?.getSelectedCategory() {
            let viewController = SearchSliderRangeComponentViewController.instantiateViewController()
            let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
            bottomSheet.dismissOnDraggingDownSheet = false
            bottomSheet.delegate = self
            viewController.coordinatorServices = coordinatorServices
            viewController.sliderViewModel.selectedCategory = selectedCategory
            viewController.callback = { (category, query, isBackButtonTapped) in
                if isBackButtonTapped {
                    self.resetChip()
                } else {
                    let selectedValue = category?.component?.settings?.selectedValue
                    self.updateSelectedChip(with: selectedValue, and: query)
                }
            }
            self.present(bottomSheet, animated: true, completion: nil)
        }
    }
    
    /// Calendar Component
    private func showCalendarSelectorComponent() {
        if let selectedCategory = resultsViewModel?.getSelectedCategory() {
            let viewController = SearchCalendarComponentViewController.instantiateViewController()
            let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
            bottomSheet.dismissOnDraggingDownSheet = false
            bottomSheet.delegate = self
            viewController.coordinatorServices = coordinatorServices
            viewController.calendarViewModel.selectedCategory = selectedCategory
            viewController.callback = { (category, query, isBackButtonTapped) in
                if isBackButtonTapped {
                    self.resetChip()
                } else {
                    let selectedValue = category?.component?.settings?.selectedValue
                    self.updateSelectedChip(with: selectedValue, and: query)
                }
            }
            self.present(bottomSheet, animated: true, completion: nil)
        }
    }
    
    // Facet Component
    private func showFacetSelectorComponent(componentType: ComponentType?, name: String) {
        if let componentType = componentType {
            if componentType == .facetQuery, let facetQueries = resultsViewModel?.facetQueries {
                let viewController = SearchFacetListComponentViewController.instantiateViewController()
                let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
                bottomSheet.dismissOnDraggingDownSheet = false
                bottomSheet.delegate = self
                viewController.coordinatorServices = coordinatorServices
                viewController.facetViewModel.facetQueryOptions = facetQueries
                viewController.facetViewModel.selectedFacetQueryString = name
                viewController.callback = { (value, query, isBackButtonTapped) in
                    if isBackButtonTapped {
                        self.resetChip()
                    } else {
                        self.updateSelectedChip(with: value, and: query)
                    }
                }
                self.present(bottomSheet, animated: true, completion: nil)
            }
        }
    }
    
    func updateSelectedChip(with value: String?, and query: String?) {
        let index = resultsViewModel?.getIndexOfSelectedChip(for: searchChipsViewModel.chips) ?? -1
        if index >= 0 {
            let chip = searchChipsViewModel.chips[index]
            if let selectedValue = value, !selectedValue.isEmpty {
                chip.selectedValue = selectedValue
                chip.query = query
                searchChipsViewModel.chips[index] = chip
                reloadChipCollectionWithoutScroll()
                resultScreenDelegate?.chipTapped(chip: chip)
                resultsListController?.scrollToSection(0)

            } else {
                let indexPath = IndexPath(row: index, section: 0)
                chip.selectedValue = ""
                chip.query = nil
                searchChipsViewModel.chips[index] = chip
                reloadChipCollectionWithoutScroll()
                self.deSelectChipCollectionCell(for: indexPath)
                resultScreenDelegate?.chipTapped(chip: chip)
                resultsListController?.scrollToSection(0)
            }
        }
    }
    
    func reloadChipCollectionWithoutScroll() {
        DispatchQueue.main.async {
            self.chipsCollectionView.reloadDataWithoutScroll()
        }
    }
}

// MARK: - Reset Search
extension ResultViewController {
    private func resetSelectedSearchFilter() {
        self.resultsViewModel?.searchModel.selectedSearchFilter = resultsViewModel?.defaultSearchFilter()
        updateCategory()
    }
    
    private func resetChipCollectionView() {
        let index = resultsViewModel?.getSelectedFilterIndex() ?? -1
        if index >= 0, let searchFilters = resultsViewModel?.searchFilters {
            guard let chipItems = resultsViewModel?.searchModel.defaultSearchChips(for: searchFilters, and: index) else { return }
            self.updateChips(chipItems)
        }
    }
        
    @IBAction func resetFilterButtonAction(_ sender: Any) {
        self.updateCategory()
        resultScreenDelegate?.resetSearchFilterTapped()
    }
}

extension ResultViewController: MDCBottomSheetControllerDelegate {
    func bottomSheetControllerDidDismissBottomSheet(_ controller: MDCBottomSheetController) {
        self.resetChip()
    }
    
    func resetChip() {
        let index = resultsViewModel?.getIndexOfSelectedChip(for: searchChipsViewModel.chips) ?? -1
        if index >= 0 {
            let chip = searchChipsViewModel.chips[index]
            let selectedValue = chip.selectedValue
            if selectedValue.isEmpty {
                let indexPath = IndexPath(row: index, section: 0)
                self.deSelectChipCollectionCell(for: indexPath)
                reloadChipCollectionWithoutScroll()
            }
        }
    }
}

// MARK: - Result Controller Delegate
extension ResultViewController: ResultPageControllerDelegate {
    func didUpdateChips(error: Error?,
                        facetFields: [SearchFacetFields],
                        facetQueries: [SearchFacetQueries],
                        facetIntervals: [SearchFacetIntervals]) {
        
        resultsViewModel?.facetFields = facetFields
        resultsViewModel?.facetQueries = facetQueries
        resultsViewModel?.facetIntervals = facetIntervals
        
        guard let model = pageController?.dataSource else { return }
        if !model.isEmpty() {
            guard let chipItems = resultsViewModel?.searchModel.facetSearchChips(for: facetFields, facetQueries: facetQueries, facetIntervals: facetIntervals) else { return }
            self.updateChips(chipItems)
        } else {
            guard let chipItems = resultsViewModel?.searchModel.facetSearchChips(for: [], facetQueries: [], facetIntervals: []) else { return }
            self.updateChips(chipItems)
        }
    }
}

// MARK: - Storyboard Instantiable

extension ResultViewController: StoryboardInstantiable { }
