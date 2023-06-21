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
import AlfrescoContent
import MaterialComponents

class WflowTaskDetailViewController: SystemSearchViewController {
    
    @IBOutlet weak var progressView: MDCProgressView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonsBaseView: UIView!
    @IBOutlet weak var outputButtonOptionOne: MDCButton!
    @IBOutlet weak var outputButtonOptionTwo: MDCButton!
    @IBOutlet weak var heightOutputView: NSLayoutConstraint!
    @IBOutlet weak var claimTaskView: UIView!
    @IBOutlet weak var claimTaskButton: MDCButton!
    var releaseTaskButton = UIButton(type: .custom)
    var viewModel: WflowTaskDetailViewModel { return controller.viewModel }
    lazy var controller: WflowTaskDetailController = { return WflowTaskDetailController( currentTheme: coordinatorServices?.themingService?.activeTheme) }()
    let refreshGroup = DispatchGroup()

    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.services = coordinatorServices ?? CoordinatorServices()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationItem.setHidesBackButton(true, animated: true)
        hideAllButtons()
        progressView.isAccessibilityElement = false
        progressView.progress = 0
        progressView.mode = .indeterminate
        applyLocalization()
        registerCells()
        addBackButton()
        addAccessibility()
        setupBindings()
        getWorkflowTaskVariables()
        addReleaseTaskButton()
        AnalyticsManager.shared.pageViewEvent(for: Event.Page.workflowTaskDetailScreen)
        
