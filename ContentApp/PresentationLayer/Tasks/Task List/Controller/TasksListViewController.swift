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
    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListTitle: UILabel!
    @IBOutlet weak var emptyListSubtitle: UILabel!
    @IBOutlet weak var emptyListImageView: UIImageView!
    @IBOutlet weak var collectionView: PageFetchableCollectionView!
    @IBOutlet weak var progressView: MDCProgressView!
    var refreshControl: UIRefreshControl?
    lazy var viewModel = TasksListViewModel(services: coordinatorServices ?? CoordinatorServices())
    let regularCellHeight: CGFloat = 60.0
    let sectionCellHeight: CGFloat = 54.0
    var sortFilterView: TasksSortAndFilterView?
    
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up progress view
        emptyListView.isHidden = true
        progressView.progress = 0
        progressView.mode = .indeterminate
        addSettingsButton(action: #selector(settingsButtonTapped), target: self)
        searchController = createSearchController()
        navigationItem.searchController = searchController
        addRefreshControl()
        setupBindings()
        registerCells()
        addSortAndFilterView()
        
        // ReSignIn Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleReSignIn(notification:)),
                                               name: Notification.Name(KeyConstants.Notification.reSignin),
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAvatarInSettingsButton()
        collectionView.reloadData()
        AnalyticsManager.shared.pageViewEvent(for: Event.Page.taskTab)
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
    
    func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        collectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh),
                                 for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    // MARK: - Public interface
    
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        emptyListView.backgroundColor = currentTheme.surfaceColor
        emptyListTitle.applyeStyleHeadline6OnSurface(theme: currentTheme)
        emptyListTitle.textAlignment = .center
        emptyListSubtitle.applyStyleBody2OnSurface60(theme: currentTheme)
        emptyListSubtitle.textAlignment = .center
        refreshControl?.tintColor = currentTheme.primaryT1Color
        self.sortFilterView?.applyTheme(currentTheme)
    }
    
    // MARK: - Get Tasks List
    func getTaskList() {
        let state = self.viewModel.filter?.state ?? ""
        let params = TaskListParams(page: viewModel.page, state: state)
        viewModel.taskList(with: params) {[weak self] taskList, error in
            guard let sSelf = self else { return }
            if error == nil {
                sSelf.collectionView.reloadData()
                sSelf.checkEmptyTaskListMessage()
            } else {
                sSelf.showTaskListNotConfiguredMessage()
            }
        }
    }
    
    func checkEmptyTaskListMessage() {
        let isListEmpty = viewModel.isEmpty()
        emptyListView.isHidden = !isListEmpty
        if isListEmpty {
            let emptyList = viewModel.emptyList()
            emptyListImageView.image = emptyList.icon
            emptyListTitle.text = emptyList.title
            emptyListSubtitle.text = emptyList.description
        }
    }
    
    func showTaskListNotConfiguredMessage() {
        emptyListView.isHidden = false
        let emptyList = viewModel.tasksNotConfigured()
        emptyListImageView.image = emptyList.icon
        emptyListTitle.text = emptyList.title
        emptyListSubtitle.text = emptyList.description
    }
    
    // MARK: - Set up Bindings
    private func setupBindings() {
        self.viewModel.isLoading.addObserver { [weak self] (isLoading) in
            if isLoading {
                self?.startLoading()
            } else {
                self?.stopLoading()
            }
        }
    }
    
    func registerCells() {
        collectionView.register(UINib(nibName: CellConstants.CollectionCells.taskList, bundle: nil), forCellWithReuseIdentifier: CellConstants.CollectionCells.taskList)
        collectionView.register(UINib(nibName: CellConstants.CollectionCells.taskSection, bundle: nil), forCellWithReuseIdentifier: CellConstants.CollectionCells.taskSection)
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
        let indexPath = IndexPath(item: 0, section: 0)
        var pointToScroll = CGPoint.zero
        if collectionView.cellForItem(at: indexPath) != nil {
            if let attributes =
                collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader,
                                                                       at: indexPath) {
                pointToScroll =
                    CGPoint(x: 0, y: attributes.frame.origin.y - collectionView.contentInset.top)
            }
        }
        collectionView.setContentOffset(pointToScroll, animated: true)
    }
    
    private func createSearchController() -> UISearchController {
        
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        let rvc = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.searchTasks) as? SearchTasksViewController
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
        refreshControl?.endRefreshing()
    }
    
    @objc private func handlePullToRefresh() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            
            sSelf.viewModel.shouldRefreshList = true
            sSelf.viewModel.size = 0
            sSelf.viewModel.total = 0
            sSelf.viewModel.page = 0
            sSelf.getTaskList()
        }
    }
    
    @objc private func handleReSignIn(notification: Notification) {
        getTaskList()
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

            let isPaginationEnabled = true
            if isPaginationEnabled &&
                collectionView.lastItemIndexPath() == indexPath &&
                viewModel.services.connectivityService?.hasInternetConnection() == true {
                getTaskList()
            }
            return cell
        }
    }
}

// MARK: - Sort and Filter View Delegate
extension TasksListViewController: TasksSortAndFilterDelegate {
    func addSortAndFilterView() {
        if let sortFilterView: TasksSortAndFilterView = .fromNib() {
            sortFilterView.frame = CGRect(x: 10, y: topBarHeight+55.0, width: self.view.frame.size.width - 20.0, height: 103.0)
            sortFilterView.deleagte = self
            sortFilterView.setFilterDetails()
            self.view.addSubview(sortFilterView)
            self.sortFilterView = sortFilterView
        }
    }
    
    func didSelectTaskFilter(_ filter: TasksFilters) {
        self.viewModel.filter = filter
        self.viewModel.rawTasks.removeAll()
        getTaskList()
    }
}

