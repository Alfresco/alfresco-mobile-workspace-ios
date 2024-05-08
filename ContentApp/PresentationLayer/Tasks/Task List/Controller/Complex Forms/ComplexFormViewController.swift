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
import Foundation

class ComplexFormViewController: SystemSearchViewController {
   
    @IBOutlet weak var progressView: MDCProgressView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var pageIndicatorView: UIView!
    @IBOutlet weak var previousPageButton: MDCButton!
    @IBOutlet weak var nextPageButton: MDCButton!
    @IBOutlet weak var labelPageNumber: UILabel!
    @IBOutlet weak var heightFooterView: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var outcomeView: UIView!
    @IBOutlet weak var saveButtonStackView: UIStackView!
    @IBOutlet weak var saveButton: MDCButton!
    @IBOutlet weak var completeButton: MDCButton!
    @IBOutlet weak var actionButton: MDCFloatingButton!
    lazy var complexFormViewModel = ComplexFormViewModel()
    private var filePreviewCoordinator: FilePreviewScreenCoordinator?
    private var filesAndFolderViewController: FilesandFolderListViewController?
    private var recentViewController: ListViewController?
    
    var viewModel: StartWorkflowViewModel { return controller.viewModel }
    lazy var controller: ComplexFormController = { return ComplexFormController( currentTheme: coordinatorServices?.themingService?.activeTheme) }()
    private var saveId = 1045
    private var completeId = 1046
    private var completeString = "Complete"

    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        startOutcome()
        viewModel.services = coordinatorServices ?? CoordinatorServices()
        self.complexFormViewModel.services = coordinatorServices ?? CoordinatorServices()
        viewModel.workflowOperationsModel = WorkflowOperationsModel(services: viewModel.services, tempWorkflowId: viewModel.tempWorkflowId)
        viewModel.workflowOperationsModel?.attachments.value = viewModel.selectedAttachments
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationItem.setHidesBackButton(true, animated: true)
        addBackButton()
        progressView.progress = 0
        progressView.mode = .indeterminate
        registerCells()
        setupBindings()
        applyLocalization()
        getWorkflowDetails()
        AnalyticsManager.shared.pageViewEvent(for: Event.Page.startWorkflowScreen)
        if viewModel.isDetailWorkflow {
            infoButton()
        } else {
            ProfileService.getAPSSource() // to get APS Source
        }
        
        // ReSignIn Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleReSignIn(notification:)),
                                               name: Notification.Name(KeyConstants.Notification.reSignin),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
       
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        controller.buildViewModel()
        if viewModel.isShowDoneCompleteBtn {
            saveButton.isHidden = true
            completeButton.isHidden = true
        }
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    private func applyLocalization() {
        self.title = viewModel.screenTitle
    }
    
