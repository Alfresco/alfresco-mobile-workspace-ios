//
// Copyright (C) 2005-2023 Alfresco Software Limited.
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
import DropDown

class WorkflowListViewController: SystemSearchViewController {
    
    var navigationViewController: UINavigationController?
    @IBOutlet weak var filtersView: UIView!
    @IBOutlet weak var filtersLabel: UILabel!
    @IBOutlet weak var filtersButton: UIButton!
    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListTitle: UILabel!
    @IBOutlet weak var emptyListSubtitle: UILabel!
    @IBOutlet weak var emptyListImageView: UIImageView!
    @IBOutlet weak var collectionView: PageFetchableCollectionView!
    @IBOutlet weak var progressView: MDCProgressView!
    @IBOutlet weak var startWorkflowButton: MDCFloatingButton!
    var refreshControl: UIRefreshControl?
    lazy var viewModel = WorkflowListViewModel(services: coordinatorServices ?? CoordinatorServices())
    let regularCellHeight: CGFloat = 70.0
    let sectionCellHeight: CGFloat = 54.0
    private var dialogTransitionController: MDCDialogTransitionController?
    lazy var dropDown = DropDown()

    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
                
        filtersView.isHidden = true
        startWorkflowButton.isHidden = true
        emptyListView.isHidden = true
        progressView.progress = 0
        progressView.mode = .indeterminate
        addRefreshControl()
        setupBindings()
        registerCells()
        getWorkflowsList()
        self.dialogTransitionController = MDCDialogTransitionController()
        setupDropDownView()
        setSelectedFilterName()
        addAccessibility()
        addNotifications()
    }
    
    private func addNotifications() {        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.refreshWorkflowList(notification:)),
                                               name: Notification.Name(KeyConstants.Notification.refreshWorkflows),
                                               object: nil)
    }
   
    @objc private func refreshWorkflowList(notification: Notification) {
        handlePullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        AnalyticsManager.shared.pageViewEvent(for: Event.Page.workflowTab)
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
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
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
        startWorkflowButton.backgroundColor = currentTheme.primaryT1Color
        startWorkflowButton.tintColor = currentTheme.onPrimaryColor
        
        filtersLabel.applyStyleSubtitle2OnSurface(theme: currentTheme)
        dropDown.backgroundColor = currentTheme.surfaceColor
        dropDown.selectionBackgroundColor = currentTheme.primary15T1Color
        dropDown.textColor = currentTheme.onSurfaceColor
        dropDown.selectedTextColor = currentTheme.onSurfaceColor
    }
    
    private func addAccessibility() {
        filtersButton.accessibilityLabel = LocalizationConstants.Workflows.filterOptions
        filtersButton.accessibilityValue = filtersLabel.text
        filtersButton.accessibilityIdentifier = "filter-button"
        
        startWorkflowButton.accessibilityLabel = LocalizationConstants.Accessibility.startWorkflow
        startWorkflowButton.accessibilityIdentifier = "start-workflow-button"
    }
    
    // MARK: - IBActions

    @IBAction func filtersButtonAction(_ sender: Any) {
        dropDown.show()
    }
    
    // MARK: - Get Workflows List
    @objc func getWorkflowsList() {
        
        viewModel.workflowList {[weak self] workflows, error in
            guard let sSelf = self else { return }
            if error == nil {
                sSelf.viewModel.isTasksConfigured = true
                sSelf.collectionView.reloadData()
                sSelf.checkEmptyTaskListMessage()
                sSelf.filtersView.isHidden = false
                sSelf.startWorkflowButton.isHidden = false
            } else {
                sSelf.viewModel.isTasksConfigured = false
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
        filtersView.isHidden = true
        startWorkflowButton.isHidden = true
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
    
    // MARK: - Coordinator Public Methods
    
    func scrollToSection(_ section: Int) {
        let indexPath = IndexPath(item: 0, section: section)
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
            sSelf.getWorkflowsList()
        }
    }
}

// MARK: - Collection view data source and delegate
extension WorkflowListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
        if node?.processID == listNodeSectionIdentifier {
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
            cell.setupWorkflowData(for: node)

            let isPaginationEnabled = true
            if isPaginationEnabled &&
                collectionView.lastItemIndexPath() == indexPath &&
                viewModel.services.connectivityService?.hasInternetConnection() == true {
                getWorkflowsList()
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let node = viewModel.listNode(for: indexPath)
        startWorkflowAction(appDefinition: nil, node: nil, workflowNode: node, isDetailFlow: true)
    }
}

// MARK: - Drop Down
extension WorkflowListViewController {
    func setupDropDownView() {
        dropDown.anchorView = filtersView
        dropDown.bottomOffset = CGPoint(x: 0, y: (dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.cornerRadius = 6
        dropDown.width = 200
        buildDropDownDataSource()
    }
    
    func buildDropDownDataSource() {
        let filters = viewModel.localizedFilterNames
        dropDown.localizationKeysDataSource = filters
        dropDown.reloadAllComponents()
        dropDown.selectionAction = { (index: Int, item: String) in
            self.viewModel.selectedFilter = self.viewModel.filters[index]
            self.handlePullToRefresh()
            self.setSelectedFilterName()
        }
    }
    
    private func setSelectedFilterName() {
        filtersLabel.text = viewModel.selectedFilter.localizedName
    }
}

// MARK: - Workflow
extension WorkflowListViewController {
    
    @IBAction func startWorkflowButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.startableWorkflowList) as? StartableWorkflowsViewController {
            let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
            viewController.coordinatorServices = coordinatorServices
            self.present(bottomSheet, animated: true)
            viewController.didSelectAction = { [weak self] (appDefinition) in
                guard let sSelf = self else { return }
                sSelf.startWorkflowAction(appDefinition: appDefinition, node: nil, workflowNode: nil)
            }
        }
    }
        
    private func startWorkflowAction(appDefinition: WFlowAppDefinitions?, node: ListNode?, workflowNode: WorkflowNode?, isDetailFlow: Bool = false) {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if isDetailFlow {
            if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.startWorkflowPage) as? StartWorkflowViewController {
                viewController.coordinatorServices = coordinatorServices
                viewController.viewModel.isEditMode = false
                viewController.viewModel.workflowDetailNode = workflowNode
                viewController.viewModel.isDetailWorkflow = isDetailFlow
                self.navigationViewController?.pushViewController(viewController, animated: true)
                viewController.viewModel.didRefreshTaskList = {[weak self] in
                    guard let sSelf = self else { return }
                    sSelf.handlePullToRefresh()
                }
            }
        } else {
            if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.complexWorkflowPage) as? ComplexFormViewController {
                viewController.coordinatorServices = coordinatorServices
                viewController.viewModel.appDefinition = appDefinition
                viewController.viewModel.isEditMode = true
                viewController.viewModel.selectedAttachments = []
                viewController.viewModel.tempWorkflowId = UIFunction.currentTimeInMilliSeconds()
                viewController.viewModel.isDetailWorkflow = isDetailFlow
                self.navigationViewController?.pushViewController(viewController, animated: true)
                viewController.viewModel.didRefreshTaskList = {[weak self] in
                    guard let sSelf = self else { return }
                    sSelf.handlePullToRefresh()
                }
            }
        }
    }
}
