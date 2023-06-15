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

class WorkflowTaskStatusViewController: SystemSearchViewController {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dropDownImageView: UIImageView!
    @IBOutlet weak var commentField: MDCOutlinedTextArea!
    @IBOutlet weak var progressView: MDCProgressView!
    @IBOutlet weak var selectStatusButton: UIButton!
    
    var saveButton = UIButton(type: .custom)
    let maxLengthForComments = 200
    var viewModel: WorkflowTaskStatusViewModel { return controller.viewModel }
    lazy var controller: WorkflowTaskStatusController = { return WorkflowTaskStatusController( currentTheme: coordinatorServices?.themingService?.activeTheme) }()

    // MARK: - View Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.services = coordinatorServices ?? CoordinatorServices()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationItem.setHidesBackButton(true, animated: true)
        progressView.progress = 0
        progressView.mode = .indeterminate
        applyLocalization()
        addBackButton()
        addSaveButton()
        addTextView()
        setupBindings()
        setupData()
        AnalyticsManager.shared.pageViewEvent(for: Event.Page.workflowTaskStatusScreen)
    }
    
    private func setupData() {
        saveButton.isHidden = viewModel.isTaskCompleted
        selectStatusButton.isUserInteractionEnabled = !viewModel.isTaskCompleted
        commentField.isUserInteractionEnabled = !viewModel.isTaskCompleted
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.isHidden = false
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    private func applyLocalization() {
        self.title = LocalizationConstants.Tasks.status
        statusLabel.text = NSLocalizedString(viewModel.statusTitle ?? "", comment: "")
        commentField.textView.text = viewModel.comment
        commentField.textView.delegate = self
    }
    
    private func addTextView() {
        DispatchQueue.main.async {
            self.commentField.minimumNumberOfVisibleRows = 1
            self.commentField.maximumNumberOfVisibleRows = 7
            self.commentField.textView.accessibilityIdentifier = "commentTextField"
        }
    }
    
    // MARK: - Public Helpers
    
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme, let theme = CameraKit.theme else { return }

        progressView.progressTintColor = currentTheme.primaryT1Color
        progressView.trackTintColor = currentTheme.primary30T1Color

        statusLabel.applyStyleBody1OnSurface(theme: currentTheme)
        dropDownImageView.tintColor = currentTheme.onSurfaceColor
        view.backgroundColor = currentTheme.surfaceColor
        
        saveButton.setTitleColor(currentTheme.primaryT1Color, for: .normal)
        saveButton.titleLabel?.font = currentTheme.buttonTextStyle.font
        
        commentField.label.text = LocalizationConstants.Accessibility.commentTitle
        commentField.applyTheme(withScheme: theme.textFieldScheme)
    }
    
    // MARK: - Back Button
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
    
    // MARK: - Save Button
    private func addSaveButton() {
        saveButton.accessibilityIdentifier = "save-button"
        saveButton.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 30.0)
        saveButton.addTarget(self,
                               action: #selector(saveButtonAction),
                               for: UIControl.Event.touchUpInside)
        saveButton.setTitle(LocalizationConstants.General.save, for: .normal)
        saveButton.titleLabel?.numberOfLines = 1
        saveButton.titleLabel?.adjustsFontSizeToFitWidth = true
        saveButton.titleLabel?.lineBreakMode = .byClipping
    
        let searchBarButtonItem = UIBarButtonItem(customView: saveButton)
        searchBarButtonItem.accessibilityIdentifier = "savebarButton"
        let currHeight = searchBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: 30.0)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = searchBarButtonItem
    }

    @objc func saveButtonAction() {
        self.view.endEditing(true)
        selectStatusButton.isUserInteractionEnabled = false
        commentField.isUserInteractionEnabled = false
        let name = viewModel.selectedWorkflowStatusOption?.name ?? ""
        let optionId = viewModel.selectedWorkflowStatusOption?.optionId ?? ""

        if let index = viewModel.workflowStatusOptions.firstIndex(where: {($0.name == name && $0.id == optionId)}) {
            let status = viewModel.workflowStatusOptions[index]
            let comment = commentField.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            viewModel.saveStatusAndComment(status: status, comment: comment) { [weak self] error in
                guard let sSelf = self else { return }
                sSelf.selectStatusButton.isUserInteractionEnabled = true
                sSelf.commentField.isUserInteractionEnabled = true
                sSelf.viewModel.didSaveStatusAndComment?(status, comment)
                sSelf.backButtonAction()
            }
        } else {
            Snackbar.display(with: LocalizationConstants.Workflows.selectStatusMessage, type: .error, finish: nil)
        }
    }
    
    // MARK: - Loader
    
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
    }
    
    // MARK: - Select status button action
    
    @IBAction func selectStatusButtonAction(_ sender: Any) {
        let viewController = RadioListViewController.instantiateViewController()
        let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.dismissOnDraggingDownSheet = false
        viewController.coordinatorServices = coordinatorServices
        viewController.viewModel.isRadioList = true
        viewController.viewModel.title = LocalizationConstants.Tasks.status
        viewController.viewModel.radioListOptions = viewModel.getStatusOptions()
        viewController.viewModel.selectedRadioListOption = viewModel.selectedWorkflowStatusOption
        viewController.viewModel.didSelectListItem = {[weak self] (option) in
            guard let sSelf = self else { return }
            sSelf.viewModel.selectedWorkflowStatusOption = option
            sSelf.applyLocalization()
        }
        self.navigationController?.present(bottomSheet, animated: true, completion: nil)
    }
}

// MARK: - UITextField Delegate

extension WorkflowTaskStatusViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLen = (textView.text.count - range.length) + text.count
        return newLen <= maxLengthForComments
    }
}
