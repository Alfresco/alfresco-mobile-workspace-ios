//
// Copyright (C) 2005-2020 Alfresco Software Limited.
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
import MaterialComponents.MaterialProgressView
import MaterialComponents.MaterialDialogs

class FilePreviewViewController: SystemThemableViewController {
    @IBOutlet weak var containerFilePreview: UIView!
    @IBOutlet weak var progressView: MDCProgressView!
    @IBOutlet var previewContraintsToSafeArea: [NSLayoutConstraint]!
    @IBOutlet var previewContraintsToSuperview: [NSLayoutConstraint]!
    @IBOutlet weak var filePreviewStatusView: UIView!
    @IBOutlet weak var mimeTypeImageView: UIImageView!
    @IBOutlet weak var filePreviewStatusLabel: UILabel!
    @IBOutlet weak var filePreviewTitleLabel: UILabel!

    @IBOutlet weak var toolbar: UIToolbar!

    var needsContraintsForFullScreen = false

    var filePreviewViewModel: FilePreviewViewModel?
    var actionMenuViewModel: ActionMenuViewModel?
    var nodeActionsViewModel: NodeActionsViewModel?
    var isFullScreen = false

    weak var filePreviewCoordinatorDelegate: FilePreviewScreenCoordinatorDelegate?

    private var filePreviewPasswordDialog: MDCAlertController?
    private var filePreviewPasswordField: MDCOutlinedTextField?

    override func viewDidLoad() {
        super.viewDidLoad()

        progressView.progress = 0
        progressView.mode = .indeterminate
        view.bringSubviewToFront(progressView)

        startLoading()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        addToolbarActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true

        ControllerRotation.lockOrientation(.all)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        filePreviewViewModel?.requestFilePreview(with: containerFilePreview.bounds.size)
        filePreviewTitleLabel.text = filePreviewViewModel?.node.title
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Remove navigation bar underline separator
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        tabBarController?.tabBar.isHidden = false

        filePreviewViewModel?.cancelOngoingOperations()
        Snackbar.dimissAll()

        ControllerRotation.lockOrientation(.portrait, andRotateTo: .portrait)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override var prefersStatusBarHidden: Bool {
        return isFullScreen
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            if sSelf.needsContraintsForFullScreen {
                sSelf.activateContraintsToSuperview()
            }
        }
        filePreviewViewModel?.filePreview?.recalculateFrame(from: size)
    }

    // MARK: - IBActions

    @objc func toolbarActionTapped(sender: UIBarButtonItem) {
        guard let actions = actionMenuViewModel?.actionsForToolbar() else { return }
        let action = actions[sender.tag]
        nodeActionsViewModel?.tapped(on: action.type, finished: {
        })
    }

    // MARK: - Private Helpers

