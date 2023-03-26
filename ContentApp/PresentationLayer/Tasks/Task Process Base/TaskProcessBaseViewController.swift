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
import MaterialComponents.MaterialTabs_TabBarView
import MaterialComponents.MaterialTabs_TabBarViewTheming
import MaterialComponents.MaterialTypographyScheme
import AlfrescoContent

class TaskProcessBaseViewController: SystemSearchViewController {
    var taskListViewController: TasksListViewController?
    var workflowListViewController: WorkflowListViewController?
    lazy var scrollView: UIScrollView = setupScrollView()
    lazy var tabBar: MDCTabBarView = setupTabBarView()
    weak var tabBarScreenDelegate: TabBarScreenDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSettingsButton(action: #selector(settingsButtonTapped), target: self)
        
        view.addSubview(tabBar)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            tabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                        constant: 0),
            tabBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                            constant: 0),
            tabBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                             constant: 0),
            tabBar.heightAnchor.constraint(equalToConstant: 48),
            scrollView.topAnchor.constraint(equalTo: tabBar.bottomAnchor, constant: 0),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                 constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: 0)
        ])

        setupScrollingContent()
        tabBar.selectedItem = tabBar.items.first
        
        // ReSignIn Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleReSignIn(notification:)),
                                               name: Notification.Name(KeyConstants.Notification.reSignin),
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        addAvatarInSettingsButton()

        taskListViewController?.viewWillAppear(animated)
        workflowListViewController?.viewWillAppear(animated)

        // Force a layout update if necessary to handle the case where the user
        // is returning from a different orientation then the screen was originally on
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let selectedItem = tabBar.selectedItem {
                view.layoutIfNeeded()
                selectTabItem(item: selectedItem)
            }
        }
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        taskListViewController?.willTransition(to: newCollection, with: coordinator)
        workflowListViewController?.willTransition(to: newCollection, with: coordinator)
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        taskListViewController?.collectionView.collectionViewLayout.invalidateLayout()
        workflowListViewController?.collectionView.collectionViewLayout.invalidateLayout()

        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            if let selectedItem = sSelf.tabBar.selectedItem {
                sSelf.selectTabItem(item: selectedItem)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.isHidden = false
    }
    
    // MARK: - Public interface
    
    override func applyComponentsThemes() {
        super.applyComponentsThemes()

        guard let scheme = coordinatorServices?.themingService?.containerScheming(for: .favoritesTabBar),
              let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        tabBar.applySurfaceTheme(withScheme: scheme)
        tabBar.backgroundColor = currentTheme.surfaceColor
        tabBar.bottomDividerColor = currentTheme.onSurface15Color
        tabBar.rippleColor = .clear
    }
    
    // MARK: - IBActions
    
    @objc private func handleReSignIn(notification: Notification) {
        taskListViewController?.getTaskList()
        workflowListViewController?.getWorkflowsList()
    }
    
    @objc func settingsButtonTapped() {
        tabBarScreenDelegate?.showSettingsScreen()
    }
    
    // MARK: - Coordinator Public Methods

    func scrollToTop() {
        if tabBar.selectedItem?.tag == 0 {
            taskListViewController?.scrollToSection(0)
        } else if tabBar.selectedItem?.tag == 1 {
            workflowListViewController?.scrollToSection(0)
        }
    }
    
    func setupTabBarView() -> MDCTabBarView {
        let tabBar = MDCTabBarView()
        tabBar.tabBarDelegate = self
        let tasksTabBarItem =
            UITabBarItem(title: LocalizationConstants.ScreenTitles.tasks,
                         image: nil,
                         tag: 0)
        let workflowsTabBarItem =
            UITabBarItem(title: LocalizationConstants.ScreenTitles.workflows,
                         image: nil,
                         tag: 1)

        tasksTabBarItem.accessibilityIdentifier = "taskListTab"
        workflowsTabBarItem.accessibilityIdentifier = "workflowListTab"

        tabBar.items = [tasksTabBarItem, workflowsTabBarItem]
        tabBar.selectionIndicatorTemplate = FavoritesTabBarIndicator()
        tabBar.translatesAutoresizingMaskIntoConstraints = false

        return tabBar
    }
    
    func setupScrollView() -> UIScrollView {
        let scrollView = UIScrollView(frame: CGRect())
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = false
        scrollView.isScrollEnabled = true
        scrollView.delegate = self
        scrollView.decelerationRate = .fast

        return scrollView
    }

    func setupScrollingContent() {

        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if let taskListViewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.taskList) as? TasksListViewController {
            taskListViewController.title = LocalizationConstants.ScreenTitles.tasks
            
            taskListViewController.coordinatorServices = coordinatorServices
            taskListViewController.navigationViewController = self.navigationController
            self.taskListViewController = taskListViewController
        }
        
        if let workflowListViewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.workflowList) as? WorkflowListViewController {
            workflowListViewController.title = LocalizationConstants.ScreenTitles.workflows
            
            workflowListViewController.coordinatorServices = coordinatorServices
            workflowListViewController.navigationViewController = self.navigationController
            self.workflowListViewController = workflowListViewController
        }

        if let tasksListView = taskListViewController?.view,
           let workflowListView = workflowListViewController?.view {
            tasksListView.translatesAutoresizingMaskIntoConstraints = false
            workflowListView.translatesAutoresizingMaskIntoConstraints = false

            scrollView.addSubview(tasksListView)
            scrollView.addSubview(workflowListView)

            NSLayoutConstraint.activate([
                tasksListView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                                                                 constant: 0),
                workflowListView.leadingAnchor.constraint(equalTo: tasksListView.trailingAnchor,
                                                           constant: 0),
                workflowListView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor,
                                                            constant: 0)
            ])

            for subview in [tasksListView, workflowListView] {
                NSLayoutConstraint.activate([
                    subview.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                    subview.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

                    subview.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
                    subview.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
                ])
            }
        }
    }
    
    func selectTabItem(item: UITabBarItem) {
        guard let index = tabBar.items.firstIndex(of: item) else {
            fatalError("MDCTabBarDelegate given selected item not found in tabBar.items")
        }

        scrollView.setContentOffset(CGPoint(x: CGFloat(index) * scrollView.bounds.width, y: 0),
                                    animated: true)
    }
}

// MARK: - MDCTabBar Delegate

extension TaskProcessBaseViewController: MDCTabBarViewDelegate {
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        selectTabItem(item: item)
    }
}

// MARK: - UIScrollView Delegate

extension TaskProcessBaseViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let pageOffset = ScrollPageController().pageOffset(
            for: scrollView.contentOffset.x,
            velocity: velocity.x,
            in: pageOffsets(in: scrollView)
        ) {
            targetContentOffset.pointee.x = pageOffset

            let page = pageOffset / scrollView.bounds.width
            if 0...1 ~= page {
                let tabBarItem = tabBar.items[Int(page)]
                tabBar.setSelectedItem(tabBarItem, animated: true)
            }
        }
    }

    private func pageOffsets(in scrollView: UIScrollView) -> [CGFloat] {
        let pageWidth = scrollView.bounds.width
                        - scrollView.adjustedContentInset.left
                        - scrollView.adjustedContentInset.right
        let numberOfPages = Int(ceil(scrollView.contentSize.width / pageWidth))
        return (0..<numberOfPages).map { CGFloat($0) * pageWidth - scrollView.adjustedContentInset.left }
    }
}
