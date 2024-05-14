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

class TaskAttachmentsViewController: SystemSearchViewController {
    @IBOutlet weak var progressView: MDCProgressView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var attachmentsCountLabel: UILabel!
    @IBOutlet weak var addAttachmentButton: MDCFloatingButton!
    @IBOutlet weak var emptyListImageView: UIImageView!
    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListTitle: UILabel!
    @IBOutlet weak var emptyListSubtitle: UILabel!
    var refreshControl: UIRefreshControl?
    var viewModel: TaskAttachmentsControllerViewModel { return controller.viewModel }
    lazy var controller: TaskAttachmentsController = { return TaskAttachmentsController( currentTheme: coordinatorServices?.themingService?.activeTheme) }()
    private var cameraCoordinator: CameraScreenCoordinator?
    private var photoLibraryCoordinator: PhotoLibraryScreenCoordinator?
    private var fileManagerCoordinator: FileManagerScreenCoordinator?
    var multiSelection = true

    // MARK: - View did load

    override func viewDidLoad() {
        super.viewDidLoad()
        emptyListView.isHidden = true
        viewModel.services = coordinatorServices ?? CoordinatorServices()
        controller.registerEvents()
        progressView.progress = 0
        progressView.mode = .indeterminate
        addRefreshControl()
        registerCells()
        addAccessibility()
        controller.buildViewModel()
        setupBindings()
        getTaskAttachments()
        logScreenEvent()
        checkForAddAttachmentButton()
        if viewModel.isWorkflowTaskAttachments {
            viewModel.isLoading.value = false
        }
    }
    
    private func logScreenEvent() {
        if viewModel.attachmentType == .task {
            AnalyticsManager.shared.pageViewEvent(for: Event.Page.taskAttachmentsScreen)
        } else {
            viewModel.isLoading.value = false
            AnalyticsManager.shared.pageViewEvent(for: Event.Page.workflowAttachmentsScreen)
        }
    }

    private func checkForAddAttachmentButton() {
        if viewModel.isWorkflowTaskAttachments {
            self.hideAddAttachmentButton()
        } else if viewModel.isTaskCompleted && viewModel.attachmentType == .task {
            self.hideAddAttachmentButton()
        } else {
            self.showAddAttachmentButton()
        }
    }
    private func showAddAttachmentButton() {
        addAttachmentButton.isHidden = false
        tableView.contentInset.bottom = 90
    }
    
    private func hideAddAttachmentButton() {
        addAttachmentButton.isHidden = true
        tableView.contentInset.bottom = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        updateTheme()
        applyLocalization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.isHidden = false
    }
    
    private func checkAddAttachButton() {
        if viewModel.attachmentType == .workflow {
            if !multiSelection {
                if viewModel.attachmentsCount?.isEmpty != nil {
                    self.hideAddAttachmentButton()
                } else {
                    self.showAddAttachmentButton()
                }
            }
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
        if viewModel.isWorkflowTaskAttachments { return }
        if viewModel.attachmentType == .task {
            let refreshControl = UIRefreshControl()
            tableView.addSubview(refreshControl)
            refreshControl.addTarget(self, action: #selector(handlePullToRefresh),
                                     for: .valueChanged)
            self.refreshControl = refreshControl
        }
    }

    private func applyLocalization() {
        self.title = LocalizationConstants.Tasks.attachedFilesTitle
        attachmentsCountLabel.text = viewModel.attachmentsCount
        checkAddAttachButton()
        showHideEmptyView()
    }
    
    private func showHideEmptyView() {
        if viewModel.attachmentType == .workflow {
            let attachments = viewModel.workflowOperationsModel?.attachments.value ?? []
            let localAttachments = attachments.filter { $0.parentGuid == viewModel.tempWorkflowId }

            if !localAttachments.isEmpty {
                emptyListView.isHidden = true
            } else {
                emptyListView.isHidden = false
                let emptyList = viewModel.emptyList()
                emptyListImageView.image = emptyList.icon
                emptyListTitle.text = emptyList.title
                emptyListSubtitle.text = emptyList.description
            }

        }
    }
    
    func registerCells() {
        self.tableView.register(UINib(nibName: CellConstants.TableCells.taskAttachment, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.taskAttachment)
    }
    
    private func addAccessibility() {
        self.navigationItem.backBarButtonItem?.accessibilityLabel = LocalizationConstants.Accessibility.back
        self.navigationItem.backBarButtonItem?.accessibilityIdentifier = "back-button"
        progressView.isAccessibilityElement = false
        attachmentsCountLabel.accessibilityTraits = .updatesFrequently
        attachmentsCountLabel.accessibilityLabel = attachmentsCountLabel.text
        
        addAttachmentButton.accessibilityLabel = LocalizationConstants.EditTask.addAttachments
        addAttachmentButton.accessibilityIdentifier = "add-attachment"
    }
    
    @objc private func handlePullToRefresh() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.getTaskAttachments()
        }
    }
    
