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

class RecentViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var settingsButton = UIButton(type: .custom)
    var searchController: UISearchController?
    var resultViewController: ResultViewController?

    var themingService: MaterialDesignThemingService?
    weak var tabBarScreenDelegate: TabBarScreenDelegate?
    var recentViewModel: RecentViewModel?
    var searchViewModel: SearchViewModel?

    var settingsButtonHeight: CGFloat = 30

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        recentViewModel?.viewModelDelegate = self
        searchViewModel?.viewModelDelegate = self

        configureNavigationBar()
        addSettingsButton()
        addSearchController()

        addLocalization()
        registerAlfrescoNodeCell()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addMaterialComponentsTheme()
        addAvatar()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        themingService?.activateUserSelectedTheme()
        addMaterialComponentsTheme()
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
        settingsButton.setImage(UIImage(named: "account-circle"), for: .normal)
        if let avatar = DiskServices.get(image: kProfileAvatarImageFileName, from: recentViewModel?.accountService?.activeAccount?.identifier ?? "") {
            settingsButton.setImage(avatar, for: .normal)
            settingsButton.imageView?.contentMode = .scaleAspectFill
        }
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
        resultViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ResultViewController.self)) as? ResultViewController
        resultViewController?.themingService = themingService
        searchController = UISearchController(searchResultsController: resultViewController)
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.delegate = self
        searchController?.delegate = self
        searchController?.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }

    func addAvatar() {
        if let avatar = DiskServices.get(image: kProfileAvatarImageFileName, from: recentViewModel?.accountService?.activeAccount?.identifier ?? "") {
            settingsButton.setImage(avatar, for: .normal)
        }
    }

    func registerAlfrescoNodeCell() {
        let identifier = String(describing: AlfrescoNodeCollectionViewCell.self)
        collectionView?.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
    }

    func addLocalization() {
        self.title = LocalizationConstants.ScreenTitles.recent
    }

    func addMaterialComponentsTheme() {
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

extension RecentViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recentViewModel?.nodes.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let node = recentViewModel?.nodes[indexPath.row] else { return UICollectionViewCell() }
        let identifier = String(describing: AlfrescoNodeCollectionViewCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? AlfrescoNodeCollectionViewCell
        cell?.node = node
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: 64.0)
    }
}

// MARK: - Recent ViewModel Delegate

extension RecentViewController: RecentViewModelDelegate {
    func didUpdateAvatarImage(image: UIImage) {
        settingsButton.setImage(image, for: .normal)
    }
}

extension RecentViewController: SearchViewModelDelegate {
    func search(results: [AlfrescoNode]) {
        resultViewController?.resultsNodes = results
        resultViewController?.emptyList = !results.isEmpty
    }
}

// MARK: - UISearchBar Delegate

extension RecentViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let stringSearch = searchBar.text {
            searchViewModel?.performSearch(for: stringSearch)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultViewController?.resultsNodes = []
        resultViewController?.emptyList = true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchController?.searchResultsController?.view.isHidden = false
    }
}

// MARK: - UISearch Results Updating

extension RecentViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
}

// MARK: - UISearchController Delegate

extension RecentViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        resultViewController?.resultsNodes = []
        searchController.searchResultsController?.view.isHidden = false
    }
}

// MARK: - Storyboard Instantiable

extension RecentViewController: StoryboardInstantiable { }
