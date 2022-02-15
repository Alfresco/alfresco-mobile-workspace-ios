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
import MaterialComponents.MaterialDialogs

class SystemSearchViewController: SystemThemableViewController {
    private var resultsViewController: ResultViewController?
    private var searchController: UISearchController?
    private let searchButtonAspectRatio: CGFloat = 30.0

    var searchViewModel: SearchViewModel?
    var searchPageController: ListPageController?

    weak var listItemActionDelegate: ListItemActionDelegate?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        searchController = createSearchController()
        if searchViewModel?.shouldDisplaySearchBar() ?? false {
            navigationItem.searchController = searchController
        }
        if searchViewModel?.shouldDisplaySearchButton() ?? false {
            addSearchButton()
            addBackButton()
        }
        
        // unauthorized Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleUnauthorizedAPIAccess(notification:)),
                                               name: Notification.Name(KeyConstants.Notification.unauthorizedRequest),
                                               object: nil)
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        resultsViewController?.viewWillTransition(to: size, with: coordinator)
        resultsViewController?.stopLoading()
    }

    // MARK: - Public Methods

    func cancelSearchMode() {
        searchViewModel?.searchModel.searchString = nil
        self.navigationItem.searchController?.searchBar.text = ""
        self.navigationItem.searchController?.isActive = false
    }

    func configureNavigationBar() {
        definesPresentationContext = true
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.hidesSearchBarWhenScrolling = false

        // Back Button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.backIndicatorImage =  UIImage(named: "ic-back")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage =  UIImage(named: "ic-back")
    }

    // MARK: - IBActions

    @objc func searchButtonTapped() {
        AlfrescoLog.debug("search button action")
    }

    // MARK: - Private Helpers

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices.themingService?.activeTheme else { return }
            
        view.backgroundColor = currentTheme.surfaceColor
        let image = UIImage(color: currentTheme.surfaceColor,
                            size: navigationController?.navigationBar.bounds.size)
        navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = currentTheme.surfaceColor
        navigationController?.navigationBar.tintColor = currentTheme.onSurface60Color
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = currentTheme.surfaceColor
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: currentTheme.headline6TextStyle.font,
             NSAttributedString.Key.foregroundColor: currentTheme.onSurfaceColor]
    }

    private func addSearchButton() {
        let searchButton = UIButton(type: .custom)
        searchButton.accessibilityIdentifier = "searchButton"
        searchButton.frame = CGRect(x: 0.0, y: 0.0,
                                    width: searchButtonAspectRatio,
                                    height: searchButtonAspectRatio)
        searchButton.imageView?.contentMode = .scaleAspectFill
        searchButton.layer.cornerRadius = searchButtonAspectRatio / 2
        searchButton.layer.masksToBounds = true
        searchButton.addTarget(self,
                               action: #selector(searchButtonTapped),
                               for: UIControl.Event.touchUpInside)
        searchButton.setImage(UIImage(named: "ic-search"),
                              for: .normal)

        let searchBarButtonItem = UIBarButtonItem(customView: searchButton)
        searchBarButtonItem.accessibilityIdentifier = "searchBarButton"
        let currWidth = searchBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: searchButtonAspectRatio)
        currWidth?.isActive = true
        let currHeight = searchBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: searchButtonAspectRatio)
        currHeight?.isActive = true

        self.navigationItem.rightBarButtonItem = searchBarButtonItem
    }
    
    private func addBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.accessibilityIdentifier = "backButton"
        backButton.frame = CGRect(x: 0.0, y: 0.0,
                                    width: searchButtonAspectRatio,
                                    height: searchButtonAspectRatio)
        backButton.imageView?.contentMode = .scaleAspectFill
        backButton.layer.masksToBounds = true
        backButton.addTarget(self,
                               action: #selector(backButtonTapped),
                               for: UIControl.Event.touchUpInside)
        backButton.setImage(UIImage(named: "ic-back"),
                              for: .normal)

        let searchBarButtonItem = UIBarButtonItem(customView: backButton)
        searchBarButtonItem.accessibilityIdentifier = "backBarButton"
        let currWidth = searchBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: searchButtonAspectRatio)
        currWidth?.isActive = true
        let currHeight = searchBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: searchButtonAspectRatio)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = searchBarButtonItem
    }
    
    @objc func backButtonTapped() {
        AlfrescoLog.debug("back button action")
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    private func createSearchController() -> UISearchController {
        let rvc = ResultViewController.instantiateViewController()
        rvc.pageController = searchPageController
        rvc.coordinatorServices = coordinatorServices
        rvc.resultScreenDelegate = self
        rvc.resultsViewModel = searchViewModel
        rvc.listItemActionDelegate = self.listItemActionDelegate
        resultsViewController = rvc

        let searchController = UISearchController(searchResultsController: resultsViewController)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.smartQuotesType = .no
        searchController.searchBar.isAccessibilityElement = true
        searchController.searchBar.accessibilityIdentifier = "searchBar"
        return searchController
    }
}

