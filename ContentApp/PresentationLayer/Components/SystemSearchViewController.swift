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

class SystemSearchViewController: SystemThemableViewController {
    var searchViewModel: SearchViewModelProtocol?
    var resultViewModel: ResultsViewModel?
    weak var folderDrillDownScreenCoordinatorDelegate: FolderDrilDownScreenCoordinatorDelegate?
    var tagSearchController: UISearchController?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        tagSearchController = createSearchController()

        if searchViewModel?.shouldDisplaySearchBar() ?? false {
            navigationItem.searchController = tagSearchController
        }
        if searchViewModel?.shouldDisplaySearchButton() ?? false {
            addSearchButton()
        }
    }

    // MARK: - Public Methods

    func cancelSearchMode() {
        self.navigationItem.searchController?.searchBar.text = ""
        self.navigationItem.searchController?.dismiss(animated: false, completion: nil)
    }

    func configureNavigationBar() {
        definesPresentationContext = true
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.hidesSearchBarWhenScrolling = false

        // Remove navigation bar underline separator
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    // MARK: - IBActions

    @objc func searchButtonTapped() {
        tagSearchController?.searchBar.isHidden = true
        navigationItem.searchController = tagSearchController
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.tagSearchController?.isActive = true
            sSelf.tagSearchController?.searchBar.becomeFirstResponder()
        }
    }

    // MARK: - Private Helpers

    override func applyComponentsThemes() {
        guard let currentTheme = self.themingService?.activeTheme else { return }

        view.backgroundColor = currentTheme.backgroundColor
        navigationController?.navigationBar.tintColor = currentTheme.primaryVariantColor
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = currentTheme.backgroundColor
    }

    private func addSearchButton() {
        let searchButton = UIButton(type: .custom)
        searchButton.frame = CGRect(x: 0.0, y: 0.0, width: accountSettingsButtonHeight, height: accountSettingsButtonHeight)
        searchButton.imageView?.contentMode = .scaleAspectFill
        searchButton.layer.cornerRadius = accountSettingsButtonHeight / 2
        searchButton.layer.masksToBounds = true
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: UIControl.Event.touchUpInside)
        searchButton.setImage(UIImage(named: "search-icon"), for: .normal)

        let searchBarButtonItem = UIBarButtonItem(customView: searchButton)
        let currWidth = searchBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: accountSettingsButtonHeight)
        currWidth?.isActive = true
        let currHeight = searchBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: accountSettingsButtonHeight)
        currHeight?.isActive = true

        self.navigationItem.rightBarButtonItem = searchBarButtonItem
    }

    private func createSearchController() -> UISearchController {
        let rvc = ResultViewController.instantiateViewController()
        rvc.themingService = themingService
        rvc.resultScreenDelegate = self
        rvc.resultsViewModel = resultViewModel
        rvc.folderDrillDownScreenCoordinatorDelegate = self.folderDrillDownScreenCoordinatorDelegate
        let searchController = UISearchController(searchResultsController: rvc)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.smartQuotesType = .no
        searchController.searchBar.isHidden = false
        return searchController
    }
}

// MARK: - Result Screen Delegate

extension SystemSearchViewController: ResultViewControllerDelegate {
    func chipTapped(chip: SearchChipItem) {
        guard let rvc = navigationItem.searchController?.searchResultsController as? ResultViewController,
            let searchViewModel = self.searchViewModel else { return }

        rvc.startLoading()
        rvc.reloadChips(searchViewModel.logicSearchChips(chipTapped: chip))
        searchViewModel.performLiveSearch(for: navigationItem.searchController?.searchBar.text)
    }

    func recentSearchTapped(string: String) {
        guard let rvc = navigationItem.searchController?.searchResultsController as? ResultViewController,
            let searchBar = navigationItem.searchController?.searchBar,
            let searchViewModel = self.searchViewModel else { return }

        rvc.startLoading()
        searchBar.text = string
        searchViewModel.performLiveSearch(for: string)
    }

    func elementListTapped(elementList: ListNode) {
        guard let rvc = navigationItem.searchController?.searchResultsController as? ResultViewController,
            let searchBar = navigationItem.searchController?.searchBar else { return }
        rvc.recentSearchesViewModel.save(recentSearch: searchBar.text)
    }

    func fetchNextSearchResultsPage(for index: IndexPath) {
        guard let searchBar = navigationItem.searchController?.searchBar, let searchViewModel = self.searchViewModel else { return }
        let searchString = searchBar.text
        searchViewModel.fetchNextSearchResultsPage(for: searchString, index: index)
    }
}

// MARK: - UISearchController Delegate

extension SystemSearchViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        guard let rvc = searchController.searchResultsController as? ResultViewController,
            let searchViewModel = self.searchViewModel else { return }
        searchController.searchBar.isHidden = false
        rvc.updateChips(searchViewModel.defaultSearchChips())
        rvc.updateRecentSearches()
        rvc.clearDataSource()
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.isHidden = false
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        if searchViewModel?.shouldDisplaySearchBar() == false {
            navigationItem.searchController = nil
            navigationController?.view.setNeedsLayout()
            navigationController?.view.layoutIfNeeded()
        }
    }
}

// MARK: - UISearchBar Delegate

extension SystemSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let rvc = navigationItem.searchController?.searchResultsController as? ResultViewController,
            let searchViewModel = self.searchViewModel else { return }

        searchViewModel.performSearch(for: searchBar.text)
        rvc.recentSearchesViewModel.save(recentSearch: searchBar.text)
        rvc.startLoading()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let rvc = navigationItem.searchController?.searchResultsController as? ResultViewController else { return }

        rvc.view.isHidden = false
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let rvc = navigationItem.searchController?.searchResultsController as? ResultViewController,
            let searchViewModel = self.searchViewModel else { return }

        searchViewModel.performLiveSearch(for: searchText)
        rvc.updateRecentSearches()
        if searchText.canPerformLiveSearch() {
            rvc.startLoading()
        }
    }
}

// MARK: - UISearch Results Updating

extension SystemSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let rvc = searchController.searchResultsController as? ResultViewController else { return }

        rvc.view.isHidden = false
    }
}