    // MARK: - Public Helpers

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        emptyListView.backgroundColor = currentTheme.surfaceColor
        emptyListTitle.applyeStyleHeadline6OnSurface(theme: currentTheme)
        emptyListTitle.textAlignment = .center
        emptyListSubtitle.applyStyleBody2OnSurface60(theme: currentTheme)
        emptyListSubtitle.textAlignment = .center
        attachmentsCountLabel.applyStyleBody2OnSurface60(theme: currentTheme)
        refreshControl?.tintColor = currentTheme.primaryT1Color
        addAttachmentButton.backgroundColor = currentTheme.primaryT1Color
        addAttachmentButton.tintColor = currentTheme.onPrimaryColor

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
        
        /* observing attachments */
        viewModel.attachments.addObserver() { [weak self] (attachments) in
            guard let sSelf = self else { return }
            DispatchQueue.main.async {
                sSelf.applyLocalization()
                sSelf.tableView.reloadData()
            }
        }
        
        /* observer did select task attachment */
        viewModel.didSelectTaskAttachment = { [weak self] (attachment) in
            guard let sSelf = self else { return }
            sSelf.didSelectAttachment(attachment: attachment)
        }
        
        /* observer did select delete attachment */
        viewModel.didSelectDeleteAttachment = { [weak self] (attachment) in
            guard let sSelf = self else { return }
            sSelf.didSelectDeleteAttachment(attachment: attachment)
        }
    }
    
    private func getTaskAttachments() {
        if viewModel.attachmentType == .workflow || viewModel.isWorkflowTaskAttachments { return }
        let taskID = viewModel.taskID
        viewModel.taskAttachments(with: taskID) { [weak self] taskAttachments, error in
            guard let sSelf = self else { return }
            if error == nil {
                sSelf.viewModel.attachments.value = taskAttachments

                // Insert nodes to be uploaded
                _ = sSelf.controller.uploadTransferDataAccessor.queryAll(for: sSelf.viewModel.taskID, attachmentType: .task) { uploadTransfers in
                    sSelf.controller.insert(uploadTransfers: uploadTransfers)
                }
                
                sSelf.controller.buildViewModel()
            }
        }
    }
    
    private func didSelectAttachment(attachment: ListNode) {
        if viewModel.attachmentType == .task {
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
        } else {
           // viewModel.workflowOperationsModel?.startFileCoordinator(for: attachment, presenter: self.navigationController)
        }
    }
}

// MARK: - Table View Data Source and Delegates
extension TaskAttachmentsViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            if cell is TaskAttachmentTableViewCell {
                (cell as? TaskAttachmentTableViewCell)?.applyTheme(with: theme)
            }
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Delete Attachment
extension TaskAttachmentsViewController {
    
    private func didSelectDeleteAttachment(attachment: ListNode) {
        if viewModel.attachmentType == .task {
            viewModel.showDeleteAttachmentAlert(for: attachment, on: self) {[weak self] success in
                guard let sSelf = self else { return }
                if success {
                    sSelf.deleteAttachmentFromList(attachment: attachment)
                }
            }
        } else {
            AnalyticsManager.shared.didTapDeleteTaskAttachment(isWorkflow: true)
            var attachments = viewModel.workflowOperationsModel?.attachments.value ?? []
            if let index = attachments.firstIndex(where: {$0.guid == attachment.guid}) {
                attachments.remove(at: index)
                viewModel.workflowOperationsModel?.attachments.value = attachments
                controller.buildViewModel()
                DispatchQueue.main.async {
                    self.applyLocalization()
                }
                if viewModel.attachmentType != .workflow {
                    popToPreviousController(attachments: attachments)
                }
            }
        }
    }
    