// MARK: - Result Screen Delegate

extension SystemSearchViewController: ResultViewControllerDelegate {
    func recentSearchTapped(string: String) {
        guard let searchBar = navigationItem.searchController?.searchBar,
            let searchViewModel = self.searchViewModel else { return }

        resultsViewController?.startLoading()
        searchBar.text = string

        searchViewModel.searchModel.searchString = string
        searchViewModel.searchModel.searchType = .simple

        resultsViewController?.pageController?.refreshList()
    }

    func elementListTapped(elementList: ListNode) {
        guard let searchBar = navigationItem.searchController?.searchBar else { return }
        resultsViewController?.recentSearchesViewModel.save(recentSearch: searchBar.text)
    }
}

// MARK: - UISearchController Delegate

extension SystemSearchViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        resultsViewController?.updateRecentSearches()
        resultsViewController?.clearDataSource()

        UIView.animate(withDuration: 0.2) {
            searchController.searchBar.alpha = 1.0
        }
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        if searchViewModel?.shouldDisplaySearchBar() == false {
            navigationItem.searchController = nil
            UIView.animate(withDuration: 0.1) { [weak self] in
                guard let sSelf = self else { return }
                sSelf.navigationController?.view.setNeedsLayout()
                sSelf.navigationController?.view.layoutIfNeeded()
            }
        }
        resultsViewController?.clearDataSource()
        searchViewModel?.searchModel.searchString = nil
    }
}

// MARK: - UISearchBar Delegate

extension SystemSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchViewModel = self.searchViewModel else { return }

        searchViewModel.searchModel.searchString = searchBar.text
        searchViewModel.searchModel.searchType = .simple

        resultsViewController?.pageController?.refreshList()
        resultsViewController?.recentSearchesViewModel.save(recentSearch: searchBar.text)
        resultsViewController?.startLoading()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultsViewController?.view.isHidden = false
        searchViewModel?.searchModel.searchString = nil
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchViewModel = self.searchViewModel else { return }
        if searchText.canPerformLiveSearch() {
            resultsViewController?.startLoading()

            searchViewModel.searchModel.searchString = searchText
            searchViewModel.searchModel.searchType = .live
            resultsViewController?.pageController?.refreshList()
            resultsViewController?.updateRecentSearches()
        } else {
            searchViewModel.searchModel.searchString = searchText
            resultsViewController?.stopLoading()
            resultsViewController?.clearDataSource()
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

// MARK: - Notifications

extension SystemSearchViewController {
    @objc private func handleUnauthorizedAPIAccess(notification: Notification) {
        let title = LocalizationConstants.Dialog.sessionExpiredTitle
        let message = LocalizationConstants.Dialog.sessionExpiredMessage
        
        let confirmAction = MDCAlertAction(title: LocalizationConstants.Buttons.signin) { [weak self] _ in
            guard let sSelf = self else { return }
            sSelf.coordinatorServices.accountService?.activeAccount?.reSignIn(onViewController: sSelf)
        }
        confirmAction.accessibilityIdentifier = "confirmActionButton"
        
        let cancelAction = MDCAlertAction(title: LocalizationConstants.General.cancel) { _ in
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
        cancelAction.accessibilityIdentifier = "cancelActionButton"

        _ = self.showDialog(title: title,
                                       message: message,
                                       actions: [confirmAction, cancelAction],
                                       completionHandler: {})
    }
}
