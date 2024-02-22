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
    lazy var complexFormViewModel = ComplexFormViewModel()
    
    var viewModel: StartWorkflowViewModel { return controller.viewModel }
    lazy var controller: ComplexFormController = { return ComplexFormController( currentTheme: coordinatorServices?.themingService?.activeTheme) }()
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
        registerCells()
        setupBindings()
        applyLocalization()
        getWorkflowDetails()
        AnalyticsManager.shared.pageViewEvent(for: Event.Page.startWorkflowScreen)
        self.dialogTransitionController = MDCDialogTransitionController()

        if !viewModel.isDetailWorkflow {
            ProfileService.getAPSSource() // to get APS Source
        }
        
        // ReSignIn Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleReSignIn(notification:)),
                                               name: Notification.Name(KeyConstants.Notification.reSignin),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
       
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

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
        if viewModel.isDetailWorkflow { return }
        viewModel.fetchProcessDefinition {[weak self] processDefinition, error in
            guard let sSelf = self else { return }
            sSelf.tableView.reloadData()
            sSelf.getFormFields()
        }
    }
    
    private func getFormFields() {
        viewModel.getFormFields {[weak self] error in
            guard let sSelf = self else { return }
            sSelf.controller.buildViewModel()
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
    }
}

// MARK: - Table View Data Source and Delegates
extension ComplexFormViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.rowViewModels.value.count
    }
    
    fileprivate func configureDatePickerCells(_ localViewModel: DatePickerTableViewCellViewModel, _ cell: UITableViewCell, _ indexPath: IndexPath) {
        (cell as? DatePickerTableViewCell)?.textField.tag = indexPath.row
        if localViewModel.type.rawValue == ComplexFormFieldType.dateTime.rawValue {
            complexFormViewModel.selectedDateTimeTextField = (cell as? DatePickerTableViewCell)?.textField
            complexFormViewModel.selectedDateTimeTextField.delegate = self
        } else {
            complexFormViewModel.selectedDateTextField = (cell as? DatePickerTableViewCell)?.textField
            complexFormViewModel.selectedDateTextField.delegate = self
        }
    }
    
    fileprivate func configureAssignUserCells(_ localViewModel: AssigneeTableViewCellViewModel, _ cell: UITableViewCell, _ indexPath: IndexPath) {
        if localViewModel.type.rawValue == ComplexFormFieldType.people.rawValue {
            (cell as? AssigneeTableViewCell)?.viewModel?.userName = complexFormViewModel.userName
        } else {
            (cell as? AssigneeTableViewCell)?.viewModel?.userName = complexFormViewModel.groupName
        }
        (cell as? AssigneeTableViewCell)?.addUserButton.tag = indexPath.row
        (cell as? AssigneeTableViewCell)?.addUserButton.addTarget(self, action: #selector(addAssigneeAction(sender:)), for: .touchUpInside)
    }
    
    fileprivate func configureDropDownCells(_ localViewModel: DropDownTableViewCellViewModel, _ cell: UITableViewCell, _ indexPath: IndexPath) {
        (cell as? DropDownTableViewCell)?.textField.tag = indexPath.row
        (cell as? DropDownTableViewCell)?.textField.delegate = self
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
            if localViewModel.type.rawValue == ComplexFormFieldType.people.rawValue {
                return complexFormViewModel.userName?.count ?? 0 > 0 ? 100 : 50.0
            } else {
                return complexFormViewModel.groupName?.count ?? 0 > 0 ? 100 : 50.0
            }
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
        default:
            return UITableView.automaticDimension
        }
    }
}
// MARK: - Date Picker
extension ComplexFormViewController {
    func showDatePicker(tag: Int, rowViewModel: RowViewModel) {
        var datePicker = UIDatePicker()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        guard let rowViewModel = rowViewModel as? DatePickerTableViewCellViewModel else { return }
        if rowViewModel.type.rawValue == ComplexFormFieldType.dateTime.rawValue {
            datePicker.datePickerMode = .dateAndTime
            complexFormViewModel.selectedDateTimeTextField.inputView = datePicker
            complexFormViewModel.selectedDateTimeTextField.inputAccessoryView = getToolBar(tag: tag)
        } else {
            datePicker.datePickerMode = .date
            complexFormViewModel.selectedDateTextField.inputView = datePicker
            complexFormViewModel.selectedDateTextField.inputAccessoryView = getToolBar(tag: tag)
        }
        
        datePicker.preferredDatePickerStyle = .inline
        datePicker.backgroundColor = currentTheme.surfaceColor
        setDatesForDatePicker(rowViewModel: rowViewModel, datePicker: &datePicker)
        
        datePicker.frame = CGRect(x: 0, y: 0, width: UIConstants.ScreenWidth, height: UIConstants.ScreenHeight/2.0)
    }
    
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
        datePicker.date = date
    }
    
    func getToolBar(tag: Int) -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIConstants.ScreenWidth, height: 44.0))
        let cancelButton = UIBarButtonItem(title: LocalizationConstants.General.cancel, style: .plain, target: self, action: #selector(self.dismissToolBar))
        let doneButton = UIBarButtonItem(title: LocalizationConstants.General.done, style: .done, target: self, action: #selector(self.handleDatePicker))
        doneButton.tag = tag
        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, flexibleButton, doneButton], animated: false)
        return toolBar
    }
    
    @objc func dismissToolBar() {
        self.view.endEditing(true)
    }
    
    @objc func handleDatePicker(sender: UIButton) {
        let rowViewModel = viewModel.rowViewModels.value[sender.tag]
        guard let localViewModel = rowViewModel as? DatePickerTableViewCellViewModel else { return }
        
        if localViewModel.type.rawValue == ComplexFormFieldType.dateTime.rawValue {
            if let dateTimePicker = complexFormViewModel.selectedDateTimeTextField.inputView as? UIDatePicker {
                // Use DateFormatter to format the date and time
                let date = complexFormViewModel.selectedDateTimeString(for: dateTimePicker.date)
                complexFormViewModel.selectedDateTimeTextField.text = date
            }
        } else {
            if let dateTimePicker = complexFormViewModel.selectedDateTextField.inputView as? UIDatePicker {
                let date = complexFormViewModel.selectedDateString(for: dateTimePicker.date)
                complexFormViewModel.selectedDateTextField.text = date
            }
        }
        
        self.view.endEditing(true)
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
        viewController.taskFilterCallBack = { (selectedChip, isBackButtonTapped) in
            if isBackButtonTapped == false {
                if let localSelectedChip = selectedChip {
                    rowViewModel.text = localSelectedChip.selectedValue ?? ""
                    self.tableView .reloadData()
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
        if let rowViewModel = rowViewModel as? DatePickerTableViewCellViewModel {
            showDatePicker(tag: textField.tag, rowViewModel: rowViewModel)
        } else if let rowViewModel = rowViewModel as? DropDownTableViewCellViewModel {
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
                    sSelf.updateGroup(with: assignee)
                } else {
                    sSelf.updateAssignee(with: assignee)
                }
            }
        }
    }
    private func updateAssignee(with assignee: TaskNodeAssignee) {
        if let apsUserID = UserProfile.apsUserID {
            if assignee.assigneeID == apsUserID {
                let name = LocalizationConstants.EditTask.meTitle
                complexFormViewModel.userName = name
            } else {
                if let groupName = assignee.groupName, !groupName.isEmpty {
                    complexFormViewModel.userName = groupName
                } else {
                    complexFormViewModel.userName = assignee.userName
                }
            }
        }
        tableView .reloadData()
    }
    private func updateGroup(with assignee: TaskNodeAssignee) {
        if let groupName = assignee.groupName, !groupName.isEmpty {
            complexFormViewModel.groupName = groupName
        }
        tableView .reloadData()
    }
}