    func registerCells() {
        self.tableView.register(UINib(nibName: CellConstants.TableCells.multiLineTextComplexForm, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.multiLineTextComplexForm)
        
        self.tableView.register(UINib(nibName: CellConstants.TableCells.singleLineTextComplexForm, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.singleLineTextComplexForm)
        
        self.tableView.register(UINib(nibName: CellConstants.TableCells.datePickerTextComplexForm, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.datePickerTextComplexForm)
        
        self.tableView.register(UINib(nibName: CellConstants.TableCells.assigneeTableViewCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.assigneeTableViewCell)
        
        self.tableView.register(UINib(nibName: CellConstants.TableCells.dropDownTableViewCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.dropDownTableViewCell)
        
        self.tableView.register(UINib(nibName: CellConstants.TableCells.hyperlinkTableViewCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.hyperlinkTableViewCell)
        
        self.tableView.register(UINib(nibName: CellConstants.TableCells.checkBoxTableViewCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.checkBoxTableViewCell)
        
        self.tableView.register(UINib(nibName: CellConstants.TableCells.addAttachmentComplexTableViewCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.addAttachmentComplexTableViewCell)
        
    }
    
    @objc private func handleReSignIn(notification: Notification) {
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + tableView.rowHeight, right: 0)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = .zero
    }
    
    // MARK: - Start workflow API integration
    private func startWorkflowAPIIntegration(name: String, id: Int) {
        if viewModel.isLocalContentAvailable() {
            showUploadingInQueueWarning(name: name, id: id)
        } else {
            startWorkFlowAction(name: name, id: id)
        }
    }
    
    private func startWorkFlowAction(name: String, id: Int) {
        if viewModel.isDetailWorkflow {
            if name == LocalizationConstants.General.save && id == saveId {
                saveWorkflowAction()
            } else {
                taskFormWorkflowAction(outcome: name)
            }
        } else {
            let name = self.viewModel.processDefinition??.name ?? ""
            let processDefinitionId = self.viewModel.processDefinition??.processId ?? ""
            self.complexFormViewModel.startWorkflowProcess(for: self.viewModel.formFields, name: name, processDefinitionId: processDefinitionId, completionHandler: { [weak self] isError in
                guard let sSelf = self else { return }
                if !isError {
                    sSelf.updateWorkflowsList()
                    sSelf.backButtonAction()
                }
            })
        }
    }
    private func taskFormWorkflowAction(outcome: String) {
        let taskId = self.viewModel.taskId
        self.complexFormViewModel.saveTaskMethod(for: self.viewModel.formFields, taskId: taskId, outcome: outcome, completionHandler: { [weak self] isError in
            guard let sSelf = self else { return }
            if !isError {
                sSelf.updateTaskList()
                sSelf.backButtonAction()
            }
        })
    }
    
    private func saveWorkflowAction() {
        let taskId = self.viewModel.taskId
        self.complexFormViewModel.saveTaskFormMethod(for: self.viewModel.formFields, taskId: taskId, completionHandler: { [weak self] isError in
            guard let sSelf = self else { return }
            if !isError {
                sSelf.updateTaskList()
                sSelf.backButtonAction()
            }
        })
    }
    
    private func updateTaskList() {
        let notification = NSNotification.Name(rawValue: KeyConstants.Notification.refreshTaskList)
        NotificationCenter.default.post(name: notification,
                                        object: nil,
                                        userInfo: nil)
    }
    
    private func updateWorkflowsList() {
        let notification = NSNotification.Name(rawValue: KeyConstants.Notification.refreshWorkflows)
        NotificationCenter.default.post(name: notification,
                                        object: nil,
                                        userInfo: nil)
    }
    
    // MARK: - Back button
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
    
    @objc func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func infoButton() {
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        let infoButton = UIButton(type: .custom)
        infoButton.accessibilityIdentifier = "infoButton"
        infoButton.frame = CGRect(x: 0.0, y: 0.0,
                                    width: 30.0,
                                    height: 30.0)
        infoButton.imageView?.contentMode = .scaleAspectFill
        infoButton.layer.masksToBounds = true
        infoButton.addTarget(self,
                               action: #selector(infoButtonTapped),
                               for: UIControl.Event.touchUpInside)
        infoButton.setImage(UIImage(named: "ic-info"),
                              for: .normal)

        let rightBarButtonItem = UIBarButtonItem(customView: infoButton)
        rightBarButtonItem.accessibilityIdentifier = "infoBarButton"
        rightBarButtonItem.accessibilityLabel = LocalizationConstants.Workflows.info
        let currWidth = rightBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: 30.0)
        currWidth?.isActive = true
        let currHeight = rightBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: 30.0)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func infoButtonTapped() {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.taskDetail) as? TaskDetailViewController {
            viewController.coordinatorServices = coordinatorServices
            viewController.viewModel.task = viewModel.task
            viewController.viewModel.isOpenAfterTaskCreation = false
            viewController.viewModel.isEditTask = false
            viewController.viewModel.isComplexForm = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    private func showUploadingInQueueWarning(name: String, id: Int) {
        let title = LocalizationConstants.Workflows.warningTitle
        let message = LocalizationConstants.Workflows.attachmentInProgressWarning
    
        let confirmAction = MDCAlertAction(title: LocalizationConstants.Dialog.confirmTitle) { [weak self] _ in
            guard let sSelf = self else { return }
            sSelf.startWorkFlowAction(name: name, id: id)
        }
        confirmAction.accessibilityIdentifier = "confirmActionButton"
        
        let cancelAction = MDCAlertAction(title: LocalizationConstants.General.cancel) { _ in }
        cancelAction.accessibilityIdentifier = "cancelActionButton"

        _ = self.showDialog(title: title,
                                       message: message,
                                       actions: [confirmAction, cancelAction],
                                       completionHandler: {})
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
    
    // MARK: - Workflow details
    private func getWorkflowDetails() {
        if viewModel.isDetailWorkflow {
            viewModel.workflowTaskDetails { [weak self] error in
                guard let sSelf = self else { return }
                sSelf.tableView.reloadData()
                sSelf.controller.buildViewModel()
                sSelf.updateUI()
                sSelf.controller.checkRequiredTextField()
            }
        } else {
            viewModel.fetchProcessDefinition {[weak self] processDefinition, error in
                guard let sSelf = self else { return }
                sSelf.tableView.reloadData()
                sSelf.getFormFields()
            }
        }
    }
    
    private func getFormFields() {
        viewModel.getFormFields {[weak self] error in
            guard let sSelf = self else { return }
            sSelf.controller.buildViewModel()
            sSelf.updateUI()
            sSelf.controller.checkRequiredTextField()
        }
    }
    
    fileprivate func applyTheme() {
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme,
              let dialogButtonScheme = coordinatorServices?.themingService?.containerScheming(for: .dialogButton)
        else { return }
        
        saveButton.applyContainedTheme(withScheme: dialogButtonScheme)
        saveButton.isUppercaseTitle = false
        saveButton.layer.cornerRadius = UIConstants.cornerRadiusDialog
        saveButton.setShadowColor(.clear, for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
                
        completeButton.applyContainedTheme(withScheme: dialogButtonScheme)
        completeButton.isUppercaseTitle = false
        completeButton.layer.cornerRadius = UIConstants.cornerRadiusDialog
        completeButton.setShadowColor(.clear, for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        
        actionButton.mode = .expanded
        actionButton.isUppercaseTitle = false
        actionButton.applyContainedTheme(withScheme: dialogButtonScheme)
        actionButton.setTitle(LocalizationConstants.Workflows.actions, for: .normal)
        
        outcomeView.backgroundColor = currentTheme.surfaceColor
        saveButtonStackView.backgroundColor = currentTheme.surfaceColor
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
        
        viewModel.isEnabledButton.addObserver { [weak self] (isEnabled) in
            guard let sSelf = self else { return }
            if isEnabled {
                DispatchQueue.main.async {
                    sSelf.enableOutcome()
                }
            } else {
                DispatchQueue.main.async {
                    sSelf.disableOutcome()
                }
            }
        }
        
        /* observing rows */
        viewModel.rowViewModels.addObserver() { [weak self] (rows) in
            guard let sSelf = self else { return }
            DispatchQueue.main.async {
                sSelf.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Save Button Action
    @IBAction func saveButtonAction(_ sender: UIButton) {
        self.startWorkflowAPIIntegration(name: sender.titleLabel?.text ?? "", id: saveId)
    }
    
    // MARK: - Complete Button Action
    @IBAction func completeButtonAction(_ sender: UIButton) {
        self.startWorkflowAPIIntegration(name: completeString, id: completeId)
    }
    
    // MARK: - Action Button Action
    @IBAction func actionButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.actionlist) as? ActionListViewController {
            let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
            bottomSheet.dismissOnDraggingDownSheet = false
            viewController.coordinatorServices = coordinatorServices
            if var outcomes = viewModel.formData?.outcomes {
                if viewModel.isDetailWorkflow {
                    if let newOutcome = self.createOutcome() {
                        outcomes.insert(newOutcome, at: 0)
                    }
                }
                viewController.outcomes = outcomes
            }
            viewController.delegate = self
            self.present(bottomSheet, animated: true, completion: nil)
        }
       
    }
}

// MARK: - Outcomes
extension ComplexFormViewController {
    
    fileprivate func updateUI() {
        if viewModel.isDetailWorkflow {
            if viewModel.isShowDoneCompleteBtn {
                saveButton.isHidden = true
                completeButton.isHidden = true
            } else {
                detailOutcome()
            }
        } else {
            if let outcomes = viewModel.formData?.outcomes {
                switch outcomes.count {
                case 0:
                    noOutcome()
                case 1, 2:
                    oneTwoOutcome(outcomes: outcomes)
                case let count where count > 2:
                    multipleOutcome()
                default:
                    break
                }
                applyTheme()
            }
        }
    }
    
    fileprivate func startOutcome() {
        saveButton.isHidden = true
        completeButton.isHidden = true
        actionButton.isHidden = true
        disableOutcome()
    }
    
    fileprivate func noOutcome() {
        saveButton.isHidden = false
        saveButton.setTitle(LocalizationConstants.Accessibility.startWorkflow, for: .normal)
        saveButton.accessibilityLabel = LocalizationConstants.Accessibility.startWorkflow
        saveButton.accessibilityIdentifier = ""
    }
        
    fileprivate func oneTwoOutcome(outcomes: [Outcome]) {
        saveButton.isHidden = false
        if outcomes.count == 2 {
            completeButton.isHidden = false
            completeButton.setTitle(outcomes[1].name, for: .normal)
            completeButton.accessibilityLabel = outcomes[1].name
        }
        saveButton.setTitle(outcomes.first?.name, for: .normal)
        saveButton.accessibilityLabel = outcomes.first?.name
        saveButton.accessibilityIdentifier = ""
        completeButton.accessibilityIdentifier = ""
    }
    
    fileprivate func multipleOutcome() {
        saveButton.isHidden = true
        completeButton.isHidden = true
        actionButton.isHidden = false
    }
    
    fileprivate func enableOutcome() {
        saveButton.isEnabled = true
        saveButton.isUserInteractionEnabled = true
        
        completeButton.isEnabled = true
        completeButton.isUserInteractionEnabled = true
        
        actionButton.isEnabled = true
        actionButton.isUserInteractionEnabled = true
        
    }
    
    fileprivate func disableOutcome() {
        saveButton.isEnabled = false
        saveButton.isUserInteractionEnabled = false
        
        completeButton.isEnabled = false
        completeButton.isUserInteractionEnabled = false
        
        actionButton.isEnabled = false
        actionButton.isUserInteractionEnabled = false
    }
    
    fileprivate func detailOutcome() {
        if let outcomes = viewModel.formData?.outcomes {
            switch outcomes.count {
            case 0, 1:
                noDetailOutcome(outcomes: outcomes)
            case let count where count > 1:
                multipleOutcome()
            default:
                break
            }
            applyTheme()
        }
    }
    
    fileprivate func noDetailOutcome(outcomes: [Outcome]) {
        saveButton.isHidden = false
        saveButton.setTitle(LocalizationConstants.General.save, for: .normal)
        saveButton.accessibilityLabel = LocalizationConstants.General.save
        saveButton.accessibilityIdentifier = ""
        
        completeButton.isHidden = false
        completeButton.accessibilityIdentifier = ""
        
        if outcomes.isEmpty {
            completeButton.setTitle(LocalizationConstants.Workflows.complete, for: .normal)
            completeButton.accessibilityLabel = LocalizationConstants.Workflows.complete
        } else {
            let title = outcomes.first?.name
            completeButton.setTitle(title, for: .normal)
            completeButton.accessibilityLabel = title
        }
    }
    
    // Create Save Outcome
    fileprivate func createOutcome() -> Outcome? {
        // Example JSON data
        let jsonString = """
        {
            "id": \(saveId),
            "name": "\(LocalizationConstants.General.save)"
        }
        """
        
        // Initialize JSONDecoder
        let decoder = JSONDecoder()
        
        // Convert JSON string to Data
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }

        do {
            // Decode Outcome from JSON data
            let outcome = try decoder.decode(Outcome.self, from: jsonData)
            return outcome
        } catch {
            return nil
        }
    }
}

// MARK: - Table View Data Source and Delegates
extension ComplexFormViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.rowViewModels.value.count
    }
    
    fileprivate func configureDatePickerCells(_ localViewModel: DatePickerTableViewCellViewModel, _ cell: UITableViewCell, _ indexPath: IndexPath) {
        var datePicker = UIDatePicker()
        if localViewModel.type.rawValue == ComplexFormFieldType.dateTime.rawValue {
            datePicker.datePickerMode = .dateAndTime
        } else {
            datePicker.datePickerMode = .date
        }
        datePicker.tag = indexPath.row
        self.datePickerConfiguration(datePicker: datePicker, rowViewModel: localViewModel)
        self.setDatesForDatePicker(rowViewModel: localViewModel, datePicker: &datePicker)
        (cell as? DatePickerTableViewCell)?.textField.inputView = datePicker
        (cell as? DatePickerTableViewCell)?.textField.text = localViewModel.text
        let toolBar = getToolBar(tag: indexPath.row, for: datePicker)
        (cell as? DatePickerTableViewCell)?.textField.inputAccessoryView = toolBar
    }
    
    fileprivate func datePickerConfiguration(datePicker: UIDatePicker, rowViewModel: RowViewModel) {
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        datePicker.preferredDatePickerStyle = .inline
        datePicker.backgroundColor = currentTheme.surfaceColor
        datePicker.frame = CGRect(x: 0, y: 0, width: UIConstants.ScreenWidth, height: UIConstants.ScreenHeight/2.0 + 100)
        guard let rowViewModel = rowViewModel as? DatePickerTableViewCellViewModel else { return }
    }
    
    fileprivate func configureAssignUserCells(_ localViewModel: AssigneeTableViewCellViewModel, _ cell: UITableViewCell, _ indexPath: IndexPath) {
        (cell as? AssigneeTableViewCell)?.addUserButton.tag = indexPath.row
        (cell as? AssigneeTableViewCell)?.addUserButton.addTarget(self, action: #selector(addAssigneeAction(sender:)), for: .touchUpInside)
    }
    
    fileprivate func configureDropDownCells(_ localViewModel: DropDownTableViewCellViewModel, _ cell: UITableViewCell, _ indexPath: IndexPath) {
        (cell as? DropDownTableViewCell)?.textField.tag = indexPath.row
        (cell as? DropDownTableViewCell)?.textField.delegate = self
    }
    
    fileprivate func configureHyperlinkCells(_ localViewModel: HyperlinkTableViewCellViewModel, _ cell: UITableViewCell, _ indexPath: IndexPath) {
        (cell as? HyperlinkTableViewCell)?.hyperlinkButton.tag = indexPath.row
        (cell as? HyperlinkTableViewCell)?.hyperlinkButton.addTarget(self, action: #selector(hyperlinkButtonAction(button:)), for: .touchUpInside)
    }
    
    fileprivate func configureCheckBoxCells(_ localViewModel: CheckBoxTableViewCellViewModel, _ cell: UITableViewCell, _ indexPath: IndexPath) {
        (cell as? CheckBoxTableViewCell)?.selectionButton.tag = indexPath.row
        (cell as? CheckBoxTableViewCell)?.selectionButton.addTarget(self, action: #selector(checkBoxButtonAction(button:)), for: .touchUpInside)
        (cell as? CheckBoxTableViewCell)?.viewAllButton.tag = indexPath.row
        (cell as? CheckBoxTableViewCell)?.viewAllButton.addTarget(self, action: #selector(viewAllButtonAction(button:)), for: .touchUpInside)
    }
    
    fileprivate func configureAttachmentCells(_ localViewModel: AddAttachmentComplexTableViewCellViewModel, _ cell: UITableViewCell, _ indexPath: IndexPath) {

            let attachCell = cell as? AddAttachmentComplexTableViewCell
            attachCell?.attachmentButton.tag = indexPath.row
            attachCell?.attachmentButton.addTarget(self, action: localViewModel.isFolder ?  #selector(attachmentFolderButtonAction(button:)): #selector(attachmentButtonAction(button:)), for: .touchUpInside)
        }
        
    fileprivate func configureDisplayCells(_ localViewModel: SingleLineTextTableCellViewModel, _ cell: UITableViewCell, _ indexPath: IndexPath) {
        
        (cell as?  SingleLineTextTableViewCell)?.selectButton.tag = indexPath.row
        (cell as?  SingleLineTextTableViewCell)?.selectButton.addTarget(self, action: #selector(viewAllAttachments(button:)), for: .touchUpInside)
    }
    
    fileprivate func applyTheme(_ cell: UITableViewCell) {
        if let themeCell = cell as? CellThemeApplier, let theme = coordinatorServices?.themingService {
            themeCell.applyCellTheme(with: theme)
        }
    }
    
    fileprivate func configureCells(_ cell: UITableViewCell, _ rowViewModel: RowViewModel, _ indexPath: IndexPath) {
        if cell is DatePickerTableViewCell, let localViewModel = rowViewModel as? DatePickerTableViewCellViewModel {
            configureDatePickerCells(localViewModel, cell, indexPath)
        } else if cell is AssigneeTableViewCell, let localViewModel = rowViewModel as? AssigneeTableViewCellViewModel {
            configureAssignUserCells(localViewModel, cell, indexPath)
        } else if cell is DropDownTableViewCell, let localViewModel = rowViewModel as? DropDownTableViewCellViewModel {
            configureDropDownCells(localViewModel, cell, indexPath)
        } else if cell is HyperlinkTableViewCell, let localViewModel = rowViewModel as? HyperlinkTableViewCellViewModel {
            configureHyperlinkCells(localViewModel, cell, indexPath)
        } else if cell is CheckBoxTableViewCell, let localViewModel = rowViewModel as? CheckBoxTableViewCellViewModel {
            configureCheckBoxCells(localViewModel, cell, indexPath)
        } else if cell is AddAttachmentComplexTableViewCell, let localViewModel = rowViewModel as? AddAttachmentComplexTableViewCellViewModel {
            configureAttachmentCells(localViewModel, cell, indexPath)
        } else if cell is SingleLineTextTableViewCell, let localViewModel = rowViewModel as? SingleLineTextTableCellViewModel {
            configureDisplayCells(localViewModel, cell, indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowViewModel = viewModel.rowViewModels.value[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: controller.cellIdentifier(for: rowViewModel), for: indexPath)
        if let cell = cell as? CellConfigurable {
            cell.setup(viewModel: rowViewModel)
        }
        configureCells(cell, rowViewModel, indexPath)
        applyTheme(cell)
        cell.layoutIfNeeded()
        return cell
    }
    
    private func assignUserCellHeight(rowViewModel: RowViewModel?) -> CGFloat {
        if let localViewModel = rowViewModel as? AssigneeTableViewCellViewModel {
            return localViewModel.userName?.count ?? 0 > 0 ? 100 : 50.0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowViewModel = viewModel.rowViewModels.value[indexPath.row]
        switch rowViewModel {
        case is MultiLineTextTableCellViewModel:
            return 120.0
        case is SingleLineTextTableCellViewModel:
            return 100.0
        case is DatePickerTableViewCellViewModel:
            return 100.0
        case is DropDownTableViewCellViewModel:
            return 100.0
        case is AssigneeTableViewCellViewModel:
            return assignUserCellHeight(rowViewModel: rowViewModel)
        case is HyperlinkTableViewCellViewModel:
            return 100
        case is AddAttachmentComplexTableViewCellViewModel:
            return 80
        default:
            return UITableView.automaticDimension
        }
    }
    
    func reloadTableView(row: Int) {
        let indexPath = IndexPath(item: row, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
// MARK: - Date Picker
extension ComplexFormViewController {
    
    private func setDatesForDatePicker(rowViewModel: RowViewModel, datePicker: inout UIDatePicker) {
        
        guard let rowViewModel = rowViewModel as? DatePickerTableViewCellViewModel else { return }
        
        let minDateStr = rowViewModel.minValue ?? ""
        let maxDateStr = rowViewModel.maxValue ?? ""
        
        var minimumDate: Date?
        var maximumDate: Date?
        let date = Date()
        if rowViewModel.type.rawValue == ComplexFormFieldType.dateTime.rawValue {
            minimumDate = complexFormViewModel.convertStringToDateTime(dateStr: minDateStr)
            maximumDate = complexFormViewModel.convertStringToDateTime(dateStr: maxDateStr)
        } else {
            minimumDate = complexFormViewModel.convertStringToDate(dateStr: minDateStr)
            maximumDate = complexFormViewModel.convertStringToDate(dateStr: maxDateStr)
        }
        
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
        let text = rowViewModel.text ?? ""
        if !text.isEmpty {
            let type = rowViewModel.type
            // Create a date formatter for your custom date
            let dateFormatter = DateFormatter()
            if type == .date {
                dateFormatter.dateFormat = "dd-MM-yyyy"
            } else {
                dateFormatter.dateFormat = "dd-MMM-yyyy hh:mm a"
            }
            datePicker.timeZone = TimeZone.current
            // Convert your custom date string to a Date object
            if let customDate = dateFormatter.date(from: text) {
                // Set the UIDatePicker's initial date
                datePicker.setDate(customDate, animated: true)
            } else {
                datePicker.date = date
            }
        } else {
            datePicker.date = date
        }
        
    }
        
    func getToolBar(tag: Int, for datePicker: UIDatePicker) -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIConstants.ScreenWidth, height: 44.0))
        let cancelButton = UIBarButtonItem(title: LocalizationConstants.General.cancel, style: .plain, target: self, action: #selector(self.dismissToolBar))
        let doneButton = UIBarButtonItem(title: LocalizationConstants.General.done, style: .done, target: self, action: #selector(self.handleDatePicker))
        doneButton.tag = tag
        doneButton.accessibilityIdentifier = "DoneButton"
        cancelButton.accessibilityIdentifier = "CancelButton"
        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, flexibleButton, doneButton], animated: false)
        return toolBar
    }
    
    @objc func dismissToolBar() {
        self.view.endEditing(true)
    }
    
    @objc func handleDatePicker(sender: UIBarButtonItem) {
        let rowViewModel = viewModel.rowViewModels.value[sender.tag]
        guard let localViewModel = rowViewModel as? DatePickerTableViewCellViewModel else { return }
        let dateFormatter = complexFormViewModel.isoDateFormat()
        
        let cellIndex = sender.tag
        guard let cell = tableView.cellForRow(at: IndexPath(row: cellIndex, section: 0)) as? DatePickerTableViewCell else { return }
        let datePicker = cell.textField.inputView as? UIDatePicker
        guard let selectedDate = datePicker?.date else { return }
        
        var formattedDate = ""
        if localViewModel.type.rawValue == ComplexFormFieldType.dateTime.rawValue {
             formattedDate = complexFormViewModel.selectedDateTimeString(for: selectedDate)
        } else {
             formattedDate = complexFormViewModel.selectedDateString(for: selectedDate)
        }
        let dateString = dateFormatter.string(from: selectedDate)
        localViewModel.didChangeText?(dateString)
        
        localViewModel.text = formattedDate
        cell.textField.text = formattedDate
        
        // Dismiss the keyboard
        view.endEditing(true)
    }
}

// MARK: - Drop Down
extension ComplexFormViewController {
    func showDropDown(tag: Int, rowViewModel: RowViewModel) {
        guard let rowViewModel = rowViewModel as? DropDownTableViewCellViewModel else { return }
        let viewController = SearchListComponentViewController.instantiateViewController()
        let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.dismissOnDraggingDownSheet = false
        viewController.coordinatorServices = coordinatorServices
        viewController.listViewModel.isRadioList = true
        viewController.listViewModel.isComplexFormsFlow = true
        viewController.listViewModel.taskChip = rowViewModel.taskChip
        viewController.taskFilterCallBack = { [weak self] (selectedChip, isBackButtonTapped) in
            if isBackButtonTapped == false {
                if let localSelectedChip = selectedChip {
                    guard let sSelf = self else { return }
                    if let selectedValue = localSelectedChip.selectedValue {
                        rowViewModel.text = selectedValue
                        rowViewModel.didChangeChip?(localSelectedChip)
                    }
                    sSelf.reloadTableView(row: tag)
                }
            }
        }
        self.present(bottomSheet, animated: true, completion: nil)
    }
}

// MARK: - Textfield Delegate
extension ComplexFormViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let rowViewModel = viewModel.rowViewModels.value[textField.tag]
        if let rowViewModel = rowViewModel as? DropDownTableViewCellViewModel {
            textField.resignFirstResponder()
            showDropDown(tag: textField.tag, rowViewModel: rowViewModel)
        }
    }
}

// MARK: - Add Assignee
extension ComplexFormViewController {
    
    @objc func addAssigneeAction(sender: UIButton) {
        let rowViewModel = viewModel.rowViewModels.value[sender.tag]
        guard let localViewModel = rowViewModel as? AssigneeTableViewCellViewModel else { return }
        
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.taskAssignee) as? TaskAssigneeViewController {
            viewController.coordinatorServices = coordinatorServices
            viewController.viewModel.isWorkflowSearch = true
            if localViewModel.type.rawValue == ComplexFormFieldType.group.rawValue {
                viewController.viewModel.isSearchByName = false
            }
            let navigationController = UINavigationController(rootViewController: viewController)
            self.present(navigationController, animated: true)
            viewController.callBack = { [weak self] (assignee) in
                guard let sSelf = self else { return }
                if localViewModel.type.rawValue == ComplexFormFieldType.group.rawValue {
                    sSelf.updateGroup(with: assignee, tag: sender.tag, localViewModel: localViewModel)
                } else {
                    sSelf.updateAssignee(with: assignee, tag: sender.tag, localViewModel: localViewModel)
                }
            }
        }
    }
    private func updateAssignee(with assignee: TaskNodeAssignee, tag: Int, localViewModel: AssigneeTableViewCellViewModel) {
        var userName = ""
        if let apsUserID = UserProfile.apsUserID {
            if assignee.assigneeID == apsUserID {
                let name = LocalizationConstants.EditTask.meTitle
                userName = name
            } else {
                if let groupName = assignee.groupName, !groupName.isEmpty {
                    userName = groupName
                } else {
                    userName = assignee.userName ?? ""
                }
            }
        }
        localViewModel.userName = userName
        localViewModel.didChangeAssignee?(assignee)
        reloadTableView(row: tag)
    }
    private func updateGroup(with assignee: TaskNodeAssignee, tag: Int, localViewModel: AssigneeTableViewCellViewModel) {
        var localGroupName = ""
        if let groupName = assignee.groupName, !groupName.isEmpty {
            localGroupName = groupName
        }
        localViewModel.userName = localGroupName
        localViewModel.didChangeAssignee?(assignee)
        reloadTableView(row: tag)
    }
}

// MARK: - Hyperlink
extension ComplexFormViewController {
    
    @objc func hyperlinkButtonAction(button: UIButton) {
        let rowViewModel = viewModel.rowViewModels.value[button.tag]
        guard let localViewModel = rowViewModel as? HyperlinkTableViewCellViewModel else { return }
        let urlSting = localViewModel.hyperlinkUrl ?? ""
        openFilePreviewController(notificationURL: urlSting)
    }
    
    private func openFilePreviewController(notificationURL: String) {
        let topMostViewController = UIApplication.shared.topMostViewController()
        if topMostViewController is MDCAlertController {
            topMostViewController?.dismiss(animated: true, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.openFilePreviewController(notificationURL: notificationURL)
                }
            })
        }
        
        guard let node = listNodeForPreview(guid: "0",
                                            title: LocalizationConstants.ScreenTitles.previewCaptureAsset),
              let navigationController = topMostViewController?.navigationController else { return }
        
        let viewControllers = navigationController.viewControllers
        for index in 0 ..< viewControllers.count {
            let controller = viewControllers[index]
            if controller is FilePreviewViewController {
                navigationController.viewControllers.remove(at: index)
                break
            }
        }
        
        let coordinator = FilePreviewScreenCoordinator(with: navigationController,
                                                       listNode: node,
                                                       excludedActions: [.moveTrash,
                                                                         .addFavorite,
                                                                         .removeFavorite],
                                                       shouldPreviewLatestContent: false,
                                                       publicPreviewURL: notificationURL)
        coordinator.start()
        self.filePreviewCoordinator = coordinator
    }
    
    private func listNodeForPreview(guid: String?,
                                    nodeType: NodeType = .file,
                                    syncStatus: SyncStatus = .pending,
                                    title: String? = nil) -> ListNode? {
        return ListNode(guid: guid ?? "",
                        title: title ?? "",
                        path: "",
                        nodeType: nodeType,
                        syncStatus: syncStatus)
    }
}
// MARK: - CheckBox
extension ComplexFormViewController {
    
    @objc func attachmentButtonAction(button: UIButton) {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.taskAttachments) as? TaskAttachmentsViewController {
            let rowViewModel = viewModel.rowViewModels.value[button.tag]
            guard let localViewModel = rowViewModel as? AddAttachmentComplexTableViewCellViewModel else { return }
            viewController.coordinatorServices = coordinatorServices
            viewController.viewModel.attachmentType = .workflow
            let fieldId = viewModel.tempWorkflowId + (localViewModel.field?.id ?? "")
            if localViewModel.tempWorkflowId.isEmpty {
                localViewModel.tempWorkflowId = fieldId
            }
            if viewModel.isDetailWorkflow {
                if localViewModel.isComplexFirstTime {
                    for attachment in localViewModel.attachments {
                        attachment.parentGuid = fieldId
                    }
                    viewModel.workflowOperationsModel?.attachments.value = localViewModel.attachments
                    localViewModel.isComplexFirstTime = false
                }
                viewController.viewModel.isDetailWorkflow = viewModel.isDetailWorkflow
            }
            viewController.viewModel.tempWorkflowId = fieldId
            viewModel.workflowOperationsModel?.tempWorkflowId = fieldId
            viewController.viewModel.processDefintionTitle = viewModel.processDefintionTitle
            viewController.multiSelection = localViewModel.multiSelection
            viewController.viewModel.workflowOperationsModel = viewModel.workflowOperationsModel
            viewController.viewModel.workflowOperationsModel?.attachments.addObserver { [weak self] (attachments) in
                guard let sSelf = self else { return }
                sSelf.receivedAttachment(tag: button.tag, attachments: attachments, rowViewModel: localViewModel)
            }
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func receivedAttachment(tag: Int, attachments: [ListNode], rowViewModel: AddAttachmentComplexTableViewCellViewModel) {
        
        var guidStr = ""
        var localAttachments = [ListNode]()
        
        for attachment in attachments where rowViewModel.tempWorkflowId == attachment.parentGuid {
            localAttachments.append(attachment)
            guidStr.isEmpty ? (guidStr = attachment.guid) : (guidStr += ",\(attachment.guid)")
        }

        rowViewModel.attachments = localAttachments
        rowViewModel.didChangeText?(guidStr)
        reloadTableView(row: tag)
        
    }
    
    @objc func attachmentFolderButtonAction(button: UIButton) {
        let rowViewModel = viewModel.rowViewModels.value[button.tag]
        guard let localViewModel = rowViewModel as? AddAttachmentComplexTableViewCellViewModel else { return }
        appDelegate()?.isAPSAttachmentFlow = true
        let controller = FilesandFolderListViewController.instantiateViewController()
        controller.sourceNodeToMove = [ListNode]()
        let navController = UINavigationController(rootViewController: controller)
        self.navigationController?.present(navController, animated: true)
        filesAndFolderViewController = controller
        filesAndFolderViewController?.didSelectDismissAction = {[weak self] folderId, folderName in
            guard let sSelf = self else { return }
            if let folderIdVal = folderId, !folderIdVal.isEmpty {
                localViewModel.folderId = folderIdVal
                localViewModel.folderName = folderName ?? ""
                
                localViewModel.didChangeText?(folderIdVal)
                sSelf.reloadTableView(row: button.tag)
            }
        }
    }

    @objc func checkBoxButtonAction(button: UIButton) {
        let rowViewModel = viewModel.rowViewModels.value[button.tag]
        guard let localViewModel = rowViewModel as? CheckBoxTableViewCellViewModel else { return }
        let isSelected = !localViewModel.isSelected
        localViewModel.isSelected = isSelected
        localViewModel.didChangeValue?(isSelected)
        reloadTableView(row: button.tag)
    }
    
    @objc func viewAllButtonAction(button: UIButton) {
        let rowViewModel = viewModel.rowViewModels.value[button.tag]
        guard let localViewModel = rowViewModel as? CheckBoxTableViewCellViewModel else { return }
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.taskDescription) as? TaskDescriptionDetailViewController {
            viewController.coordinatorServices = coordinatorServices
            viewController.viewModel.appDefinition = localViewModel.appDefinition
            let navigationController = UINavigationController(rootViewController: viewController)
            self.present(navigationController, animated: true)
        }
    }
    
    @objc func viewAllAttachments(button: UIButton) {
        let rowViewModel = viewModel.rowViewModels.value[button.tag]
        guard let localViewModel = rowViewModel as? SingleLineTextTableCellViewModel else { return }
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: StoryboardConstants.controller.taskAttachments) as? TaskAttachmentsViewController {
            viewController.coordinatorServices = coordinatorServices
            viewController.viewModel.isWorkflowTaskAttachments = true
            viewController.viewModel.attachments = Observable<[ListNode]>(localViewModel.attachments)
            viewController.viewModel.task = viewModel.task
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

}

extension ComplexFormViewController: ActionListViewControllerDelegate {
    func actionListViewController(_ viewController: ActionListViewController, didSelectItem selectedItem: AlfrescoContent.Outcome) {
        let name = selectedItem.name
        let id = selectedItem.id ?? 0
        startWorkflowAPIIntegration(name: name, id: id)
    }
}