        // ReSignIn Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleReSignIn(notification:)),
                                               name: Notification.Name(KeyConstants.Notification.reSignin),
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
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
    }
    
    private func applyLocalization() {
        self.title = LocalizationConstants.Tasks.taskDetailTitle
        
        let titleOne = NSLocalizedString(viewModel.outcomeTitleOne ?? "", comment: "")
        let titleTwo = NSLocalizedString(viewModel.outcomeTitleTwo ?? "", comment: "")
        outputButtonOptionOne.setTitle(titleOne, for: .normal)
        outputButtonOptionTwo.setTitle(titleTwo, for: .normal)
        claimTaskButton.setTitle(LocalizationConstants.Workflows.claimTitle, for: .normal)
    }
    
    func registerCells() {
        self.tableView.register(UINib(nibName: CellConstants.TableCells.titleCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.titleCell)
        self.tableView.register(UINib(nibName: CellConstants.TableCells.infoCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.infoCell)
        self.tableView.register(UINib(nibName: CellConstants.TableCells.priorityCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.priorityCell)
        self.tableView.register(UINib(nibName: CellConstants.TableCells.taskHeaderCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.taskHeaderCell)
        self.tableView.register(UINib(nibName: CellConstants.TableCells.emptyPlaceholderCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.emptyPlaceholderCell)
        self.tableView.register(UINib(nibName: CellConstants.TableCells.taskAttachment, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.taskAttachment)
        self.tableView.register(UINib(nibName: CellConstants.TableCells.spaceCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.spaceCell)
    }
    
    private func addAccessibility() {
        progressView.isAccessibilityElement = false
    }
    
    // MARK: - Public Helpers
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme,
              let buttonScheme = coordinatorServices?.themingService?.containerScheming(for: .dialogButton) else { return }
        
        view.backgroundColor = currentTheme.surfaceColor
        buttonsBaseView.backgroundColor = currentTheme.surfaceColor
        claimTaskView.backgroundColor = currentTheme.surfaceColor
        
        outputButtonOptionOne.applyContainedTheme(withScheme: buttonScheme)
        outputButtonOptionOne.isUppercaseTitle = false
        outputButtonOptionOne.setShadowColor(.clear, for: .normal)
        outputButtonOptionOne.layer.cornerRadius = UIConstants.cornerRadiusDialog

        outputButtonOptionTwo.applyContainedTheme(withScheme: buttonScheme)
        outputButtonOptionTwo.setBackgroundColor(currentTheme.onSurface5Color, for: .normal)
        outputButtonOptionTwo.isUppercaseTitle = false
        outputButtonOptionTwo.setShadowColor(.clear, for: .normal)
        outputButtonOptionTwo.setTitleColor(currentTheme.onSurfaceColor, for: .normal)
        outputButtonOptionTwo.layer.cornerRadius = UIConstants.cornerRadiusDialog
        
        releaseTaskButton.setTitleColor(currentTheme.primaryT1Color, for: .normal)
        releaseTaskButton.titleLabel?.font = currentTheme.buttonTextStyle.font
        
        claimTaskButton.applyContainedTheme(withScheme: buttonScheme)
        claimTaskButton.isUppercaseTitle = false
        claimTaskButton.setShadowColor(.clear, for: .normal)
        claimTaskButton.layer.cornerRadius = UIConstants.cornerRadiusDialog
    }
    
    func startLoading() {
        progressView?.startAnimating()
        progressView?.setHidden(false, animated: true)
    }

    func stopLoading() {
        progressView?.stopAnimating()
        progressView?.setHidden(true, animated: false)
    }

    @objc private func handleReSignIn(notification: Notification) {
        getWorkflowTaskDetails()
    }
    
    private func addBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.accessibilityIdentifier = "backButton"
        backButton.accessibilityLabel = LocalizationConstants.Accessibility.back
        backButton.frame = CGRect(x: 0.0, y: 0.0,
                                  width: 30.0,
                                    height: 30.0)
        backButton.imageView?.contentMode = .scaleAspectFill
        backButton.layer.masksToBounds = true
        backButton.addTarget(self,
                               action: #selector(backButtonAction),
                               for: UIControl.Event.touchUpInside)
        backButton.setImage(UIImage(named: "ic-back"),
                              for: .normal)

        let searchBarButtonItem = UIBarButtonItem(customView: backButton)
        searchBarButtonItem.accessibilityIdentifier = "backBarButton"
        let currWidth = searchBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: 30.0)
        currWidth?.isActive = true
        let currHeight = searchBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: 30.0)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = searchBarButtonItem
    }
    
    // MARK: - Back Button Action
    @objc func backButtonAction() {
        self.backAndRefreshAction(isRefreshList: false)
    }
    
    private func backAndRefreshAction(isRefreshList: Bool) {
        if isRefreshList {
            self.viewModel.didRefreshWorkflowList?()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Button Actions
    @IBAction func outputButtonOneAction(_ sender: Any) {
        if viewModel.isValidationPassed() {
            viewModel.selectedOutcome = viewModel.outcomeTitleOne
            callAPIToApproveRejectTask()
        } else {
            Snackbar.display(with: LocalizationConstants.Workflows.selectStatusMessage, type: .error, finish: nil)
        }
    }
    
    @IBAction func outputButtonTwoAction(_ sender: Any) {
        if viewModel.isValidationPassed() {
            viewModel.selectedOutcome = viewModel.outcomeTitleTwo
            callAPIToApproveRejectTask()
        } else {
            Snackbar.display(with: LocalizationConstants.Workflows.selectStatusMessage, type: .error, finish: nil)
        }
    }
    
    private func callAPIToApproveRejectTask() {
        viewModel.approveRejectTask { error in
            if error == nil {
                self.backAndRefreshAction(isRefreshList: true)
            }
        }
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
        
        /* observe view all attachments action */
        viewModel.viewAllAttachmentsAction = { [weak self] in
            guard let sSelf = self else { return }
            sSelf.viewAllAttachments()
        }
        
        /* observer did select task attachment */
        viewModel.didSelectTaskAttachment = { [weak self] (attachment) in
            guard let sSelf = self else { return }
            sSelf.didSelectAttachment(attachment: attachment)
        }
        
        /* observing read more description */
        controller.didSelectReadMoreActionForDescription = {
            self.showTaskDescription()
        }
        
        /* did select workflow task status */
        controller.didSelectWorkflowTasksStatus = { [weak self] in
            guard let sSelf = self else { return }
            sSelf.didSelectWorkflowTasksStatus()
        }
    }
    
    // MARK: - Workflow Task Variables
    private func getWorkflowTaskVariables() {
        
        refreshGroup.enter()
        getTaskDetails()

        refreshGroup.enter()
        getWorkflowTaskDetails()
        
        refreshGroup.notify(queue: CameraKit.cameraWorkerQueue) {[weak self] in
            guard let sSelf = self else { return }
            sSelf.updateUIComponents()
        }
    }
    
    // MARK: - Task details
    private func getTaskDetails() {
        let taskID = viewModel.taskID
        viewModel.taskDetails(with: taskID) { [weak self] taskNodes, error in
            guard let sSelf = self else { return }
            if error == nil {
                sSelf.viewModel.taskNode = taskNodes
            }
            sSelf.refreshGroup.leave()
        }
    }
    
    // MARK: - Workflow Task details
    private func getWorkflowTaskDetails() {
        
        viewModel.workflowTaskDetails { [weak self] error in
            guard let sSelf = self else { return }
            sSelf.refreshGroup.leave()
        }
    }
    
    // MARK: - Update UI components
    private func updateUIComponents() {
        DispatchQueue.main.async {
            self.applyLocalization()
            self.controller.buildViewModel()
            self.viewModel.selectedStatus = self.viewModel.getSelectedStatus()
            self.showOutputButtonsView()
        }
    }
    
    private func hideAllButtons() {
        buttonsBaseView.isHidden = true
        heightOutputView.constant = 0
        claimTaskView.isHidden = true
        releaseTaskButton.isHidden = true
    }
    
    private func showOutputButtonsView() {
        if viewModel.isTaskCompleted {
            hideAllButtons()
            return
        }
        
        let processInstanceStartUserId = Int(viewModel.taskNode?.processInstanceStartUserId ?? "") ?? 0
        let assigneeUserId = viewModel.assigneeUserId
        let apsUserID = UserProfile.apsUserID
        let memberOfCandidateGroup = viewModel.taskNode?.memberOfCandidateGroup ?? false

        if !memberOfCandidateGroup { // single reviewer task
            if assigneeUserId == apsUserID || processInstanceStartUserId == apsUserID {
                claimTaskView.isHidden = true
                releaseTaskButton.isHidden = true
                if !viewModel.outcomes.isEmpty {
                    buttonsBaseView.isHidden = false
                    heightOutputView.constant = 48
                }
            } else {
                hideAllButtons()
            }
        } else {
            
            if assigneeUserId < 0 { // task not claimed
                claimTaskView.isHidden = false
                releaseTaskButton.isHidden = true
                buttonsBaseView.isHidden = true
                heightOutputView.constant = 0
            } else if assigneeUserId == apsUserID { // task is claimed by me. show release button
                releaseTaskButton.isHidden = false
                claimTaskView.isHidden = true
                if !viewModel.outcomes.isEmpty {
                    buttonsBaseView.isHidden = false
                    heightOutputView.constant = 48
                }
            } else {
                hideAllButtons()
            }
        }
    }
    
    // MARK: - task description
    private func showTaskDescription() {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.taskDescription) as? TaskDescriptionDetailViewController {
            viewController.coordinatorServices = coordinatorServices
            viewController.viewModel.task = viewModel.task
            
            let navigationController = UINavigationController(rootViewController: viewController)
            self.present(navigationController, animated: true)
        }
    }
    
    // MARK: - view all attachments
    private func viewAllAttachments() {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.taskAttachments) as? TaskAttachmentsViewController {
            viewController.coordinatorServices = coordinatorServices
            viewController.viewModel.attachments.value = viewModel.workflowTaskAttachments
            viewController.viewModel.task = viewModel.task
            viewController.viewModel.isWorkflowTaskAttachments = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    private func didSelectAttachment(attachment: ListNode) {
        if attachment.syncStatus == .undefined || attachment.syncStatus == .synced {
            let title = attachment.title
            let attachmentId = attachment.guid
            viewModel.downloadContent(for: title, contentId: attachmentId) {[weak self] path, error in
                guard let sSelf = self, let path = path else { return }
                sSelf.viewModel.showPreviewController(with: path, attachment: attachment, navigationController: sSelf.navigationController)
            }
        } else {
            viewModel.startFileCoordinator(for: attachment, presenter: self.navigationController)
        }
    }
    
    private func didSelectWorkflowTasksStatus() {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.workflowTaskStatus) as? WorkflowTaskStatusViewController {
            viewController.coordinatorServices = coordinatorServices
            viewController.viewModel.workflowStatus = viewModel.workflowStatus
            viewController.viewModel.taskId = viewModel.taskId
            viewController.viewModel.comment = viewModel.comment
            viewController.viewModel.isAllowedToEditStatus = viewModel.isAllowedToEditStatus
            viewController.viewModel.workflowStatusOptions = viewModel.workflowStatusOptions
            viewController.viewModel.selectedWorkflowStatusOption = RadioListOptions(optionId: viewModel.workflowStatus, name: viewModel.workflowStatus)
            self.navigationController?.pushViewController(viewController, animated: true)
            viewController.viewModel.didSaveStatusAndComment = {[weak self] (status, comment) in
                guard let sSelf = self else { return }
                sSelf.viewModel.selectedStatus = status
                sSelf.viewModel.workflowStatus = status?.name
                sSelf.viewModel.comment = comment
                sSelf.controller.buildViewModel()
            }
        }
    }
}

// MARK: - Table View Data Source and Delegates
extension WflowTaskDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            if cell is TitleTableViewCell {
                (cell as? TitleTableViewCell)?.applyTheme(with: theme)
            } else if cell is InfoTableViewCell {
                (cell as? InfoTableViewCell)?.applyTheme(with: theme)
            } else if cell is PriorityTableViewCell {
                (cell as? PriorityTableViewCell)?.applyTheme(with: theme)
            } else if cell is TaskHeaderTableViewCell {
                (cell as? TaskHeaderTableViewCell)?.applyTheme(with: theme)
            } else if cell is EmptyPlaceholderTableViewCell {
                (cell as? EmptyPlaceholderTableViewCell)?.applyTheme(with: theme)
            } else if cell is TaskAttachmentTableViewCell {
                (cell as? TaskAttachmentTableViewCell)?.applyTheme(with: theme)
            } else if cell is SpaceTableViewCell {
                (cell as? SpaceTableViewCell)?.applyTheme(with: theme)
            }
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowViewModel = viewModel.rowViewModels.value[indexPath.row]
        switch rowViewModel {
        case is SpaceTableCellViewModel:
            return 40.0
        default:
            return UITableView.automaticDimension
        }
    }
}

// MARK: - Claim or Release Task Button
extension WflowTaskDetailViewController {
    
    private func addReleaseTaskButton() {
        releaseTaskButton.accessibilityIdentifier = "release-task-button"
        releaseTaskButton.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 30.0)
        releaseTaskButton.addTarget(self,
                               action: #selector(releaseTaskButtonAction),
                               for: UIControl.Event.touchUpInside)
        releaseTaskButton.setTitle(LocalizationConstants.Workflows.releaseTitle, for: .normal)
        releaseTaskButton.titleLabel?.numberOfLines = 1
        releaseTaskButton.titleLabel?.adjustsFontSizeToFitWidth = true
        releaseTaskButton.titleLabel?.lineBreakMode = .byClipping
        releaseTaskButton.isHidden = true
    
        let searchBarButtonItem = UIBarButtonItem(customView: releaseTaskButton)
        searchBarButtonItem.accessibilityIdentifier = "barButton"
        let currHeight = searchBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: 30.0)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = searchBarButtonItem
    }

    @objc func releaseTaskButtonAction() {
        viewModel.claimUnclaimTask(isClaim: false) { [weak self] error in
            guard let sSelf = self else { return }
            if error == nil {
                sSelf.backAndRefreshAction(isRefreshList: true)
            }
        }
    }
    
    @IBAction func claimTaskButtonAction(_ sender: Any) {
        viewModel.claimUnclaimTask(isClaim: true) { [weak self] error in
            guard let sSelf = self else { return }
            if error == nil {
                sSelf.backAndRefreshAction(isRefreshList: true)
            }
        }
    }
}