    private func addToolbarActions() {
        actionMenuViewModel?.divideForToolbarActions()
        guard let actions = actionMenuViewModel?.actionsForToolbar() else { return }
        var array = [UIBarButtonItem]()
        for action in actions {
            let button = UIBarButtonItem(image: action.icon,
                                         style: .plain,
                                         target: self,
                                         action: #selector(toolbarActionTapped(sender:)))
            button.tag = array.count
            button.image = action.icon
            array.append(button)
        }

        var toolbarActions = [UIBarButtonItem]()
        for button in array {
            toolbarActions.append(button)
            toolbarActions.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        toolbarActions.removeLast()
        toolbar.items = toolbarActions
    }

    private func activateContraintsToSuperview() {
        NSLayoutConstraint.deactivate(previewContraintsToSafeArea)
        NSLayoutConstraint.activate(previewContraintsToSuperview)
        view.layoutIfNeeded()
        containerFilePreview.layoutIfNeeded()
    }

    private func startLoading() {
        progressView.startAnimating()
        progressView.setHidden(false, animated: false)
    }

    private func stopLoading() {
        progressView.stopAnimating()
        progressView.setHidden(true, animated: false)
    }

    override func applyComponentsThemes() {
        guard let themingService = self.themingService, let currentTheme = themingService.activeTheme else { return }
        view.backgroundColor = currentTheme.backgroundColor
        filePreviewViewModel?.filePreview?.applyComponentsThemes(themingService.activeTheme)
        if let passwordDialog = filePreviewPasswordDialog, let passwordField = filePreviewPasswordField {
            applyTheme(for: passwordDialog)
            applyTheme(for: passwordField)
        }

        navigationController?.navigationBar.backgroundColor = currentTheme.surfaceColor
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil

        filePreviewStatusLabel.applyStyleCaptionOnSurface60(theme: currentTheme)
        filePreviewTitleLabel.applyStyleBody2OnSurface(theme: currentTheme)
        mimeTypeImageView.image = FileIcon.icon(for: filePreviewViewModel?.node.mimeType)

        toolbar.barTintColor = currentTheme.surfaceColor
        toolbar.tintColor = currentTheme.onSurfaceColor.withAlphaComponent(0.6)
    }

    private func applyTheme(for dialog: MDCAlertController) {
        if let themingService = self.themingService {
            dialog.applyTheme(withScheme: themingService.containerScheming(for: .pdfPasswordDialog))
            dialog.titleColor = themingService.activeTheme?.onSurfaceColor
            dialog.messageColor = themingService.activeTheme?.onBackgroundColor
        }
    }

    private func applyTheme(for passwordField: MDCOutlinedTextField) {
        if let themingService = themingService {
            passwordField.applyTheme(withScheme: themingService.containerScheming(for: .loginTextField))
        }
    }
}

// MARK: - PreviewFile ViewModel Delegate

extension FilePreviewViewController: FilePreviewViewModelDelegate {
    func display(previewContainer: FilePreviewProtocol) {
        view.bringSubviewToFront(filePreviewStatusView)
        filePreviewStatusLabel.text = LocalizationConstants.FilePreview.loadingPreviewMessage

        containerFilePreview.addSubview(previewContainer)
        filePreviewViewModel?.filePreview?.filePreviewDelegate = self
        filePreviewViewModel?.filePreview?.applyComponentsThemes(themingService?.activeTheme)

        NSLayoutConstraint.activate([
            previewContainer.topAnchor.constraint(equalTo: self.containerFilePreview.topAnchor, constant: 0),
            previewContainer.leftAnchor.constraint(equalTo: self.containerFilePreview.leftAnchor, constant: 0),
            previewContainer.rightAnchor.constraint(equalTo: self.containerFilePreview.rightAnchor, constant: 0),
            previewContainer.bottomAnchor.constraint(equalTo: self.containerFilePreview.bottomAnchor, constant: 0)
        ])
    }

    func requestFileUnlock(retry: Bool) {
        let passwordField = MDCOutlinedTextField()
        passwordField.labelBehavior = MDCTextControlLabelBehavior.floats
        passwordField.clearButtonMode = UITextField.ViewMode.whileEditing
        passwordField.isSecureTextEntry = false
        passwordField.label.text = LocalizationConstants.TextFieldPlaceholders.password
        applyTheme(for: passwordField)
        passwordField.isSecureTextEntry = true
        filePreviewPasswordField = passwordField

        let alertTitle = retry ? LocalizationConstants.FilePreview.passwordPromptFailTitle : LocalizationConstants.FilePreview.passwordPromptTitle
        let alertMessage = retry ? LocalizationConstants.FilePreview.passwordPromptFailMessage : LocalizationConstants.FilePreview.passwordPromptMessage

        let alertController = MDCAlertController(title: alertTitle, message: alertMessage)
        alertController.cornerRadius = dialogCornerRadius
        alertController.mdc_dialogPresentationController?.dismissOnBackgroundTap = false
        let submitAction = MDCAlertAction(title: LocalizationConstants.FilePreview.passwordPromptSubmit) { [weak self] _ in
            guard let sSelf = self else { return }
            sSelf.filePreviewViewModel?.unlockFile(with: passwordField.text ?? "")
        }
        let cancelAction = MDCAlertAction(title: LocalizationConstants.Buttons.cancel) { [weak self] _ in
            guard let sSelf = self else { return }

            alertController.dismiss(animated: true, completion: nil)
            sSelf.filePreviewCoordinatorDelegate?.navigateBack()
        }
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)

        alertController.accessoryView = passwordField
        applyTheme(for: alertController)
        filePreviewPasswordDialog = alertController

        present(alertController, animated: true, completion: {
            passwordField.becomeFirstResponder()
        })
    }

    func enableFullscreenContentExperience() {
        needsContraintsForFullScreen = true
        activateContraintsToSuperview()
    }

    func willPreparePreview() {
        filePreviewStatusLabel.text = LocalizationConstants.FilePreview.preparingPreviewMessage
    }

    func didFinishLoadingPreview(error: Error?) {
        filePreviewStatusView.isHidden = true
        stopLoading()
        filePreviewViewModel?.sendAnalyticsForPreviewFile(success: (error == nil))
    }
}

// MARK: - ActionMenuViewModel Delegate

extension FilePreviewViewController: NodeActionsViewModelDelegate {
    func nodeActionFinished(with actionType: ActionMenuType, node: ListNode, error: Error?) {
        switch actionType {
        case .more:
            filePreviewCoordinatorDelegate?.showActionSheetForListItem(node: node, delegate: self)
        default: break
        }
    }
}

// MARK: - FilePreview Delegate

extension FilePreviewViewController: FilePreviewDelegate {
    func enableFullScreen(_ enable: Bool) {
        isFullScreen = enable
        containerFilePreview.backgroundColor = (isFullScreen) ? .black : .clear
        navigationController?.setNavigationBarHidden(isFullScreen, animated: true)
        setNeedsStatusBarAppearanceUpdate()
    }
}

// MARK: - Storyboard Instantiable

extension FilePreviewViewController: StoryboardInstantiable { }
