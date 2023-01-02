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
        
        progressView.isAccessibilityElement = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let isLocalFilePreview = filePreviewViewModel?.isLocalFilePreview ?? false
        if isLocalFilePreview {
            startPreviewingLocalFiles()
        } else if let publicURL = notificationsCentre().notificationURL, !publicURL.isEmpty {
            previewPublicURlFile(url: "https://mobileapps.envalfresco.com/aca/#/preview/s/kV66-gfvSD-DxRvDf8Qepg")
        } else {
            startPreviewingNode()
        }

        addDownloadContentButton()
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
    
    private func addDownloadContentButton() {
        let isContentAlreadyDownloaded = filePreviewViewModel?.isContentAlreadyDownloaded ?? false
        if isContentAlreadyDownloaded {
            let downloadButton = UIButton(type: .custom)
            downloadButton.accessibilityIdentifier = "downloadButton"
            downloadButton.frame = CGRect(x: 0.0, y: 0.0,
                                        width: 30.0,
                                        height: 30.0)
            downloadButton.imageView?.contentMode = .scaleAspectFill
            downloadButton.layer.masksToBounds = true
            downloadButton.addTarget(self,
                                   action: #selector(downloadButtonTapped),
                                   for: UIControl.Event.touchUpInside)
            downloadButton.setImage(UIImage(named: "ic-action-download"),
                                  for: .normal)

            let searchBarButtonItem = UIBarButtonItem(customView: downloadButton)
            searchBarButtonItem.accessibilityIdentifier = "downloadBarButton"
            searchBarButtonItem.accessibilityLabel = LocalizationConstants.Accessibility.download
            let currWidth = searchBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: 30.0)
            currWidth?.isActive = true
            let currHeight = searchBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: 30.0)
            currHeight?.isActive = true
            self.navigationItem.rightBarButtonItem = searchBarButtonItem
        }
    }
    
    @objc func downloadButtonTapped() {
        let path = filePreviewViewModel?.listNode?.path ?? ""
        let fileUrl = URL(fileURLWithPath: path)
        displayActivityViewController(for: fileUrl)
    }
    
    private func displayActivityViewController(for url: URL) {
        guard let presentationContext = UIViewController.applicationTopMostPresented else { return }
        
        let activityViewController =
            UIActivityViewController(activityItems: [url],
                                     applicationActivities: nil)
        activityViewController.modalPresentationStyle = .popover

        let clearController = UIViewController()
        clearController.view.backgroundColor = .clear
        clearController.modalPresentationStyle = .overCurrentContext

        activityViewController.completionWithItemsHandler = { [weak self] (activity, success, _, _) in
            guard let sSelf = self else { return }

            activityViewController.dismiss(animated: true)
            clearController.dismiss(animated: false) {
                // Will not base check on error code as used constants have been deprecated
                if activity?.rawValue == KeyConstants.Save.toCameraRoll && !success {
                    let privacyVC = PrivacyNoticeViewController.instantiateViewController()
                    privacyVC.viewModel = PrivacyNoticePhotosModel()
                    privacyVC.coordinatorServices = sSelf.coordinatorServices
                    presentationContext.present(privacyVC,
                                                animated: true,
                                                completion: nil)
                }
            }
        }

        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = presentationContext.view.bounds
            popoverController.sourceView = presentationContext.view

            popoverController.permittedArrowDirections = []
        }

        presentationContext.present(clearController,
                                    animated: false) {
            clearController.present(activityViewController,
                                    animated: true,
                                    completion: nil)
        }
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
            button.accessibilityLabel = action.analyticEventName
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
        toolbar.tintColor = currentTheme.onSurface70Color
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
        filePreviewStatusLabel.accessibilityLabel = filePreviewStatusLabel.text

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
        filePreviewStatusLabel.accessibilityLabel = filePreviewStatusLabel.text
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
            filePreviewTitleLabel.accessibilityLabel = filePreviewTitleLabel.text
            mimeTypeImageView.image = FileIcon.icon(for: filePreviewViewModel.listNode)
        }
    }
    
    private func previewPublicURlFile(url: String?) {
        
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
        title = LocalizationConstants.ScreenTitles.previewCaptureAsset
        toolbar.isHidden = true
        filePreviewViewModel.requestPublicURLFilePreview(with: containerFilePreview.bounds.size, url: url)
        filePreviewTitleLabel.text = LocalizationConstants.ScreenTitles.previewCaptureAsset
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
            } else if action.type.isCreateActions {
                handleSheetCreate(action: action, node: node)
            }
            logEvent(with: action, node: node)
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
    
    func handleSheetCreate(action: ActionMenu, node: ListNode?) {
        switch action.type {
        case .renameNode:
            filePreviewCoordinatorDelegate?.renameNodeForListItem(for: node, actionMenu: action, delegate: self)
        default: break
        }
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

extension FilePreviewViewController: CreateNodeViewModelDelegate {

    func handleCreatedNode(node: ListNode?, error: Error?, isUpdate: Bool) {
        if node == nil && error == nil {
            return
        } else if let error = error {
            self.display(error: error)
        } else {
            self.title = node?.title ?? ""
            displaySnackbar(with: String(format: LocalizationConstants.Approved.updated,
                                         node?.truncateTailTitle() ?? ""),
                            type: .approve)
        }
    }
}

// MARK: - Analytics
extension FilePreviewViewController {
    
    func logEvent(with action: ActionMenu?, node: ListNode?) {
        guard let action = action else { return }
        AnalyticsManager.shared.fileActionEvent(for: node, action: action)
    }
}

// MARK: - Storyboard Instantiable

extension FilePreviewViewController: StoryboardInstantiable { }
