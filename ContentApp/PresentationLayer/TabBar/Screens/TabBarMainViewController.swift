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
import MaterialComponents

protocol TabBarScreenDelegate: class {
    func showSettingsScreen()
}

class TabBarMainViewController: UITabBarController {
    let bottomNavigationBar = MDCBottomNavigationBar()
    var tabs = [UITabBarItem]()

    var themingService: MaterialDesignThemingService?
    weak var tabBarCoordinatorDelegate: TabBarScreenCoordinatorDelegate?

    private var observation: NSKeyValueObservation?
    private let itemsContentVerticalMargin: CGFloat = 5.0

    // MARK: - View Life Cycle

    deinit {
        observation?.invalidate()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        observation =  observe(\.tabBar.isHidden, options: [.old, .new]) { [weak self] _, change in
            guard let sSelf = self else { return }
            sSelf.bottomNavigationBar.isHidden = change.newValue ?? false
            sSelf.addMaterialComponentsTheme()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        tabBarCoordinatorDelegate?.showRecentScreen()
        tabBarCoordinatorDelegate?.showFavoritesScreen()
        addLocalization()
        addBottomNavigationBar()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutBottomNavBar()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        layoutBottomNavBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        addMaterialComponentsTheme()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        themingService?.activateUserSelectedTheme()
        addMaterialComponentsTheme()
    }

    // MARK: - Helpers

    func addLocalization() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    func addMaterialComponentsTheme() {
        guard let themingService = self.themingService, let currentTheme = self.themingService?.activeTheme else { return }

        bottomNavigationBar.applyPrimaryTheme(withScheme: themingService.containerScheming(for: .applicationTabBar))
        bottomNavigationBar.selectedItemTintColor = currentTheme.onSurfaceColor
        bottomNavigationBar.unselectedItemTintColor = currentTheme.onSurfaceColor.withAlphaComponent(0.6)
        bottomNavigationBar.itemsContentVerticalMargin = self.itemsContentVerticalMargin
        navigationController?.navigationBar.tintColor = currentTheme.primaryVariantColor
    }

    func addBottomNavigationBar() {
        view.addSubview(bottomNavigationBar)
        bottomNavigationBar.titleVisibility = .always
        bottomNavigationBar.alignment = .centered
        bottomNavigationBar.items = tabs

        bottomNavigationBar.selectedItem = tabs.first
        bottomNavigationBar.delegate = self
    }

    func layoutBottomNavBar() {
        let size = bottomNavigationBar.sizeThatFits(view.bounds.size)
        var bottomNavigationBarFrame = CGRect( x: 0,
                                               y: view.bounds.height - size.height,
                                               width: size.width,
                                               height: size.height )
        bottomNavigationBarFrame.size.height += view.safeAreaInsets.bottom
        bottomNavigationBarFrame.origin.y -= view.safeAreaInsets.bottom
        bottomNavigationBar.frame = bottomNavigationBarFrame
    }

    func doubleTapLogic(for item: Int) {
        guard self.selectedIndex == item else { return }
        self.tabBarCoordinatorDelegate?.scrollToTop(forScreen: item)
    }
}

// MARK: - MDCBottomNavigationBarDelegate

extension TabBarMainViewController: MDCBottomNavigationBarDelegate {
    func bottomNavigationBar(_ bottomNavigationBar: MDCBottomNavigationBar, shouldSelect item: UITabBarItem) -> Bool {
        doubleTapLogic(for: item.tag)
        self.selectedIndex = item.tag
        return true
    }
}

// MARK: - UITabBarControllerDelegate

extension TabBarMainViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TopLevelTransition(viewControllers: tabBarController.viewControllers)
    }
}

// MARK: - TabBarScreen Delegate

extension TabBarMainViewController: TabBarScreenDelegate {
    func showSettingsScreen() {
        tabBarCoordinatorDelegate?.showSettingsScreen()
    }
}

// MARK: - Storyboard Instantiable

extension TabBarMainViewController: StoryboardInstantiable { }
