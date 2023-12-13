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

class ComplexFormViewController: SystemSearchViewController {
   
    @IBOutlet weak var progressView: MDCProgressView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var pageIndicatorView: UIView!
    @IBOutlet weak var previousPageButton: MDCButton!
    @IBOutlet weak var nextPageButton: MDCButton!
    @IBOutlet weak var labelPageNumber: UILabel!
    @IBOutlet weak var heightFooterView: NSLayoutConstraint!
    
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
        applyTheme()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        updateTheme()
        //controller.buildViewModel()
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
    
    @objc private func handleReSignIn(notification: Notification) {
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
    func applyTheme() {
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme,
              let buttonScheme = coordinatorServices?.themingService?.containerScheming(for: .dialogButton)
        else { return }
    }
    
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
           // sSelf.tableView.reloadData()
            sSelf.getFormFields()
        }
    }
    
    private func getFormFields() {
        viewModel.getFormFields {[weak self] error in
            guard let sSelf = self else { return }
         //   sSelf.controller.buildViewModel()
        }
    }
}
