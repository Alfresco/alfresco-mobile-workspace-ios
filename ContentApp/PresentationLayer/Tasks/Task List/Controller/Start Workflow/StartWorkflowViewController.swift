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
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationItem.setHidesBackButton(true, animated: true)
        addBackButton()
        progressView.progress = 0
        progressView.mode = .indeterminate
        applyTheme()
        applyLocalization()
        registerCells()
        addAccessibility()
        controller.buildViewModel()
        setupBindings()
     //   getWorkflowDetails()
        AnalyticsManager.shared.pageViewEvent(for: Event.Page.startWorkflowScreen)
        self.dialogTransitionController = MDCDialogTransitionController()
     //   updateCompleteTaskUI()

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
        self.title = LocalizationConstants.Accessibility.startWorkflow
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
        // getTaskDetails()
    }
    
    @IBAction func startWorkflowButtonAction(_ sender: Any) {
        AlfrescoLog.debug("start workflow button action")
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
          //  self.showTaskDescription()
        }
        
        /* observing edit title */
        controller.didSelectEditTitle = {
           // self.editTitleAndDescriptionAction()
        }
        
        /* observing edit due date */
        controller.didSelectEditDueDate = {
          //  self.editDueDateAction()
        }
        
        /* observing reset due date */
        controller.didSelectResetDueDate = {
          //  self.resetDueDateAction()
        }
        
        /* observing priority */
        controller.didSelectPriority = {
          //  self.changePriorityAction()
        }
        
        /* observing assignee */
        controller.didSelectAssignee = {
          //  self.changeAssigneeAction()
        }
        
        /* observer did select add attachment */
        controller.didSelectAddAttachment = {
          //  self.addAttachmentButtonAction()
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
