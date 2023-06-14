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

class StartWorkflowViewController: SystemSearchViewController {
    @IBOutlet weak var progressView: MDCProgressView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startWorkflowView: UIView!
    @IBOutlet weak var startWorkflowButton: MDCButton!
    var viewModel: StartWorkflowViewModel { return controller.viewModel }
    lazy var controller: StartWorkflowController = { return StartWorkflowController( currentTheme: coordinatorServices?.themingService?.activeTheme) }()
    private var dialogTransitionController: MDCDialogTransitionController?
    private var cameraCoordinator: CameraScreenCoordinator?
    private var photoLibraryCoordinator: PhotoLibraryScreenCoordinator?
    private var fileManagerCoordinator: FileManagerScreenCoordinator?
    
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.services = coordinatorServices ?? CoordinatorServices()
        viewModel.workflowOperationsModel = WorkflowOperationsModel(services: viewModel.services, tempWorkflowId: viewModel.tempWorkflowId)
        viewModel.workflowOperationsModel?.attachments.value = viewModel.selectedAttachments
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationItem.setHidesBackButton(true, animated: true)
        addBackButton()
        progressView.progress = 0
        progressView.mode = .indeterminate
        applyTheme()
        applyLocalization()
        registerCells()
        addAccessibility()
        setupBindings()
        getWorkflowDetails()
        linkContent()
        AnalyticsManager.shared.pageViewEvent(for: Event.Page.startWorkflowScreen)
        self.dialogTransitionController = MDCDialogTransitionController()
        controller.registerEvents()
        if !viewModel.isDetailWorkflow {
            ProfileService.getAPSSource() // to get APS Source
        }
        getTaskList() // to get tasks count in workflow detail
        
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
        controller.buildViewModel()
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
        self.title = viewModel.screenTitle
    }
    
    func registerCells() {
        self.tableView.register(UINib(nibName: CellConstants.TableCells.titleCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.titleCell)
        self.tableView.register(UINib(nibName: CellConstants.TableCells.infoCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.infoCell)
        self.tableView.register(UINib(nibName: CellConstants.TableCells.priorityCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.priorityCell)
        self.tableView.register(UINib(nibName: CellConstants.TableCells.taskHeaderCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.taskHeaderCell)
        self.tableView.register(UINib(nibName: CellConstants.TableCells.emptyPlaceholderCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.emptyPlaceholderCell)
        self.tableView.register(UINib(nibName: CellConstants.TableCells.taskAttachment, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.taskAttachment)
        self.tableView.register(UINib(nibName: CellConstants.TableCells.addTaskAttachment, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.addTaskAttachment)
        self.tableView.register(UINib(nibName: CellConstants.TableCells.spaceCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.spaceCell)
    }
    
    private func addAccessibility() {
        progressView.isAccessibilityElement = false
    }
    
    // MARK: - Public Helpers

    func applyTheme() {
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme,
              let buttonScheme = coordinatorServices?.themingService?.containerScheming(for: .dialogButton)
        else { return }
        
        startWorkflowView.backgroundColor = currentTheme.surfaceColor
        startWorkflowButton.applyContainedTheme(withScheme: buttonScheme)
        startWorkflowButton.isUppercaseTitle = false
        startWorkflowButton.setTitle(LocalizationConstants.Accessibility.startWorkflow, for: .normal)
        startWorkflowButton.layer.cornerRadius = UIConstants.cornerRadiusDialog
        startWorkflowButton.setShadowColor(.clear, for: .normal)
        startWorkflowButton.setTitleColor(.white, for: .normal)
        
        if viewModel.isDetailWorkflow {
            startWorkflowView.isHidden = true
        }
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
    }
    
    @IBAction func startWorkflowButtonAction(_ sender: Any) {
        if viewModel.isLocalContentAvailable() {
            showUploadingInQueueWarning()
        } else {
            startWorkflowAPIIntegration()
        }
    }
    
    private func showUploadingInQueueWarning() {
        let title = LocalizationConstants.Workflows.warningTitle
        let message = LocalizationConstants.Workflows.attachmentInProgressWarning
    
        let confirmAction = MDCAlertAction(title: LocalizationConstants.Dialog.confirmTitle) { [weak self] _ in
            guard let sSelf = self else { return }
            sSelf.startWorkflowAPIIntegration()
        }
        confirmAction.accessibilityIdentifier = "confirmActionButton"
        
        let cancelAction = MDCAlertAction(title: LocalizationConstants.General.cancel) { _ in }
        cancelAction.accessibilityIdentifier = "cancelActionButton"

        _ = self.showDialog(title: title,
                                       message: message,
                                       actions: [confirmAction, cancelAction],
                                       completionHandler: {})
    }
    
    // MARK: - Start workflow API integration
    private func startWorkflowAPIIntegration() {        
        if !viewModel.isAllowedToStartWorkflow() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                Snackbar.display(with: String(format: LocalizationConstants.Workflows.selectAssigneeMessage),
                                 type: .warning, finish: nil)
            })
        } else {
            viewModel.startWorkflow {[weak self] isError in
                guard let sSelf = self else { return }
                if !isError {
                    sSelf.updateWorkflowsList()
                    sSelf.backButtonAction()
                }
            }
        }
    }
    
    private func updateWorkflowsList() {
        let notification = NSNotification.Name(rawValue: KeyConstants.Notification.refreshWorkflows)
        NotificationCenter.default.post(name: notification,
                                        object: nil,
                                        userInfo: nil)
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
        self.navigationController?.popViewController(animated: true)
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
        
        /* observing read more description */
        controller.didSelectReadMoreActionForDescription = {
            self.showWorkflowDescription()
        }
        
        /* observing edit title */
        controller.didSelectEditTitle = {
            self.editTitleAndDescriptionAction()
        }
        
        /* observing edit due date */
        controller.didSelectEditDueDate = {
            self.editDueDateAction()
        }
        
        /* observing reset due date */
        controller.didSelectResetDueDate = {
            self.resetDueDateAction()
        }
        
        /* observing priority */
        controller.didSelectPriority = {
            self.changePriorityAction()
        }
        
        /* observing assignee */
        controller.didSelectAssignee = {
            self.changeAssigneeAction()
        }
        
        /* observer did select add attachment */
        controller.didSelectAddAttachment = {
            self.addAttachmentButtonAction()
        }
        
        /* observe view all attachments action */
        viewModel.viewAllAttachmentsAction = { [weak self] in
            guard let sSelf = self else { return }
            sSelf.viewAllAttachments()
        }
        
        /* observer did select task attachment */
        viewModel.didSelectAttachment = { [weak self] (attachment) in
            guard let sSelf = self else { return }
            sSelf.didSelectAttachment(attachment: attachment)
        }
        
        /* observer did select delete attachment */
        viewModel.didSelectDeleteAttachment = { [weak self] (attachment) in
            guard let sSelf = self else { return }
            sSelf.didSelectDeleteAttachment(attachment: attachment)
        }
        
        controller.didSelectTasksDetails = { [weak self] in
            guard let sSelf = self else { return }
            sSelf.didSelectTasksDetails()
        }
    }
    
    // MARK: - Workflow details
    private func getWorkflowDetails() {
        if viewModel.isDetailWorkflow { return }
        viewModel.fetchProcessDefinition {[weak self] processDefinition, error in
            guard let sSelf = self else { return }
            sSelf.tableView.reloadData()
            sSelf.getFormFields()
        }
    }
    
    // MARK: - Link content
    private func linkContent() {
        if viewModel.isDetailWorkflow { return }
        viewModel.linkContentToAPS { [weak self] node, error in
            guard let sSelf = self else { return }
            if let node = node {
                sSelf.updateListNodeForLinkContent(node: node)
            }
        }
    }
    
    private func updateListNodeForLinkContent(node: ListNode) {
        var attachments = viewModel.workflowOperationsModel?.attachments.value ?? []
        if let index = attachments.firstIndex(where: {$0.guid == node.parentGuid}) {
            attachments[index] = node
            viewModel.workflowOperationsModel?.attachments.value = attachments
            controller.buildViewModel()
        }
    }
    
    private func getFormFields() {
        viewModel.getFormFieldsToCheckAssigneeType {[weak self] error in
            guard let sSelf = self else { return }
            sSelf.controller.buildViewModel()
        }
    }
    
    private func showWorkflowDescription() {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.taskDescription) as? TaskDescriptionDetailViewController {
            viewController.coordinatorServices = coordinatorServices
            viewController.viewModel.appDefinition = viewModel.appDefinition
            let navigationController = UINavigationController(rootViewController: viewController)
            self.present(navigationController, animated: true)
        }
    }
}

// MARK: - Table View Data Source and Delegates
extension StartWorkflowViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            } else if cell is AddAttachmentTableViewCell {
                (cell as? AddAttachmentTableViewCell)?.applyTheme(with: theme)
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

// MARK: - Edit Task Name and description
extension StartWorkflowViewController {
    
    private func editTitleAndDescriptionAction() {
        
        let viewController = CreateNodeSheetViewControler.instantiateViewController()
        let createTaskViewModel = CreateTaskViewModel(coordinatorServices: coordinatorServices,
                                                      createTaskViewType: .editTask,
                                                      task: createTaskNodeObject())
        
        viewController.coordinatorServices = coordinatorServices
        viewController.createTaskViewModel = createTaskViewModel
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = dialogTransitionController
        viewController.mdc_dialogPresentationController?.dismissOnBackgroundTap = false
        self.present(viewController, animated: true)
        viewController.callBack = { [weak self] (task, title, description) in
            guard let sSelf = self else { return }
            sSelf.updateTaskTitleAndDescription(with: title, description: description)
        }
    }

    private func updateTaskTitleAndDescription(with title: String?, description: String?) {
        viewModel.appDefinition?.name = title
        viewModel.appDefinition?.description = description
        controller.buildViewModel()
    }
    
    private func createTaskNodeObject() -> TaskNode {
        return TaskNode(guid: "0",
                        title: viewModel.processDefintionTitle,
                        name: viewModel.processDefintionTitle,
                        description: viewModel.processDefintionDescription)
    }
}

// MARK: - Edit Due Date
extension StartWorkflowViewController {
    
    func editDueDateAction() {
        
        let viewController = DatePickerViewController.instantiateViewController()
        let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.dismissOnDraggingDownSheet = false
        viewController.coordinatorServices = coordinatorServices
        viewController.viewModel.selectedDate = viewModel.dueDate
        self.navigationController?.present(bottomSheet, animated: true, completion: nil)
        viewController.callBack = { [weak self] (dueDate) in
            guard let sSelf = self else { return }
            sSelf.updateDueDate(with: dueDate)
        }
    }
    
    func resetDueDateAction() {
        self.updateDueDate(with: nil)
    }
    
    private func updateDueDate(with dueDate: Date?) {
        viewModel.dueDate = dueDate
        controller.buildViewModel()
    }
}

// MARK: - Edit Priority
extension StartWorkflowViewController {
    
    func changePriorityAction() {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.taskPriority) as? TaskPriorityViewController {
            let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
            bottomSheet.dismissOnDraggingDownSheet = false
            viewController.coordinatorServices = coordinatorServices
            viewController.viewModel.priority = viewModel.priority
            self.navigationController?.present(bottomSheet, animated: true, completion: nil)
            viewController.callBack = { [weak self] (priority) in
                guard let sSelf = self else { return }
                sSelf.updateTaskPriority(with: priority)
            }
        }
    }
    
    private func updateTaskPriority(with priority: Int) {
        viewModel.priority = priority
        controller.buildViewModel()
    }
}

// MARK: - Edit Assignee
extension StartWorkflowViewController {
    
    func changeAssigneeAction() {
        if viewModel.isAllowedToEditAssignee {
            let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.taskAssignee) as? TaskAssigneeViewController {
                viewController.coordinatorServices = coordinatorServices
                viewController.viewModel.isWorkflowSearch = true
                viewController.viewModel.isSearchByName = viewModel.isSingleReviewer
                let navigationController = UINavigationController(rootViewController: viewController)
                self.present(navigationController, animated: true)
                viewController.callBack = { [weak self] (assignee) in
                    guard let sSelf = self else { return }
                    sSelf.updateAssignee(with: assignee)
                }
            }
        }
    }
    
    private func updateAssignee(with assignee: TaskNodeAssignee) {
        viewModel.assignee = assignee
        controller.buildViewModel()
    }
}

// MARK: - Add Attachment
extension StartWorkflowViewController {
    
    private func addAttachmentButtonAction() {
        AnalyticsManager.shared.didTapUploadTaskAttachment(isWorkflow: true)

        let actions = ActionsMenuFolderAttachments.actions()
        let actionMenuViewModel = ActionMenuViewModel(menuActions: actions,
                                                      coordinatorServices: coordinatorServices)
        let viewController = ActionMenuViewController.instantiateViewController()
        let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
        viewController.coordinatorServices = coordinatorServices
        viewController.actionMenuModel = actionMenuViewModel
        self.present(bottomSheet, animated: true, completion: nil)
        viewController.didSelectAction = {[weak self] (action) in
            guard let sSelf = self else { return }
            sSelf.handleAction(action: action)
        }
    }
    
    private func handleAction(action: ActionMenu) {
        if action.type.isCreateActions {
            if action.type == .uploadMedia {
                showPhotoLibrary()
            } else if action.type == .createMedia {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    self.showCamera()
                })
            } else if action.type == .uploadFiles {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    self.showFiles()
                })
            }
        }
    }

    func showPhotoLibrary() {
        AnalyticsManager.shared.uploadPhotoforTasks(isWorkflow: true)
        if let presenter = self.navigationController {
            let coordinator = PhotoLibraryScreenCoordinator(with: presenter,
                                                            parentListNode: workflowNode(),
                                                            attachmentType: .workflow)
            coordinator.start()
            photoLibraryCoordinator = coordinator
            coordinator.didSelectAttachment = { [weak self] (uploadTransfers) in
                guard let sSelf = self else { return }
                sSelf.didSelectUploadTransfers(uploadTransfers: uploadTransfers)
            }
        }
    }

    func showCamera() {
        AnalyticsManager.shared.takePhotoforTasks(isWorkflow: true)
        if let presenter = self.navigationController {
            let coordinator = CameraScreenCoordinator(with: presenter,
                                                      parentListNode: workflowNode(),
                                                      attachmentType: .workflow)
            coordinator.start()
            cameraCoordinator = coordinator
            coordinator.didSelectAttachment = { [weak self] (uploadTransfers) in
                guard let sSelf = self else { return }
                sSelf.didSelectUploadTransfers(uploadTransfers: uploadTransfers)
            }
        }
    }

    func showFiles() {
        AnalyticsManager.shared.uploadFilesforTasks(isWorkflow: true)
        if let presenter = self.navigationController {
            let coordinator = FileManagerScreenCoordinator(with: presenter,
                                                           parentListNode: workflowNode(),
                                                           attachmentType: .workflow)
            coordinator.start()
            fileManagerCoordinator = coordinator
            coordinator.didSelectAttachment = { [weak self] (uploadTransfers) in
                guard let sSelf = self else { return }
                sSelf.didSelectUploadTransfers(uploadTransfers: uploadTransfers)
            }
        }
    }

    func workflowNode() -> ListNode {
        return ListNode(guid: viewModel.tempWorkflowId,
                        title: viewModel.processDefintionTitle,
                        path: "",
                        nodeType: .folder)
    }
    
    private func viewAllAttachments() {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.taskAttachments) as? TaskAttachmentsViewController {
            viewController.coordinatorServices = coordinatorServices
            viewController.viewModel.attachmentType = .workflow
            viewController.viewModel.tempWorkflowId = viewModel.tempWorkflowId
            viewController.viewModel.processDefintionTitle = viewModel.processDefintionTitle
            viewController.viewModel.workflowOperationsModel = viewModel.workflowOperationsModel
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    private func didSelectAttachment(attachment: ListNode) {
      //  viewModel.workflowOperationsModel?.startFileCoordinator(for: attachment, presenter: self.navigationController)
    }
    
    private func didSelectUploadTransfers(uploadTransfers: [UploadTransfer]) {
        for uploadTransfer in uploadTransfers {
            viewModel.workflowOperationsModel?.uploadAttachmentOperation(transfer: uploadTransfer, completionHandler: {[weak self] isError in
                guard self != nil else { return }
                AlfrescoLog.debug("\(isError)")
            })
        }
    }
}

