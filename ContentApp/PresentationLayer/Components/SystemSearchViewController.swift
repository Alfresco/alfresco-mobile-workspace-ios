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

    override func viewDidLoad() {
        super.viewDidLoad()

        addSearchController()
    }

    func addSearchController() {
        let rvc = ResultViewController.instantiateViewController()
        rvc.themingService = themingService
        rvc.resultScreenDelegate = self // TODO: To change to other viewmodel?
        rvc.resultsViewModel = resultViewModel
        rvc.folderDrillDownScreenCoordinatorDelegate = self.folderDrillDownScreenCoordinatorDelegate
        let searchController = UISearchController(searchResultsController: rvc)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.smartQuotesType = .no
        navigationItem.searchController = searchController
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
        guard let searchBar = navigationItem.searchController?.searchBar,
            let searchViewModel = self.searchViewModel else { return }

        searchBar.text = string
        searchViewModel.performLiveSearch(for: string)
    }

    func elementListTapped(elementList: ListNode) {
        guard let searchBar = navigationItem.searchController?.searchBar,
            let searchViewModel = self.searchViewModel else { return }

        searchViewModel.save(recentSearch: searchBar.text)
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

        rvc.updateChips(searchViewModel.defaultSearchChips())
        rvc.updateRecentSearches(searchViewModel.recentSearches())
        rvc.clearDataSource()
    }
}

// MARK: - UISearchBar Delegate

extension SystemSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let rvc = navigationItem.searchController?.searchResultsController as? ResultViewController,
            let searchViewModel = self.searchViewModel else { return }

        rvc.startLoading()
        searchViewModel.performSearch(for: searchBar.text)
        searchViewModel.save(recentSearch: navigationItem.searchController?.searchBar.text)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let rvc = navigationItem.searchController?.searchResultsController as? ResultViewController else { return }

        rvc.view.isHidden = false
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let rvc = navigationItem.searchController?.searchResultsController as? ResultViewController,
            let searchViewModel = self.searchViewModel else { return }

        searchViewModel.performLiveSearch(for: searchText)
        rvc.updateRecentSearches(searchViewModel.recentSearches())
    }
}

// MARK: - UISearch Results Updating

extension SystemSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let rvc = searchController.searchResultsController as? ResultViewController else { return }

        rvc.view.isHidden = false
    }
}
