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
import AlfrescoContent
import MaterialComponents

class TaskDetailViewController: SystemSearchViewController {

    @IBOutlet weak var progressView: MDCProgressView!
    lazy var viewModel = TaskDetailViewModel(services: coordinatorServices ?? CoordinatorServices())
    var tableView: UITableView!
    var refreshControl: UIRefreshControl?

    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.progress = 0
        progressView.mode = .indeterminate
        addRefreshControl()
        applyLocalization()

        // ReSignIn Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleReSignIn(notification:)),
                                               name: Notification.Name(KeyConstants.Notification.reSignin),
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
      //  tableView.reloadData()
        updateTheme()
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
       // collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func addRefreshControl() {
        let refreshControl = UIRefreshControl()
     //   tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh),
                                 for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    // MARK: - Public interface
    
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        refreshControl?.tintColor = currentTheme.primaryT1Color
    }
    
    private func applyLocalization() {
        self.title = LocalizationConstants.Tasks.taskDetailTitle
        
        //viewModel.name
    }
    
    func registerCells() {
        
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
//        DispatchQueue.main.async { [weak self] in
//            guard let sSelf = self else { return }
//
//            sSelf.viewModel.shouldRefreshList = true
//            sSelf.viewModel.size = 0
//            sSelf.viewModel.total = 0
//            sSelf.viewModel.page = 0
//            sSelf.getTaskList()
//        }
    }
    
    @objc private func handleReSignIn(notification: Notification) {
        // getTaskList()
    }
}
