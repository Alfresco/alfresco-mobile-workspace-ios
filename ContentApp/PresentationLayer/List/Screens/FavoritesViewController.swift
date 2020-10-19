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
import MaterialComponents.MaterialTabs
import MaterialComponents.MaterialTabs_Theming
import MaterialComponents.MaterialTypographyScheme
import AlfrescoContent

class FavoritesViewController: SystemSearchViewController {
    var folderAndFilesViewController: ListComponentViewController?
    var librariesViewController: ListComponentViewController?

    var folderAndFilesListViewModel: ListViewModelProtocol?
    var librariesListViewModel: ListViewModelProtocol?

    lazy var scrollView: UIScrollView = setupScrollView()
    lazy var tabBar: MDCTabBar = setupTabBarView()

    weak var tabBarScreenDelegate: TabBarScreenDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        if folderAndFilesListViewModel?.shouldDisplaySettingsButton() ?? false {
            addSettingsButton(action: #selector(settingsButtonTapped), target: self)
        }

        view.addSubview(tabBar)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            tabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tabBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            tabBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            tabBar.heightAnchor.constraint(equalToConstant: 48),
            scrollView.topAnchor.constraint(equalTo: tabBar.bottomAnchor, constant: 0),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])

        setupScrollingContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        folderAndFilesViewController?.viewWillAppear(animated)
        librariesViewController?.viewWillAppear(animated)
        addAvatarInSettingsButton()

        // Force a layout update if necessary to handle the case where the user
        // is returning from a different orientation then the screen was originally on
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let selectedItem = tabBar.selectedItem {
                view.layoutIfNeeded()
                selectTabItem(item: selectedItem)
            }
        }
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        folderAndFilesViewController?.willTransition(to: newCollection, with: coordinator)
        librariesViewController?.willTransition(to: newCollection, with: coordinator)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        folderAndFilesViewController?.collectionView.collectionViewLayout.invalidateLayout()
        librariesViewController?.collectionView.collectionViewLayout.invalidateLayout()

        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            if let selectedItem = sSelf.tabBar.selectedItem {
                sSelf.selectTabItem(item: selectedItem)
            }
        }
    }

    // MARK: - IBActions

    @objc func settingsButtonTapped() {
        tabBarScreenDelegate?.showSettingsScreen()
    }

    // MARK: - Coordinator Public Methods

    func scrollToTop() {
        if tabBar.selectedItem?.tag == 0 {
            folderAndFilesViewController?.scrollToSection(0)
        } else if tabBar.selectedItem?.tag == 1 {
            librariesViewController?.scrollToSection(0)
        }
    }

    // MARK: - Private interface

    override func applyComponentsThemes() {
        super.applyComponentsThemes()

        guard let themingService = self.themingService, let currentTheme = self.themingService?.activeTheme else { return }
        tabBar.applySurfaceTheme(withScheme: themingService.containerScheming(for: .favoritesTabBar))
        tabBar.backgroundColor = currentTheme.backgroundColor
        tabBar.bottomDividerColor = currentTheme.dividerColor
        tabBar.enableRippleBehavior = true
        tabBar.rippleColor = currentTheme.backgroundColor
    }

    func setupTabBarView() -> MDCTabBar {
        let tabBar = MDCTabBar()
        tabBar.delegate = self

        tabBar.items = [UITabBarItem(title: LocalizationConstants.Search.filterFoldersAndFiles, image: nil, tag: 0),
                        UITabBarItem(title: LocalizationConstants.Search.filterLibraries, image: nil, tag: 1)]

        tabBar.itemAppearance = .titles
        tabBar.setAlignment(.justified, animated: false)
        tabBar.selectionIndicatorTemplate = FavoritesTabBarIndicator()
        tabBar.displaysUppercaseTitles = false
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
        // Set up the folders and files view
        let folderAndFilesViewController = ListComponentViewController.instantiateViewController()
        folderAndFilesViewController.listActionDelegate = self
        folderAndFilesViewController.listDataSource = folderAndFilesListViewModel
        folderAndFilesViewController.themingService = self.themingService
        folderAndFilesListViewModel?.pageUpdatingDelegate = folderAndFilesViewController

        self.folderAndFilesViewController = folderAndFilesViewController
        self.folderAndFilesViewController?.listItemActionDelegate = self.listItemActionDelegate

        // Set up the libraries view
        let librariesViewController = ListComponentViewController.instantiateViewController()
        librariesViewController.listActionDelegate = self
        librariesViewController.listDataSource = librariesListViewModel
        librariesViewController.themingService = self.themingService
        librariesListViewModel?.pageUpdatingDelegate = librariesViewController

        self.librariesViewController = librariesViewController
        self.librariesViewController?.listItemActionDelegate = self.listItemActionDelegate

        if let foldersAndFilesListView = folderAndFilesViewController.view, let librariesListView = librariesViewController.view {
            foldersAndFilesListView.translatesAutoresizingMaskIntoConstraints = false
            librariesListView.translatesAutoresizingMaskIntoConstraints = false

            scrollView.addSubview(foldersAndFilesListView)
            scrollView.addSubview(librariesListView)

            NSLayoutConstraint.activate([
                foldersAndFilesListView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 0),
                librariesListView.leadingAnchor.constraint(equalTo: foldersAndFilesListView.trailingAnchor, constant: 0),
                librariesListView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: 0)
            ])

            for subview in [foldersAndFilesListView, librariesListView] {
                NSLayoutConstraint.activate([
                    subview.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                    subview.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

                    subview.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
                    subview.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
                ])
            }
        }

        folderAndFilesViewController.startLoading()
        folderAndFilesListViewModel?.refreshList()
        librariesViewController.startLoading()
        librariesListViewModel?.refreshList()
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

extension FavoritesViewController: MDCTabBarDelegate {
    func tabBar(_ tabBar: MDCTabBar, didSelect item: UITabBarItem) {
        selectTabItem(item: item)
    }
}

// MARK: - UIScrollView Delegate

extension FavoritesViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
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

// MARK: - ListComponentActionDelegate

extension FavoritesViewController: ListComponentActionDelegate {
    func elementTapped(node: ListNode) {
    }

    func didUpdateList(error: Error?, pagination: Pagination?) {
        if tabBar.selectedItem?.tag == 0 {
            folderAndFilesViewController?.stopLoading()
        } else if tabBar.selectedItem?.tag == 1 {
            librariesViewController?.stopLoading()
        }
    }

    func fetchNextListPage(for itemAtIndexPath: IndexPath) {
        if tabBar.selectedItem?.tag == 0 {
            folderAndFilesListViewModel?.fetchNextListPage(index: itemAtIndexPath, userInfo: nil)
        } else if tabBar.selectedItem?.tag == 1 {
            librariesListViewModel?.fetchNextListPage(index: itemAtIndexPath, userInfo: nil)
        }
    }
}

class FavoritesTabBarIndicator: NSObject, MDCTabBarIndicatorTemplate {
    func indicatorAttributes(for context: MDCTabBarIndicatorContext) -> MDCTabBarIndicatorAttributes {
        let bounds = context.contentFrame
        let attr = MDCTabBarIndicatorAttributes()
        let overflow: CGFloat = 30
        let frame = CGRect(x: bounds.minX - overflow / 2, y: context.bounds.maxY - 2, width: bounds.width + overflow, height: 2)
        attr.path = UIBezierPath(rect: frame)
        return attr
    }
}