// MARK: - Delete Attachment
extension StartWorkflowViewController {
    
    private func didSelectDeleteAttachment(attachment: ListNode) {
        AnalyticsManager.shared.didTapDeleteTaskAttachment(isWorkflow: true)
        if var attachments = viewModel.workflowOperationsModel?.attachments.value {
            if let index = attachments.firstIndex(where: {$0.guid == attachment.guid}) {
                attachments.remove(at: index)
                viewModel.workflowOperationsModel?.attachments.value = attachments
                controller.buildViewModel()
            }
        }
    }
}

// MARK: - Workflow details
extension StartWorkflowViewController {
    
    func getTaskList() {
        if !viewModel.isDetailWorkflow { return }
        let params = TaskListParams(page: 0,
                                    processInstanceId: viewModel.workflowDetailNode?.processID,
                                    state: "all")
        viewModel.taskList(with: params) {[weak self] taskList, error in
            guard let sSelf = self else { return }
            if error == nil {
                sSelf.controller.buildViewModel()
            }
        }
    }
    
    private func didSelectTasksDetails() {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if let taskListViewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.taskList) as? TasksListViewController {
            taskListViewController.title = LocalizationConstants.ScreenTitles.tasks
            taskListViewController.coordinatorServices = coordinatorServices
            taskListViewController.viewModel.workflowDetailNode = viewModel.workflowDetailNode
            taskListViewController.navigationViewController = self.navigationController
            self.navigationController?.pushViewController(taskListViewController, animated: true)
        }
    }
}
