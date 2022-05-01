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

class FilesandFolderListViewController: SystemThemableViewController {
    private let searchButtonAspectRatio: CGFloat = 30.0
    lazy var viewModel = FilesandFolderListViewModel()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        
        let searchBarButtonItem = createSearchBarButton()
        self.navigationItem.rightBarButtonItems = [searchBarButtonItem]
        addBackButton()
        addLocalization()
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
    
    private func createSearchBarButton() -> UIBarButtonItem {
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
        return searchBarButtonItem
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
    
    // MARK: - Back Button
    @objc func backButtonTapped() {
//        if self.isChildFolder {
//            self.navigationController?.popViewController(animated: true)
//        } else {
//            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
//        }
    }
    
    // MARK: - IBActions

    @objc func searchButtonTapped() {
//        navigationItem.searchController = searchController
//        searchController?.searchBar.alpha = 0.0
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
//            guard let sSelf = self else { return }
//            sSelf.searchController?.isActive = true
//            sSelf.searchController?.searchBar.becomeFirstResponder()
//        }
    }
    
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
            
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
    
    func addLocalization() {
        self.title = viewModel.title
    }
}

// MARK: - Storyboard Instantiable

extension FilesandFolderListViewController: StoryboardInstantiable {}
