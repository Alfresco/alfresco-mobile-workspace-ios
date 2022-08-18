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
import GrowingTextView

class TaskCommentsViewController: SystemSearchViewController {
    @IBOutlet weak var progressView: MDCProgressView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var sendButton: MDCButton!
    @IBOutlet weak var textBaseView: UIView!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    var refreshControl: UIRefreshControl?
    var viewModel: TaskCommentsViewModel { return controller.viewModel }
    lazy var controller: TaskCommentsController = { return TaskCommentsController( currentTheme: coordinatorServices?.themingService?.activeTheme) }()
    
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.services = coordinatorServices ?? CoordinatorServices()
        progressView.progress = 0
        progressView.mode = .indeterminate
        applyLocalization()
        addRefreshControl()
        registerCells()
        addAccessibility()
        controller.buildViewModel()
        setupBindings()
        getTaskComments()
        AnalyticsManager.shared.pageViewEvent(for: Event.Page.taskCommentsScreen)
        scrollToBottom(animated: false)
        textView.delegate = self
        setDefaultStateForSendButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
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
        showKeyboard()
    }
    
    private func showKeyboard() {
        if viewModel.isShowKeyboard {
            textView.becomeFirstResponder()
        }
    }
    
    override func viewDidLayoutSubviews() {
        if viewModel.isAddComment {
            self.viewModel.isAddComment = false
            self.scrollToBottom(animated: true)
        } else {
            self.scrollToBottom(animated: false)
        }
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
    
    func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh),
                                 for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    private func applyLocalization() {
        self.title = LocalizationConstants.Tasks.commentsTitle
        commentsCountLabel.text = viewModel.commentsCount
        textView.placeholder = LocalizationConstants.Tasks.addCommentPlaceholder
    }
    
    func registerCells() {
        self.tableView.register(UINib(nibName: CellConstants.TableCells.commentCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.commentCell)
    }

    private func addAccessibility() {
        self.navigationItem.backBarButtonItem?.accessibilityLabel = LocalizationConstants.Accessibility.back
        self.navigationItem.backBarButtonItem?.accessibilityIdentifier = "back-button"
        progressView.isAccessibilityElement = false
        commentsCountLabel.accessibilityTraits = .updatesFrequently
        commentsCountLabel.accessibilityLabel = commentsCountLabel.text
        
        sendButton.accessibilityIdentifier = "send-button"
        textView.accessibilityTraits = .searchField
        textView.accessibilityIdentifier = "text-view"
        textView.accessibilityLabel = textView.placeholder
    }
    
    @objc private func handlePullToRefresh() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.getTaskComments()
        }
    }
    
    // MARK: - Public Helpers

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme,
        let bigButtonScheme = coordinatorServices?.themingService?.containerScheming(for: .loginBigButton) else { return }
        
        commentsCountLabel.applyStyleBody2OnSurface60(theme: currentTheme)
        bottomView.backgroundColor = currentTheme.surfaceColor
        refreshControl?.tintColor = currentTheme.primaryT1Color

        textBaseView.backgroundColor = currentTheme.surfaceColor
        textView.backgroundColor = currentTheme.surfaceColor
        textView.textColor = currentTheme.onSurface60Color
        textView.placeholderColor = currentTheme.onSurface60Color
        textView.font = currentTheme.subtitle2TextStyle.font
        divider.backgroundColor = currentTheme.onSurface12Color
        sendButton.backgroundColor = currentTheme.surfaceColor
    }
    
    func startLoading() {
        progressView?.startAnimating()
        progressView?.setHidden(false, animated: true)
    }

    func stopLoading() {
        progressView?.stopAnimating()
        progressView?.setHidden(true, animated: false)
        refreshControl?.endRefreshing()
    }
    
    @IBAction func sendButtonAction(_ sender: Any) {
        self.addComment(message: textView.text)
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
            sSelf.tableView.reloadData()
        }
        
        /* observing comments */
        viewModel.comments.addObserver() { [weak self] (comments) in
            guard let sSelf = self else { return }
            sSelf.applyLocalization()
            sSelf.tableView.reloadData()
        }
    }
    
    private func getTaskComments() {
        let taskID = viewModel.taskID
        viewModel.taskComments(with: taskID) { [weak self] comments, error in
            guard let sSelf = self else { return }
            if error == nil {
                sSelf.viewModel.comments.value = comments
                sSelf.controller.buildViewModel()
                sSelf.scrollToBottom(animated: true)
            }
        }
    }
    
    private func addComment(message: String?) {
        if viewModel.isAddCommentAllowed(for: message).isAllowed {
            viewModel.isAddComment = true
            self.textView.text = nil
            setDefaultStateForSendButton()
            
            let text = viewModel.isAddCommentAllowed(for: message).message
            let taskID = viewModel.taskID
            viewModel.addTaskComment(with: taskID, message: text) { [weak self] taskComment, error in
                guard let sSelf = self else { return }
                if error == nil {
                    sSelf.viewModel.comments.value.append(contentsOf: taskComment)
                    sSelf.controller.updateViewModel(for: taskComment)
                }
            }
        }
    }
    
    private func scrollToBottom(animated: Bool) {
        if !viewModel.rowViewModels.value.isEmpty {
            let indexPath = IndexPath(row: viewModel.rowViewModels.value.count - 1, section: 0)
            self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: animated)
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

// MARK: - KeyBoard
extension TaskCommentsViewController {
    
    @objc func keyboardWillShow(_ notification: Notification) {
        viewModel.keyboardShown = true
        let (height, duration, _) = UIFunction.getKeyboardAnimationOptions(notification: notification)
        viewModel.keyboardHeight = height ?? 0
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration ?? 0, delay: 0, options: .curveEaseOut, animations: {
                
                let yAxisFromBottom = (self.viewModel.keyboardHeight - self.view.safeAreaInsets.bottom) + 10.0
                self.bottomViewBottomConstraint.constant = yAxisFromBottom
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            self.viewModel.keyboardShown = true
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        viewModel.keyboardShown = false
        viewModel.keyboardHeight = 0
        
        let (_, duration, _) = UIFunction.getKeyboardAnimationOptions(notification: notification)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration ?? 0, delay: 0, options: .curveEaseOut, animations: {
                self.bottomViewBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
}

// MARK: - Text view delegate
extension TaskCommentsViewController: GrowingTextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if viewModel.isAddCommentAllowed(for: textView.text).isAllowed {
            sendButton.isUserInteractionEnabled = true
            sendButton.isSelected = true
        } else {
            setDefaultStateForSendButton()
        }
    }
    
    private func setDefaultStateForSendButton() {
        sendButton.isUserInteractionEnabled = false
        sendButton.isSelected = false
    }
}
