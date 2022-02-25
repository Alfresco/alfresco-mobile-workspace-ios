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

protocol ResultViewControllerDelegate: AnyObject {
    func recentSearchTapped(string: String)
    func elementListTapped(elementList: ListNode)
}

class ResultViewController: SystemThemableViewController {
    @IBOutlet weak var recentSearchCollectionView: UICollectionView!
    @IBOutlet weak var recentSearchesView: UIView!
    @IBOutlet weak var recentSearchesTitle: UILabel!
    @IBOutlet weak var progressView: MDCProgressView!
    weak var resultScreenDelegate: ResultViewControllerDelegate?
    weak var listItemActionDelegate: ListItemActionDelegate?
    private var presenter: UINavigationController?
    var resultsListController: ListComponentViewController?
    var pageController: ListPageController?
    var resultsViewModel: SearchViewModel?
    var recentSearchesViewModel = RecentSearchesViewModel()
    private let recentSearchCellHeight: CGFloat = 44.0

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

            view.insertSubview(listComponentView, aboveSubview: progressView)
            listComponentView.topAnchor.constraint(equalTo: progressView.bottomAnchor,
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
        self.resultsViewModel?.searchModel.selectedSearchFilter = self.resultsViewModel?.searchFilters[1]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.isHidden = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultsListController?.viewWillAppear(animated)

        let activeTheme = coordinatorServices.themingService?.activeTheme
        progressView.progressTintColor = activeTheme?.primaryT1Color
        progressView.trackTintColor = activeTheme?.primary30T1Color
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        recentSearchCollectionView.reloadData()
        resultsListController?.willTransition(to: newCollection, with: coordinator)

        let activeTheme = coordinatorServices.themingService?.activeTheme
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
        pageController?.clear()
        recentSearchesView.isHidden = false
    }

    func updateRecentSearches() {
        recentSearchesViewModel.reloadRecentSearch()
        recentSearchesTitle.text = (recentSearchesViewModel.searches.isEmpty) ?
            LocalizationConstants.Search.noRecentSearch : LocalizationConstants.Search.recentSearch
        recentSearchCollectionView.reloadData()
    }

    // MARK: - Helpers

    func addLocalization() {
        recentSearchesTitle.text = LocalizationConstants.Search.noRecentSearch
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices.themingService?.activeTheme else { return }
        recentSearchesTitle.applyStyleSubtitle2OnSurface(theme: currentTheme)
        view.backgroundColor = currentTheme.surfaceColor
        recentSearchesView.backgroundColor = currentTheme.surfaceColor
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension ResultViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case recentSearchCollectionView:
            return recentSearchesViewModel.searches.count
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
            cell?.applyTheme(coordinatorServices.themingService?.activeTheme)
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

// MARK: - Storyboard Instantiable

extension ResultViewController: StoryboardInstantiable { }