    private func deleteAttachmentFromList(attachment: ListNode) {
        var attachments = viewModel.attachments.value
        if let index = attachments.firstIndex(where: {$0.guid == attachment.guid}) {
            attachments.remove(at: index)
            viewModel.attachments.value = attachments
            controller.buildViewModel()
            popToPreviousController(attachments: attachments)
        }
    }
    
    private func popToPreviousController(attachments: [ListNode]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            if attachments.isEmpty {
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
}

// MARK: - Add Attachment
extension TaskAttachmentsViewController {
    
    @IBAction func addAttachmentButtonAction(_ sender: Any) {
        if viewModel.attachmentType == .task {
            AnalyticsManager.shared.didTapUploadTaskAttachment()
        } else {
            AnalyticsManager.shared.didTapUploadTaskAttachment(isWorkflow: true)
        }
        
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
        
        if viewModel.attachmentType == .task {
            AnalyticsManager.shared.uploadPhotoforTasks()
            if let presenter = self.navigationController {
                let coordinator = PhotoLibraryScreenCoordinator(with: presenter,
                                                                parentListNode: taskNode(),
                                                                attachmentType: .task)
                coordinator.start()
                photoLibraryCoordinator = coordinator
            }
        } else {
            AnalyticsManager.shared.uploadPhotoforTasks(isWorkflow: true)
            if let presenter = self.navigationController {
                let coordinator = PhotoLibraryScreenCoordinator(with: presenter,
                                                                parentListNode: workflowNode(),
                                                                attachmentType: .workflow)
                coordinator.multiSelection = multiSelection
                coordinator.start()
                photoLibraryCoordinator = coordinator
                coordinator.didSelectAttachment = { [weak self] (uploadTransfers) in
                    guard let sSelf = self else { return }
                    sSelf.didSelectUploadTransfers(uploadTransfers: uploadTransfers)
                }
            }
        }
    }
        
    func showCamera() {
        if viewModel.attachmentType == .task {
            AnalyticsManager.shared.takePhotoforTasks()
            if let presenter = self.navigationController {
                let coordinator = CameraScreenCoordinator(with: presenter,
                                                          parentListNode: taskNode(),
                                                          attachmentType: .task)
                coordinator.start()
                cameraCoordinator = coordinator
            }
        } else {
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
    }
    
    func showFiles() {
        if viewModel.attachmentType == .task {
            AnalyticsManager.shared.uploadFilesforTasks()
            if let presenter = self.navigationController {
                let coordinator = FileManagerScreenCoordinator(with: presenter,
                                                               parentListNode: taskNode(),
                                                               attachmentType: .task)
                coordinator.start()
                fileManagerCoordinator = coordinator
            }
        } else {
            AnalyticsManager.shared.uploadFilesforTasks(isWorkflow: true)
            if let presenter = self.navigationController {
                let coordinator = FileManagerScreenCoordinator(with: presenter,
                                                               parentListNode: workflowNode(),
                                                               attachmentType: .workflow)
                coordinator.multiSelection = multiSelection
                coordinator.start()
                fileManagerCoordinator = coordinator
                coordinator.didSelectAttachment = { [weak self] (uploadTransfers) in
                    guard let sSelf = self else { return }
                    sSelf.didSelectUploadTransfers(uploadTransfers: uploadTransfers)
                }
            }
        }
    }
    
    func taskNode () -> ListNode {
        return ListNode(guid: viewModel.taskID,
                        title: viewModel.taskName ?? "",
                        path: "",
                        nodeType: .folder)
    }
    
    func workflowNode() -> ListNode {
        return ListNode(guid: viewModel.tempWorkflowId,
                        title: viewModel.processDefintionTitle,
                        path: "",
                        nodeType: .folder)
    }
    
    private func didSelectUploadTransfers(uploadTransfers: [UploadTransfer]) {
        for uploadTransfer in uploadTransfers {
            viewModel.workflowOperationsModel?.uploadAttachmentOperation(transfer: uploadTransfer, completionHandler: {[weak self] isError in
                guard let sSelf = self else { return }
                DispatchQueue.main.async {
                    sSelf.applyLocalization()
                }
            })
        }
    }
}
