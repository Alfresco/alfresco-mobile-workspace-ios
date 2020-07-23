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

    @IBOutlet weak var activityIndicatorSuperview: UIView!
    var activityIndicator: ActivityIndicatorView?

    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListTitle: UILabel!
    @IBOutlet weak var emptyListSubtitle: UILabel!
    @IBOutlet weak var emptyListImageView: UIImageView!

    weak var tabBarScreenDelegate: TabBarScreenDelegate?
    var listViewModel: ListViewModelProtocol?
    var searchViewModel: SearchViewModelProtocol?

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
        emptyListView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAvatarInSettingsButton()
        activityIndicator = ActivityIndicatorView(currentTheme: themingService?.activeTheme,
                                                  configuration: ActivityIndicatorConfiguration(title: "" ,
                                                                                                radius: 12,
                                                                                                strokeWidth: 2,
                                                                                                cycleColors: [themingService?.activeTheme?.primaryVariantColor ?? .black]))
        if let activityIndicator = activityIndicator {
            activityIndicatorSuperview.addSubview(activityIndicator)
            activityIndicatorSuperview.isHidden = true
        }
        if emptyListView.isHidden && listViewModel?.groupedLists.count == 0 {
            self.startLoading()
        }
        collectionView.reloadData()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
    }

    // MARK: - IBActions

    @objc func settingsButtonTapped() {
        tabBarScreenDelegate?.showSettingsScreen()
    }

    // MARK: - Coordinator Public Methods

    func popToRoot() {
    }

    func scrollToTop() {
        self.scrollToSection(0)
    }

    // MARK: - Helpers

    func startLoading() {
        activityIndicatorSuperview.isHidden = false
        activityIndicator?.state = .isLoading
    }

    func stopLoading() {
        activityIndicatorSuperview.isHidden = true
        activityIndicator?.state = .isIdle
    }

    func configureNavigationBar() {
        definesPresentationContext = true
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    func addSettingsButton() {
        settingsButton.frame = CGRect(x: 0.0, y: 0.0, width: accountSettingsButtonHeight, height: accountSettingsButtonHeight)
        addAvatarInSettingsButton()
        settingsButton.imageView?.contentMode = .scaleAspectFill
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: UIControl.Event.touchUpInside)
        settingsButton.layer.cornerRadius = accountSettingsButtonHeight / 2
        settingsButton.layer.masksToBounds = true

        let settingsBarButtonItem = UIBarButtonItem(customView: settingsButton)
        let currWidth = settingsBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: accountSettingsButtonHeight)
        currWidth?.isActive = true
        let currHeight = settingsBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: accountSettingsButtonHeight)
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
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.smartQuotesType = .no
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
        guard let currentTheme = self.themingService?.activeTheme else { return }
        emptyListSubtitle.applyeStyleHeadline5OnSurface(theme: currentTheme)
        emptyListSubtitle.applyStyleSubtitle1OnSurface(theme: currentTheme)

        emptyListView.backgroundColor = currentTheme.backgroundColor
        view.backgroundColor = currentTheme.backgroundColor
        navigationController?.navigationBar.tintColor = currentTheme.primaryVariantColor
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = currentTheme.backgroundColor
    }

    func addLocalization() {
        emptyListTitle.text = LocalizationConstants.Search.title
        emptyListSubtitle.text = LocalizationConstants.Search.subtitle
    }

    func scrollToSection(_ section: Int) {
        guard let results = self.listViewModel?.groupedLists, !results.isEmpty else { return }
        let indexPath = IndexPath(item: 0, section: section)
        if let attributes = collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
            let topOfHeader = CGPoint(x: 0, y: attributes.frame.origin.y - collectionView.contentInset.top)
            collectionView.setContentOffset(topOfHeader, animated: true)
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension ListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listViewModel?.groupedLists[section].list.count ?? 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return listViewModel?.groupedLists.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let node = listViewModel?.groupedLists[indexPath.section].list[indexPath.row] else { return UICollectionViewCell() }
        let identifier = String(describing: ListElementCollectionViewCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ListElementCollectionViewCell
        cell?.element = node
        cell?.applyThemingService(themingService?.activeTheme)
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: listItemNodeCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let identifier = String(describing: ListSectionCollectionReusableView.self)
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier,
                                                                                   for: indexPath) as? ListSectionCollectionReusableView else {
                                                                                    fatalError("Invalid ListSectionCollectionReusableView type") }
            headerView.titleLabel.text = listViewModel?.groupedLists[indexPath.section].titleGroup
            headerView.applyTheme(themingService?.activeTheme)
            return headerView
        default:
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let viewModel = listViewModel, viewModel.shouldDisplaySections() {
            return CGSize(width: self.view.bounds.width, height: listSectionCellHeight)
        } else {
            return CGSize(width: self.view.bounds.width, height: 0)
        }
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
// MARK: - List ViewModel Delegate

extension ListViewController: ListViewModelDelegate {
    func handleList() {
        self.stopLoading()
        emptyListView.isHidden = !(listViewModel?.groupedLists.isEmpty ?? false)
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
