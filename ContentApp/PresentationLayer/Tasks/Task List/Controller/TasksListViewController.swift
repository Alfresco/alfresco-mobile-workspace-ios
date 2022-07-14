//
// Copyright (C) 2005-2022 Alfresco Software Limited.
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
import MaterialComponents
import AlfrescoContent

class TasksListViewController: SystemSearchViewController {

    weak var tabBarScreenDelegate: TabBarScreenDelegate?
    private var searchController: UISearchController?
    private let searchButtonAspectRatio: CGFloat = 30.0
    @IBOutlet weak var collectionView: PageFetchableCollectionView!
    @IBOutlet weak var progressView: MDCProgressView!
    lazy var viewModel = TasksListViewModel(services: coordinatorServices ?? CoordinatorServices())
    let regularCellHeight: CGFloat = 60.0
    let sectionCellHeight: CGFloat = 54.0
    
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up progress view
        progressView.progress = 0
        progressView.mode = .indeterminate
        
        addSettingsButton(action: #selector(settingsButtonTapped), target: self)
        searchController = createSearchController()
        navigationItem.searchController = searchController
        setupBindings()
        registerCells()
        getTaskList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAvatarInSettingsButton()
        collectionView.reloadData()
        AnalyticsManager.shared.pageViewEvent(for: self.title)
        updateTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.isHidden = false
    }
    
    func updateTheme() {
        let activeTheme = coordinatorServices?.themingService?.activeTheme
        progressView.progressTintColor = activeTheme?.primaryT1Color
        progressView.trackTintColor = activeTheme?.primary30T1Color
    }
    
    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
        updateTheme()
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Get Tasks List
    func getTaskList() {
        let params = TaskListParams(page: viewModel.page)
        viewModel.taskList(with: params) { taskList, error in
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Set up Bindings
    private func setupBindings() {
        
        // observing loader
        self.viewModel.isLoading.addObserver { [weak self] (isLoading) in
            if isLoading {
                self?.startLoading()
            } else {
                self?.stopLoading()
            }
        }
    }
    
    func registerCells() {
        collectionView.register(UINib(nibName: "TaskListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TaskListCollectionViewCell")
        collectionView.register(UINib(nibName: "TaskSectionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TaskSectionCollectionViewCell")
        collectionView.register(ActivityIndicatorFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: String(describing: ActivityIndicatorFooterView.self))
    }
    
    // MARK: - IBActions

    @objc func settingsButtonTapped() {
        tabBarScreenDelegate?.showSettingsScreen()
    }
    
    // MARK: - Coordinator Public Methods

    func scrollToTop() {
        // listController?.scrollToSection(0)
    }
    
    private func createSearchController() -> UISearchController {
        
        let storyboard = UIStoryboard(name: "Tasks", bundle: nil)
        let rvc = storyboard.instantiateViewController(withIdentifier: "SearchTasksViewController") as? SearchTasksViewController
        rvc?.coordinatorServices = coordinatorServices
        tasksResultsViewController = rvc

        let searchController = UISearchController(searchResultsController: tasksResultsViewController)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.smartQuotesType = .no
        searchController.searchBar.isAccessibilityElement = true
        searchController.searchBar.accessibilityIdentifier = "searchBar"
        searchController.showsSearchResultsController = true
        return searchController
    }
    
    // MARK: - Public Helpers

    func startLoading() {
        progressView?.startAnimating()
        progressView?.setHidden(false, animated: true)
    }

    func stopLoading() {
        progressView?.stopAnimating()
        progressView?.setHidden(true, animated: false)
    }
}

// MARK: - Collection view data source and delegate
extension TasksListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: regularCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        let shouldDisplayListLoadingIndicator = viewModel.shouldDisplaTaskListLoadingIndicator()
        if shouldDisplayListLoadingIndicator && viewModel.services.connectivityService?.hasInternetConnection() == true {
            return CGSize(width: collectionView.bounds.width,
                          height: regularCellHeight)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let footerView =
                collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                withReuseIdentifier: String(describing: ActivityIndicatorFooterView.self),
                                                                for: indexPath)
            
            return footerView
            
        default:
            assert(false, "Unexpected element kind")
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifierSection = String(describing: TaskSectionCollectionViewCell.self)
        let identifierElement = String(describing: TaskListCollectionViewCell.self)

        let node = viewModel.listNode(for: indexPath)
        if node?.guid == listNodeSectionIdentifier {
            guard let cell = collectionView
                    .dequeueReusableCell(withReuseIdentifier: identifierSection,
                                         for: indexPath) as? TaskSectionCollectionViewCell else { return UICollectionViewCell() }
            cell.applyTheme(viewModel.services.themingService?.activeTheme)
            cell.titleLabel.text = viewModel.titleForSectionHeader(at: indexPath)
            return cell
        } else {
            guard let cell = collectionView
                    .dequeueReusableCell(withReuseIdentifier: identifierElement,
                                         for: indexPath) as? TaskListCollectionViewCell else { return UICollectionViewCell() }
            cell.applyTheme(viewModel.services.themingService?.activeTheme)
            cell.setupData(for: node)

//            let isPaginationEnabled = true
//            if isPaginationEnabled &&
//                collectionView.lastItemIndexPath() == indexPath &&
//                viewModel.services.connectivityService?.hasInternetConnection() == true {
//                if let collectionView = collectionView as? PageFetchableCollectionView {
//                    getTaskList()
//                }
//            }
            return cell
        }
    }
}
