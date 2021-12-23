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
    var toolbarActions: [UIBarButtonItem] = []

    var needsContraintsForFullScreen = false

    var filePreviewViewModel: FilePreviewViewModel?
    var isFullScreen = false

    weak var filePreviewCoordinatorDelegate: FilePreviewScreenCoordinatorDelegate?

    private var filePreviewPasswordDialog: MDCAlertController?
    private var filePreviewPasswordField: MDCOutlinedTextField?

    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let isLocalFilePreview = filePreviewViewModel?.isLocalFilePreview ?? false
        if isLocalFilePreview {
            startPreviewingLocalFiles()
        } else {
            startPreviewingNode()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true

        allowInterfaceRotation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tabBarController?.tabBar.isHidden = false

        filePreviewViewModel?.cancelOngoingOperations()
        Snackbar.dimissAll()

        ControllerRotation.lockOrientation(.portrait, andRotateTo: .portrait)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override var prefersStatusBarHidden: Bool {
        return isFullScreen
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            if sSelf.needsContraintsForFullScreen {
                sSelf.activateContraintsToSuperview()
            }
        }
        filePreviewViewModel?.filePreview?.recalculateFrame(from: size)
    }

    func allowInterfaceRotation() {
        ControllerRotation.lockOrientation(.all)
    }

    // MARK: - IBActions

    @objc func toolbarActionTapped(sender: UIBarButtonItem) {
        guard let actions = filePreviewViewModel?.actionMenuViewModel?.actionsForToolbar() else {
            return
        }

        let action = actions[sender.tag]
        filePreviewViewModel?.nodeActionsViewModel?.tapped(on: action,
                                                           finished: {})
    }

    // MARK: - Preview For Local Files
    private func startPreviewingLocalFiles() {
        title = filePreviewViewModel?.listNode?.title
        filePreviewViewModel?.setNodeDetailsForLocalFile()
    }

    // MARK: - Private Helpers

    private func startPreviewingNode() {
        progressView.progress = 0
        progressView.mode = .indeterminate
        view.bringSubviewToFront(progressView)

        startLoading()

        title = filePreviewViewModel?.listNode?.title
        filePreviewViewModel?.requestUpdateNodeDetails()
    }

    private func addToolbarActions() {
        guard let actions = filePreviewViewModel?.actionMenuViewModel?.actionsForToolbar() else {
            return
        }

        var array = [UIBarButtonItem]()
        for action in actions {
            let button = UIBarButtonItem(image: action.icon,
                                         style: .plain,
                                         target: self,
                                         action: #selector(toolbarActionTapped(sender:)))
            button.tag = array.count
            button.image = action.icon
            button.accessibilityIdentifier = action.type.rawValue
            array.append(button)
        }
        self.toolbarActions = array
        var toolbarActions = [UIBarButtonItem]()
        for button in array {
            toolbarActions.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                                  target: nil,
                                                  action: nil))
            toolbarActions.append(button)
            toolbarActions.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                                  target: nil,
                                                  action: nil))
        }
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
        super.applyComponentsThemes()
        guard  let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        view.backgroundColor = currentTheme.backgroundColor
        filePreviewViewModel?.filePreview?.applyComponentsThemes(currentTheme)

        if let passwordDialog = filePreviewPasswordDialog,
           let passwordField = filePreviewPasswordField {
            applyTheme(for: passwordDialog)
            applyTheme(for: passwordField)
        }

        filePreviewStatusLabel.applyStyleCaptionOnSurface60(theme: currentTheme)
        filePreviewTitleLabel?.font = currentTheme.body2TextStyle.font
        filePreviewTitleLabel?.textColor = currentTheme.onSurfaceColor

        toolbar.barTintColor = currentTheme.primaryColorVariant
        toolbar.tintColor = currentTheme.onSurface60Color
    }

    private func applyTheme(for dialog: MDCAlertController) {
        if let themingService = coordinatorServices?.themingService {
            dialog.applyTheme(withScheme: themingService.containerScheming(for: .pdfPasswordDialog))
            dialog.titleColor = themingService.activeTheme?.onSurfaceColor
            dialog.messageColor = themingService.activeTheme?.onBackgroundColor
        }
    }

    private func applyTheme(for passwordField: MDCOutlinedTextField) {
        if let themingService = coordinatorServices?.themingService {
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
        filePreviewViewModel?.filePreview?.applyComponentsThemes(coordinatorServices?.themingService?.activeTheme)

        NSLayoutConstraint.activate([
            previewContainer.topAnchor.constraint(equalTo: self.containerFilePreview.topAnchor,
                                                  constant: 0),
            previewContainer.leftAnchor.constraint(equalTo: self.containerFilePreview.leftAnchor,
                                                   constant: 0),
            previewContainer.rightAnchor.constraint(equalTo: self.containerFilePreview.rightAnchor,
                                                    constant: 0),
            previewContainer.bottomAnchor.constraint(equalTo: self.containerFilePreview.bottomAnchor,
                                                     constant: 0)
        ])
    }

    func enableFullscreenContentExperience() {
        needsContraintsForFullScreen = true
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            if sSelf.needsContraintsForFullScreen {
                sSelf.activateContraintsToSuperview()
            }
        }
    }

    func willPreparePreview() {
        filePreviewStatusLabel.text = LocalizationConstants.FilePreview.preparingPreviewMessage
    }

    func didFinishLoadingPreview(error: Error?) {
        filePreviewStatusView.isHidden = true
        stopLoading()
        filePreviewViewModel?.sendAnalyticsForPreviewFile(success: (error == nil))
    }

    func update(listNode: ListNode) {
        if let index = filePreviewViewModel?.actionMenuViewModel?.indexInToolbar(for: .removeFavorite) {
            let icon = (listNode.favorite ?? false) ? ActionMenuType.removeFavorite.rawValue :
                ActionMenuType.addFavorite.rawValue
            toolbarActions[index].image = UIImage(named: icon)
        }
        if let index = filePreviewViewModel?.actionMenuViewModel?.indexInToolbar(for: .addFavorite) {
            let icon = (listNode.favorite ?? false ) ? ActionMenuType.removeFavorite.rawValue :
                ActionMenuType.addFavorite.rawValue
            toolbarActions[index].image = UIImage(named: icon)
        }
    }

    func didFinishNodeDetails(error: Error?) {
        let handleError = { [weak self] in
            guard let sSelf = self else { return }

            Snackbar.display(with: LocalizationConstants.Errors.errorUnknown,
                             type: .error, automaticallyDismisses: false, finish: nil)
            sSelf.toolbar.isHidden = true
        }

        guard let filePreviewViewModel = filePreviewViewModel else {
            handleError()
            return
        }

        if error != nil {
            handleError()
        } else {
            if filePreviewViewModel.shouldDisplayActionsToolbar() {
                toolbar.isHidden = false
                filePreviewViewModel.nodeActionsViewModel?.delegate = self
                addToolbarActions()
            } else {
                toolbar.isHidden = true
            }
            filePreviewViewModel.requestFilePreview(with: containerFilePreview.bounds.size)
            filePreviewTitleLabel.text = filePreviewViewModel.listNode?.title
            mimeTypeImageView.image = FileIcon.icon(for: filePreviewViewModel.listNode)
        }
    }
    
    func reloadPreview() {
        startPreviewingNode()
    }
}

