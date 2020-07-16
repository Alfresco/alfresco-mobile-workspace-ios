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

class ListViewController: SystemThemableViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    weak var tabBarScreenDelegate: TabBarScreenDelegate?
    var listViewModel: ListViewModelProtocol?
    var searchViewModel: SearchViewModelProtocol?

    private var settingsButtonHeight: CGFloat = 30.0
    private var nodeHeighCell: CGFloat = 64.0
    private var settingsButton = UIButton(type: .custom)

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        listViewModel?.viewModelDelegate = self
        searchViewModel?.viewModelDelegate = self

        configureNavigationBar()
        addSettingsButton()
        addSearchController()

        registerListElementCell()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAvatarInSettingsButton()
    }

    // MARK: - IBActions

    @objc func settingsButtonTapped() {
        tabBarScreenDelegate?.showSettingsScreen()
    }

    // MARK: - Helpers

    func configureNavigationBar() {
        definesPresentationContext = true
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    func addSettingsButton() {
        settingsButton.frame = CGRect(x: 0.0, y: 0.0, width: settingsButtonHeight, height: settingsButtonHeight)
        addAvatarInSettingsButton()
        settingsButton.imageView?.contentMode = .scaleAspectFill
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: UIControl.Event.touchUpInside)
        settingsButton.layer.cornerRadius = settingsButtonHeight / 2
        settingsButton.layer.masksToBounds = true

        let settingsBarButtonItem = UIBarButtonItem(customView: settingsButton)
        let currWidth = settingsBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: settingsButtonHeight)
        currWidth?.isActive = true
        let currHeight = settingsBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: settingsButtonHeight)
        currHeight?.isActive = true

        self.navigationItem.leftBarButtonItem = settingsBarButtonItem
    }

    func addSearchController() {
        let rvc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ResultViewController.self)) as? ResultViewController
        rvc?.themingService = themingService
        rvc?.resultScreenDelegate = self
        let searchController = UISearchController(searchResultsController: rvc)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        navigationItem.searchController = searchController
    }

    func addAvatarInSettingsButton() {
        let avatarImage = listViewModel?.getAvatar(completionHandler: { [weak self] image in
            guard let sSelf = self else { return }

            if let fetchedImage = image {
                sSelf.settingsButton.setImage(fetchedImage, for: .normal)
            }
        })
        settingsButton.setImage(avatarImage, for: .normal)
    }

    func registerListElementCell() {
        let identifier = String(describing: ListElementCollectionViewCell.self)
        collectionView?.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
    }

    override func applyComponentsThemes() {
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.tintColor = .label
            navigationItem.leftBarButtonItem?.tintColor = .label
        } else {
            navigationController?.navigationBar.tintColor = .black
            navigationItem.leftBarButtonItem?.tintColor = .black
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension ListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listViewModel?.resultsList.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let node = listViewModel?.resultsList[indexPath.row] else { return UICollectionViewCell() }
        let identifier = String(describing: ListElementCollectionViewCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ListElementCollectionViewCell
        cell?.element = node
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: nodeHeighCell)
    }
}

// MARK: - Result Screen Delegate

extension ListViewController: ResultScreenDelegate {
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

    func elementListTapped(elementList: ListElementProtocol) {
        guard let searchBar = navigationItem.searchController?.searchBar,
            let searchViewModel = self.searchViewModel else { return }

        searchViewModel.save(recentSearch: searchBar.text)
    }
}

// MARK: - Search ViewModel Delegate

extension ListViewController: SearchViewModelDelegate {
    func handle(results: [ListElementProtocol]?) {
        guard let rvc = navigationItem.searchController?.searchResultsController as? ResultViewController else { return }
        
        rvc.updateDataSource(results)
    }
}

extension ListViewController: ListViewModelDelegate {
    func handleRecent(results: [ListElementProtocol]?) {
        collectionView.reloadData()
    }
}

// MARK: - UISearchBar Delegate

extension ListViewController: UISearchBarDelegate {
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

extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let rvc = searchController.searchResultsController as? ResultViewController else { return }

        rvc.view.isHidden = false
    }
}

// MARK: - UISearchController Delegate

extension ListViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        guard let rvc = searchController.searchResultsController as? ResultViewController,
            let searchViewModel = self.searchViewModel else { return }

        rvc.updateChips(searchViewModel.defaultSearchChips())
        rvc.updateRecentSearches(searchViewModel.recentSearches())
        rvc.updateDataSource(nil)
    }
}

// MARK: - Storyboard Instantiable

extension ListViewController: StoryboardInstantiable { }
