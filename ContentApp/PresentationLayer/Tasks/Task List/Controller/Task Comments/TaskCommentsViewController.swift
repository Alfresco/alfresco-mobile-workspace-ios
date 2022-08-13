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

class TaskCommentsViewController: SystemSearchViewController {
    @IBOutlet weak var progressView: MDCProgressView!
    @IBOutlet weak var tableView: UITableView!
    var viewModel: TaskCommentsViewModel { return controller.viewModel }
    lazy var controller: TaskCommentsController = { return TaskCommentsController( currentTheme: coordinatorServices?.themingService?.activeTheme) }()
    
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.services = coordinatorServices ?? CoordinatorServices()
        progressView.progress = 0
        progressView.mode = .indeterminate
        applyLocalization()
        registerCells()
        addAccessibility()
        controller.buildViewModel()
        setupBindings()
        getTaskComments()
        AnalyticsManager.shared.pageViewEvent(for: Event.Page.taskCommentsScreen)
        tableView.contentInset.bottom = 50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        updateTheme()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Snackbar.dimissAll()
        self.tabBarController?.tabBar.isHidden = false
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
    }
    
    private func applyLocalization() {
        self.title = LocalizationConstants.Tasks.commentsTitle
    }
    
    func registerCells() {
        self.tableView.register(UINib(nibName: CellConstants.TableCells.commentCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.commentCell)
    }

    private func addAccessibility() {
        self.navigationItem.backBarButtonItem?.accessibilityLabel = LocalizationConstants.Accessibility.back
        self.navigationItem.backBarButtonItem?.accessibilityIdentifier = "back-button"
        progressView.isAccessibilityElement = false
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
    
    // MARK: - Set up Bindings
    private func setupBindings() {
        
        /* observer loader */
        viewModel.isLoading.addObserver { [weak self] (isLoading) in
            guard let sSelf = self else { return }
            if isLoading {
                sSelf.startLoading()
            } else {
                sSelf.stopLoading()
            }
        }
        
        /* observing rows */
        viewModel.rowViewModels.addObserver() { [weak self] (rows) in
            guard let sSelf = self else { return }
            DispatchQueue.main.async {
                sSelf.tableView.reloadData()
            }
        }
        
        /* observing comments */
        viewModel.comments.addObserver() { [weak self] (comments) in
            guard let sSelf = self else { return }
            DispatchQueue.main.async {
                sSelf.tableView.reloadData()
            }
        }
    }
    
    private func getTaskComments() {
        let taskID = viewModel.taskID
        viewModel.taskComments(with: taskID) { [weak self] comments, error in
            guard let sSelf = self else { return }
            if error == nil {
                sSelf.viewModel.comments.value = comments
                sSelf.controller.buildViewModel()
            }
        }
    }
}

// MARK: - Table View Data Source and Delegates
extension TaskCommentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.rowViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowViewModel = viewModel.rowViewModels.value[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: controller.cellIdentifier(for: rowViewModel), for: indexPath)
        if let cell = cell as? CellConfigurable {
            cell.setup(viewModel: rowViewModel)
        }
        
        if let theme = coordinatorServices?.themingService {
            if cell is TaskCommentTableViewCell {
                (cell as? TaskCommentTableViewCell)?.applyTheme(with: theme)
            }
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