// MARK: - ActionMenuViewModel Delegate

extension FilePreviewViewController: NodeActionsViewModelDelegate {

    func handleFinishedAction(with action: ActionMenu?,
                              node: ListNode?,
                              error: Error?) {
        if let error = error {
            self.display(error: error)
        } else {
            guard let action = action else { return }

            if action.type.isGenericActions {
                handleGeneric(action: action, node: node)
            } else if action.type.isFavoriteActions {
                handleFavorite(action: action)
            } else if action.type.isMoveActions {
                handleMove(action: action, node: node)
            } else if action.type.isDownloadActions {
                handleDownload(action: action, node: node)
            }
        }
    }

    func handleGeneric(action: ActionMenu, node: ListNode?) {
        guard let node = node else { return }
        switch action.type {
        case .more:
            filePreviewCoordinatorDelegate?.showActionSheetForListItem(node: node,
                                                                       delegate: self)
        default: break
        }
    }

    func handleFavorite(action: ActionMenu) {
        var snackBarMessage: String?
        switch action.type {
        case .addFavorite:
            snackBarMessage = LocalizationConstants.Approved.removedFavorites
        case .removeFavorite:
            snackBarMessage = LocalizationConstants.Approved.addedFavorites
        default: break
        }
        displaySnackbar(with: snackBarMessage, type: .approve)
    }

    func handleMove(action: ActionMenu, node: ListNode?) {
        guard let node = node else { return }
        switch action.type {
        case .moveTrash:
            filePreviewCoordinatorDelegate?.navigateBack()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                Snackbar.display(with: String(format: LocalizationConstants.Approved.movedTrash,
                                              node.truncateTailTitle()),
                                 type: .approve, finish: nil)
            })
        default: break
        }
    }

    func handleDownload(action: ActionMenu, node: ListNode?) {
        guard let node = node else { return }
        var snackBarMessage: String?
        switch action.type {
        case .markOffline:
            snackBarMessage = String(format: LocalizationConstants.Approved.removeOffline,
                                     node.truncateTailTitle())
        case .removeOffline:
            snackBarMessage = String(format: LocalizationConstants.Approved.markOffline,
                                     node.truncateTailTitle())
        default: break
        }
        displaySnackbar(with: snackBarMessage, type: .approve)
    }

    func display(error: Error) {
        var snackBarMessage = ""
        switch error.code {
        case ErrorCodes.Swagger.timeout:
            snackBarMessage = LocalizationConstants.Errors.errorTimeout
        default:
            snackBarMessage = LocalizationConstants.Errors.errorUnknown
        }
        displaySnackbar(with: snackBarMessage, type: .error)
    }

    func displaySnackbar(with message: String?, type: SnackBarType?) {
        if let message = message, let type = type {
            let snackBar = Snackbar(with: message, type: type)
            snackBar.snackBar.presentationHostViewOverride = view
            snackBar.show(completion: nil)
        }
    }
}

// MARK: - FilePreview Delegate

extension FilePreviewViewController: FilePreviewDelegate {
    func enableFullScreen(_ enable: Bool) {
        guard let filePreviewViewModel = filePreviewViewModel else {
            return
        }

        isFullScreen = enable
        containerFilePreview.backgroundColor = (isFullScreen) ? .black : .clear
        navigationController?.setNavigationBarHidden(isFullScreen, animated: true)
        setNeedsStatusBarAppearanceUpdate()

        if filePreviewViewModel.shouldDisplayActionsToolbar() {
            toolbar.isHidden = enable
        }
    }
}

// MARK: - Storyboard Instantiable

extension FilePreviewViewController: StoryboardInstantiable { }
