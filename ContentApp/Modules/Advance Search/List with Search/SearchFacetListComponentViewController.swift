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
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming

class SearchFacetListComponentViewController: SystemThemableViewController {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var headerDivider: UIView!
    @IBOutlet weak var listViewDivider: UIView!
    @IBOutlet weak var applyButton: MDCButton!
    @IBOutlet weak var resetButton: MDCButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightTableView: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var heightSearchView: NSLayoutConstraint!
    @IBOutlet weak var searchView: UIView!
    
    var facetViewModel: SearchFacetListComponentViewModel { return controller.facetViewModel }
    lazy var controller: SearchFacetListComponentController = { return SearchFacetListComponentController() }()
    let maxHeightTableView: CGFloat =  UIConstants.ScreenHeight - 300.0
    var callback: FacetComponentsCallBack?
    var isKeyboardOpen = false
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = UIConstants.cornerRadiusDialog
        baseView.layer.cornerRadius = UIConstants.cornerRadiusDialog
        view.isHidden = true
        hideKeyboardWhenTappedAround()
        tableView.estimatedRowHeight = 1000
        facetViewModel.saveTemporaryDataForSearchResults()
        controller.updatedSelectedValues()
        applyLocalization()
        applyComponentsThemes()
        registerCells()
        controller.buildViewModel()
        setupBindings()
        heightSearchView.constant = facetViewModel.heightAndAlphaOfSearchView().height
        searchView.alpha = facetViewModel.heightAndAlphaOfSearchView().alpha
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        view.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillAppear() {
        isKeyboardOpen = true
    }

    @objc func keyboardWillDisappear() {
        isKeyboardOpen = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculatePreferredSize(view.bounds.size)
    }
    
    private func calculatePreferredSize(_ size: CGSize) {
        if isKeyboardOpen == false {
            let targetSize = CGSize(width: size.width,
                                    height: UIView.layoutFittingCompressedSize.height)
            preferredContentSize = view.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .defaultLow)
        }
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        calculatePreferredSize(size)
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
    }
    
    // MARK: - Apply Themes and Localization
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme,
              let buttonScheme = coordinatorServices?.themingService?.containerScheming(for: .dialogButton),
              let bigButtonScheme = coordinatorServices?.themingService?.containerScheming(for: .loginBigButton) else { return }
        
        view.backgroundColor = currentTheme.surfaceColor
        headerTitleLabel.applyeStyleHeadline6OnSurface(theme: currentTheme)
        dismissButton.tintColor = currentTheme.onSurfaceColor
        headerDivider.backgroundColor = currentTheme.onSurface12Color
        listViewDivider.backgroundColor = currentTheme.onSurface12Color
        
        applyButton.applyContainedTheme(withScheme: buttonScheme)
        applyButton.isUppercaseTitle = false
        applyButton.setShadowColor(.clear, for: .normal)
        applyButton.layer.cornerRadius = UIConstants.cornerRadiusDialog
        
        resetButton.applyContainedTheme(withScheme: bigButtonScheme)
        resetButton.setBackgroundColor(currentTheme.onSurface5Color, for: .normal)
        resetButton.isUppercaseTitle = false
        resetButton.setShadowColor(.clear, for: .normal)
        resetButton.setTitleColor(currentTheme.onSurfaceColor, for: .normal)
        resetButton.layer.cornerRadius = UIConstants.cornerRadiusDialog
    }
    
    private func applyLocalization() {
        headerTitleLabel.text = facetViewModel.title
        applyButton.setTitle(LocalizationConstants.AdvanceSearch.apply, for: .normal)
        resetButton.setTitle(LocalizationConstants.AdvanceSearch.reset, for: .normal)
        searchBar.placeholder = LocalizationConstants.AdvanceSearch.searchPlaceholder
    }
    
    func registerCells() {
        self.tableView.register(UINib(nibName: CellConstants.TableCells.listItem, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.listItem)
    }
    
    // MARK: - Set up Bindings
    private func setupBindings() {
        /* observing rows */
        self.facetViewModel.rowViewModels.addObserver() { [weak self] (rows) in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    @IBAction func dismissButtonAction(_ sender: Any) {
        let isBackButtonTapped = true
        let value = facetViewModel.selectedSearchFacetString
        let query = facetViewModel.queryBuilder
        self.callback?(value, query, isBackButtonTapped)
        self.dismiss(animated: true, completion: nil)
    }
        
    @IBAction func applyButtonAction(_ sender: Any) {
        let isBackButtonTapped = false
        self.controller.applyFilter()
        let value = facetViewModel.selectedSearchFacetString
        let query = facetViewModel.queryBuilder
        self.callback?(value, query, isBackButtonTapped)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetButtonAction(_ sender: Any) {
        let isBackButtonTapped = false
        self.controller.resetFilter()
        let value = facetViewModel.selectedSearchFacetString
        let query = facetViewModel.queryBuilder
        self.callback?(value, query, isBackButtonTapped)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Table View Data Source and Delegates
extension SearchFacetListComponentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.facetViewModel.rowViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowViewModel = facetViewModel.rowViewModels.value[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: controller.cellIdentifier(for: rowViewModel), for: indexPath)
        if let cell = cell as? CellConfigurable {
            cell.setup(viewModel: rowViewModel)
        }
        if cell is ListItemTableViewCell {
            if let theme = coordinatorServices?.themingService {
                (cell as? ListItemTableViewCell)?.applyTheme(with: theme)
            }
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.view.layoutSubviews()
        DispatchQueue.main.async {
            self.heightTableView?.constant = ( self.tableView.contentSize.height < self.maxHeightTableView ) ? self.tableView.contentSize.height : self.maxHeightTableView
        }
        self.view.layoutIfNeeded()
    }
}

// MARK: - UISearchBar Delegate
extension SearchFacetListComponentViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            facetViewModel.searchFacetOptions = facetViewModel.tempSearchFacetOptions
        } else {
            facetViewModel.searchFacetOptions = facetViewModel.tempSearchFacetOptions.filter({ NSLocalizedString($0.label ?? "", comment: "").lowercased().contains(searchText.lowercased()) })
        }
        controller.buildViewModel()
    }
}

// MARK: - Storyboard Instantiable
extension SearchFacetListComponentViewController: SearchComponentsStoryboardInstantiable { }
