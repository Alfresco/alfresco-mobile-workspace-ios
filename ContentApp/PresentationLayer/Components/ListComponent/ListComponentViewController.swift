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
import AlfrescoContent
import MaterialComponents.MaterialActivityIndicator
import MaterialComponents.MaterialProgressView
import Micro

var notificationObserver: NSObjectProtocol?

class ListComponentViewController: SystemThemableViewController {
    @IBOutlet weak var collectionView: PageFetchableCollectionView!
    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListTitle: UILabel!
    @IBOutlet weak var emptyListSubtitle: UILabel!
    @IBOutlet weak var emptyListImageView: UIImageView!
    @IBOutlet weak var progressView: MDCProgressView!
    @IBOutlet weak var createButton: MDCFloatingButton!
    @IBOutlet weak var listActionButton: MDCButton!
    var refreshControl: UIRefreshControl?
    @IBOutlet weak var uploadingBannerView: UIView!
    @IBOutlet weak var uploadingBannerHeight: NSLayoutConstraint!
    @IBOutlet weak var uploadingPercentageLabel: UILabel!
    @IBOutlet weak var uploadingFilesImageView: UIImageView!
    @IBOutlet weak var uploadingFilesLabel: UILabel!
    @IBOutlet weak var uploadingProgressView: MDCProgressView!
    @IBOutlet weak var moveFilesBottomView: UIView!
    @IBOutlet weak var moveFilesButton: MDCButton!
    @IBOutlet weak var cancelMoveButton: MDCButton!
    
    var pageController: ListPageController?
    var viewModel: ListComponentViewModel?
    var dataSource: ListComponentDataSource?
    
    weak var listActionDelegate: ListComponentActionDelegate?
    weak var listItemActionDelegate: ListItemActionDelegate?
    
    private var kvoConnectivity: NSKeyValueObservation?
    private let listBottomInset: CGFloat = 70.0
    private let bannerHeight: CGFloat = 60.0
    
    var destinationNodeToMove: ListNode?
    var sourceNodeToMove: [ListNode]?
    var navigationViewController: UINavigationController?
    var multipleSelectionHeader: MultipleSelectionHeaderView? = .fromNib()
    var folderId = ""
    var isAPSAttachmentFlow = false
    var connectivityService: ConnectivityService?
    private var didShowFinalNotification = false
    var lastUploadedCount: Int = 0
    var lastTotalCount: Int = 0
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.isAccessibilityElement = false
        // Configure collection view data source and delegate
        guard let viewModel = self.viewModel,
              let services = coordinatorServices else { return }
        let dataSourceConfiguration =
            ListComponentDataSourceConfiguration(collectionView: collectionView,
                                                 viewModel: viewModel,
                                                 cellDelegate: self,
                                                 services: services)
        let dataSource = ListComponentDataSource(with: dataSourceConfiguration,
                                                 delegate: self)
        self.dataSource = dataSource
        
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        collectionView.pageDelegate = self
                
        emptyListView.isHidden = true
        let connectivityService = coordinatorServices?.connectivityService
        if connectivityService?.hasInternetConnection() == false {
            createButton.isHidden = true
        } else {
            createButton.isHidden = !viewModel.shouldDisplayCreateButton()
        }
        
        listActionButton.isHidden = !viewModel.shouldDisplayListActionButton()
        
        listActionButton.isUppercaseTitle = false
        listActionButton.setTitle(viewModel.listActionTitle(), for: .normal)
        listActionButton.layer.cornerRadius = listActionButton.frame.height / 2
        if let isAttachment = appDelegate()?.isAPSAttachmentFlow, isAttachment {
            isAPSAttachmentFlow = isAttachment
            createButton.isHidden = isAttachment
            moveFilesBottomView.isHidden = isAttachment
        } else {
            moveFilesBottomView.isHidden = viewModel.shouldHideMoveItemView()
        }

        if viewModel.shouldDisplayCreateButton() ||
            viewModel.shouldDisplayListActionButton() {
            collectionView.contentInset = UIEdgeInsets(top: 0,
                                                       left: 0,
                                                       bottom: listBottomInset,
                                                       right: 0)
        }
                
        // Set up progress view
        progressView.progress = 0
        progressView.mode = .indeterminate
        
        // Set up pull to refresh control
        let refreshControl = UIRefreshControl()// RefreshIndicatorView(theme: themingService?.activeTheme)
        collectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh),
                                 for: .valueChanged)
        self.refreshControl = refreshControl
        
        // Register collection view footer and cell
        collectionView.register(ActivityIndicatorFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: String(describing: ActivityIndicatorFooterView.self))
        let identifier = String(describing: ListElementCollectionViewCell.self)
        collectionView?.register(UINib(nibName: identifier,
                                       bundle: nil),
                                 forCellWithReuseIdentifier: identifier)
        
        // ReSignIn Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleReSignIn(notification:)),
                                               name: Notification.Name(KeyConstants.Notification.reSignin),
                                               object: nil)
        // Sync Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleSyncStartedNotification(notification:)),
                                               name: Notification.Name(KeyConstants.Notification.syncStarted),
                                               object: nil)
        
        // Refresh Recent List
        if notificationObserver == nil {
            notificationObserver = NotificationCenter.default.addObserver(forName: Notification.Name(KeyConstants.Notification.refreshRecentList),
                                                                          object: nil,
                                                                          queue: .main) { [weak self] notification in
                self?.handleReSignIn(notification: notification)
            }
        }
        
        observeConnectivity()
        setAccessibility()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Move files
    @IBAction func moveFilesButtonAction(_ sender: Any) {
        if isAPSAttachmentFlow {
            triggerMoveNotifyService(folderId: folderId, folderName: destinationNodeToMove?.title ?? "")
        } else {
            guard let source = self.sourceNodeToMove, let destination = self.destinationNodeToMove else { return }
            let menu = ActionMenu(title: LocalizationConstants.ActionMenu.moveToFolder,
                                  type: .moveToFolder)
            self.listItemActionDelegate?.moveNodeTapped(for: source, destinationNode: destination, delegate: self, actionMenu: menu)
        }
    }
    
    @IBAction func cancelMoveButtonAction(_ sender: Any) {
        appDelegate()?.isMoveFilesAndFolderFlow = false
        appDelegate()?.isAPSAttachmentFlow = false
        moveFilesBottomView.isHidden = true
        triggerMoveNotifyService(folderId: "", folderName: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handleConnectivity()
        
        if coordinatorServices?.syncService?.syncServiceStatus != .idle {
            listActionButton.isEnabled = false
        }
        
        collectionView.reloadData()
        
        let activeTheme = coordinatorServices?.themingService?.activeTheme
        progressView.progressTintColor = activeTheme?.primaryT1Color
        progressView.trackTintColor = activeTheme?.primary30T1Color
       
        checkForUploadingFilesBanner()
    }
    
    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
        progressView.progressTintColor = coordinatorServices?.themingService?.activeTheme?.primaryT1Color
        progressView.trackTintColor =
            coordinatorServices?.themingService?.activeTheme?.primary30T1Color
    }
    
    // MARK: - Actions
    
    @IBAction func createButtonTapped(_ sender: MDCFloatingButton) {
        listItemActionDelegate?.showNodeCreationSheet(delegate: self)
    }
    
    @IBAction func listActionButtonTapped(_ sender: MDCFloatingButton) {
        listActionDelegate?.performListAction()
    }
    
    // MARK: - Public interface
    
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme,
              let buttonScheme = coordinatorServices?.themingService?.containerScheming(for: .dialogButton),
              let bigButtonScheme = coordinatorServices?.themingService?.containerScheming(for: .loginBigButton)
        else { return }
        
        emptyListTitle.applyeStyleHeadline6OnSurface(theme: currentTheme)
        emptyListTitle.textAlignment = .center
        emptyListSubtitle.applyStyleBody2OnSurface60(theme: currentTheme)
        emptyListSubtitle.textAlignment = .center
        
        createButton.backgroundColor = currentTheme.primaryT1Color
        createButton.tintColor = currentTheme.onPrimaryColor
        
        listActionButton.backgroundColor = currentTheme.primaryT1Color
        listActionButton.tintColor = currentTheme.onPrimaryColor
        listActionButton.setTitleFont(currentTheme.subtitle2TextStyle.font, for: .normal)
        
        refreshControl?.tintColor = currentTheme.primaryT1Color
        
        uploadingBannerView.layer.cornerRadius = 8.0
        uploadingBannerView.layer.borderWidth = 1.0
        uploadingBannerView.layer.borderColor =  currentTheme.onSurface15Color.cgColor
        uploadingBannerView.backgroundColor = currentTheme.primaryColorVariant
        uploadingPercentageLabel.font = currentTheme.body2TextStyle.font
        uploadingPercentageLabel.textColor = currentTheme.onSurface70Color
        uploadingFilesLabel.font = currentTheme.subtitle2TextStyle.font
        uploadingFilesLabel.textColor = currentTheme.onSurfaceColor
        uploadingProgressView.progressTintColor = currentTheme.primaryT1Color
        uploadingProgressView.trackTintColor = currentTheme.primary30T1Color
        
        moveFilesBottomView.backgroundColor = currentTheme.surfaceColor
        moveFilesButton.applyContainedTheme(withScheme: buttonScheme)
        moveFilesButton.isUppercaseTitle = false
        let buttonTitle = isAPSAttachmentFlow ? LocalizationConstants.Workflows.select : LocalizationConstants.Buttons.moveHere
        moveFilesButton.setTitle(buttonTitle, for: .normal)
        moveFilesButton.layer.cornerRadius = UIConstants.cornerRadiusDialog
        moveFilesButton.setShadowColor(.clear, for: .normal)
        
        cancelMoveButton.applyContainedTheme(withScheme: bigButtonScheme)
        cancelMoveButton.setBackgroundColor(currentTheme.onSurface5Color, for: .normal)
        cancelMoveButton.isUppercaseTitle = false
        cancelMoveButton.setTitle(LocalizationConstants.General.cancel, for: .normal)
        cancelMoveButton.setShadowColor(.clear, for: .normal)
        cancelMoveButton.setTitleColor(currentTheme.onSurfaceColor, for: .normal)
        cancelMoveButton.layer.cornerRadius = UIConstants.cornerRadiusDialog
    }
        
    func startLoading() {
        progressView.startAnimating()
        progressView.setHidden(false, animated: true)
    }
    
    func stopLoading() {
        progressView.stopAnimating()
        progressView.setHidden(true, animated: false)
        refreshControl?.endRefreshing()
    }
    
    func scrollToSection(_ section: Int) {
        let indexPath = IndexPath(item: 0, section: section)
        var pointToScroll = CGPoint.zero
        if collectionView.cellForItem(at: indexPath) != nil {
            if let attributes =
                collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader,
                                                                       at: indexPath) {
                pointToScroll =
                    CGPoint(x: 0, y: attributes.frame.origin.y - collectionView.contentInset.top)
            }
        }
        collectionView.setContentOffset(pointToScroll, animated: true)
    }
    
    func setAccessibility() {
        createButton.accessibilityIdentifier = "create-button"
        createButton.accessibilityLabel = LocalizationConstants.General.create
    }
    
    // MARK: - Private Interface
    
    @objc private func handlePullToRefresh() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            
            sSelf.pageController?.refreshList()
        }
    }
    
    @objc private func handleReSignIn(notification: Notification) {
        pageController?.refreshList()
    }
        
    private func reloadDataSource() {
        guard let model = pageController?.dataSource,
              let viewModel = viewModel,
              let dataSource = self.dataSource else { return }
        viewModel.getAvailableMenus()

        var indexPaths: [IndexPath] = []
        dataSource.state = forEach(model.listNodes()) { listNode in
            if listNode.guid == listNodeSectionIdentifier {
                return Cell<ListSectionCollectionViewCell>()
                .onSize { [weak self] context in
                    guard let sSelf = self else { return .zero}
                    indexPaths.append(context.indexPath)
                    return CGSize(width: sSelf.view.safeAreaLayoutGuide.layoutFrame.width,
                                  height: (viewModel.shouldDisplaySubtitle(for: context.indexPath)) ? regularCellHeight : compactCellHeight)
                }
            } else {
                return Cell<ListElementCollectionViewCell>()
                    .onSize { [weak self] context in
                        guard let sSelf = self else { return .zero}

                        return CGSize(width: sSelf.view.safeAreaLayoutGuide.layoutFrame.width,
                                      height: (viewModel.shouldDisplaySubtitle(for: context.indexPath)) ? regularCellHeight : compactCellHeight)
                    }.onSelect { [weak self] context in
                        guard let sSelf = self else { return }
                        if let node = model.listNode(for: context.indexPath) {
                            
                            if !viewModel.selectedMultipleItems.isEmpty {
                                sSelf.handleAddRemoveNodeList(node: node)
                                return
                            }
                            
                            if viewModel.shouldPreviewNode(at: context.indexPath) == false { return }
                            if node.trashed == false {
                                if sSelf.isNavigationAllowed(for: node) {
                                    sSelf.listItemActionDelegate?.showPreview(for: node,
                                                                              from: model)
                                    sSelf.listActionDelegate?.elementTapped(node: node)
                                }
                            } else {
                                if viewModel.isTrashAvailable {
                                    sSelf.listItemActionDelegate?.showActionSheetForListItem(for: node,
                                                                                             from: model,
                                                                                             delegate: sSelf)
                                }
                            }
                        }
                    }
            }
        }
        
        self.forceRefresh(with: indexPaths)
    }
    
    func isNavigationAllowed(for node: ListNode?) -> Bool {
        if let isMoveFiles = appDelegate()?.isMoveFilesAndFolderFlow, isMoveFiles, let source = self.sourceNodeToMove {
            let destinationElementIds = node?.elementIds?.components(separatedBy: ",") ?? []
            var isShowSnackbar = false
            for listNode in source where destinationElementIds.contains(listNode.guid) {
                isShowSnackbar = true
                break
            }
            
            if isShowSnackbar {
                Snackbar.display(with: LocalizationConstants.Alert.searchMoveWarning,
                                 type: .approve,
                                 presentationHostViewOverride: appDelegate()?.window,
                                 finish: nil)
                return false
            }
        }
        return true
    }
    
    func openFolderAfterCreate(for node: ListNode?) {
        if let node = node {
            guard let model = pageController?.dataSource else {
                return
            }
            self.listItemActionDelegate?.showPreview(for: node,
                                                      from: model)
            self.listActionDelegate?.elementTapped(node: node)
        }
    }
    
    private func forceRefresh(with indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            self.forceDisplayRefresh(for: indexPath)
        }
    }
    
    // MARK: Connectivity Helpers
    
    private func observeConnectivity() {
        let connectivityService = coordinatorServices?.connectivityService
        kvoConnectivity = connectivityService?.observe(\.status,
                                                       options: [.new],
                                                       changeHandler: { [weak self] (_, _) in
                                                        guard let sSelf = self else { return }
                                                        sSelf.handleConnectivity()
                                                        sSelf.collectionView.reloadData()
                                                       })
    }
    
    private func handleConnectivity() {
        let connectivityService = coordinatorServices?.connectivityService
        if connectivityService?.hasInternetConnection() == false {
            didUpdateList(error: NSError(), pagination: nil, source: nil)
            
            if viewModel?.shouldDisplayPullToRefreshOffline() == false {
                refreshControl?.removeFromSuperview()
            }
        } else {
            if let refreshControl = self.refreshControl, refreshControl.superview == nil {
                collectionView.addSubview(refreshControl)
            }
        }
        listActionButton.isEnabled = connectivityService?.hasInternetConnection() ?? false
        if connectivityService?.hasInternetConnection() == false {
            removeUploadingFileBanner()
        }
    }
    
    internal func isPaginationEnabled() -> Bool {
        guard let isPaginationEnabled = pageController?.isPaginationEnabled() else { return true }
        return isPaginationEnabled
    }
}

// MARK: - ListElementCollectionViewCell Delegate

extension ListComponentViewController: ListElementCollectionViewCellDelegate {
    func moreButtonTapped(for element: ListNode?, in cell: ListElementCollectionViewCell) {
        guard let node = element,
              let model = pageController?.dataSource else { return }
        listItemActionDelegate?.showActionSheetForListItem(for: node,
                                                           from: model,
                                                           delegate: self)
    }
    
    func longTapGestureActivated(for element: ListNode?, in cell: ListElementCollectionViewCell) {
        let guid = element?.guid ?? "0"
        if guid != "0" {
            let isMoveFilesAndFolderFlow = appDelegate()?.isMoveFilesAndFolderFlow ?? false
            let isSelectedItemsArrayEmpty = viewModel?.selectedMultipleItems.isEmpty ?? true
            if isSelectedItemsArrayEmpty && !isMoveFilesAndFolderFlow {
                guard let node = element else { return }
                viewModel?.isMultipleFileSelectionEnabled = true
                handleAddRemoveNodeList(node: node)
                createButton.isHidden = true
                listActionDelegate?.enabledLongTapGestureForMultiSelection(isShowTabbar: false)
                listActionButton.isHidden = true
                showMultiSelectionHeader()
                collectionView.reloadData()
            }
        }
    }
}

// MARK: - PageFetchableDelegate

extension ListComponentViewController: PageFetchableDelegate {
    func fetchNextContentPage(for collectionView: UICollectionView, itemAtIndexPath: IndexPath) {
        pageController?.fetchNextPage()
    }
}

// MARK: - ListPageControllerDelegate

extension ListComponentViewController: ListPageControllerDelegate {
    func didUpdateList(error: Error?,
                       pagination: Pagination?,
                       source: Node?) {
        guard let model = pageController?.dataSource else { return }
        
        // When no error or pagination information is present just perform a data source reload
        // as this might be a filter action
        if error == nil && pagination == nil {
            reloadDataSource()
            return
        }
        
        let isMultipleFileSelectionEnabled = viewModel?.isMultipleFileSelectionEnabled ?? false
        if isMultipleFileSelectionEnabled {
            listActionButton.isHidden = true
        } else {
            listActionButton.isHidden = !(viewModel?.shouldDisplayListActionButton() ?? false)
        }
        if isAPSAttachmentFlow {
            createButton.isHidden = isAPSAttachmentFlow
            let createdByUserId = source?.createdByUser._id
            if createdByUserId != nil {
                if createdByUserId == "System" {
                    moveFilesBottomView.isHidden = isAPSAttachmentFlow
                } else {
                    folderId = source?._id ?? ""
                    moveFilesBottomView.isHidden = false
                }
            }
        } else {
            moveFilesBottomView.isHidden = (viewModel?.shouldHideMoveItemView() ?? true)
        }
        
        let isListEmpty = model.isEmpty()
        emptyListView.isHidden = !isListEmpty
        if isListEmpty {
            let emptyList = viewModel?.emptyList()
            emptyListImageView.image = emptyList?.icon
            emptyListTitle.text = emptyList?.title
            emptyListSubtitle.text = emptyList?.description
            
            emptyListTitle.accessibilityLabel = LocalizationConstants.Accessibility.title
            emptyListTitle.accessibilityValue = emptyListTitle.text
            emptyListSubtitle.accessibilityLabel = LocalizationConstants.Accessibility.subTitle
            emptyListSubtitle.accessibilityValue = emptyListSubtitle.text
        }
        
        // If loading the first page or missing pagination scroll to top
        let scrollToTop = pagination?.skipCount == 0 || pagination == nil
        let stopLoadingAndScrollToTop = { [weak self] in
            guard let sSelf = self else { return }
            
            sSelf.stopLoading()
            if scrollToTop {
                sSelf.scrollToSection(0)
            }
        }
        
        if error == nil {
            reloadDataSource()
            stopLoadingAndScrollToTop()
            listActionDelegate?.didUpdateList(in: self, error: error, pagination: pagination, source: source)
        } else {
            stopLoadingAndScrollToTop()
        }
    }

    func forceDisplayRefresh(for indexPath: IndexPath) {
        guard let model = pageController?.dataSource else { return }
        if model.listNodes().indices.contains(indexPath.row) {
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

// MARK: - ListComponentViewModelDelegate

extension ListComponentViewController: ListComponentViewModelDelegate {
    func didUpdateListActionState(enable: Bool) {
        listActionButton.isEnabled = enable
    }
}

// MARK: - ListComponentDataSourceDelegate

extension ListComponentViewController: ListComponentDataSourceDelegate {
    func shouldDisplayListLoadingIndicator() -> Bool {
        guard let displayLoadingIndicator = pageController?.shouldDisplayNextPageLoadingIndicator else { return false }
        return displayLoadingIndicator
    }
}

// MARK: - Uploading File Banner
extension ListComponentViewController {
    
    @objc private func handleSyncStartedNotification(notification: Notification) {
        guard let viewModel = self.viewModel else { return }
        if viewModel.shouldDisplaySyncBanner() {
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                sSelf.checkForUploadingFilesBanner()
            }
        }
    }
    
    func checkForUploadingFilesBanner() {
        guard let viewModel = self.viewModel else { return }
        if viewModel.model is RecentModel {
            let totalNodes = SyncBannerService.totalUploadNodes()
            let uploadedNodes = SyncBannerService.totalUploadedNodes()
            let totalUploadNodes = totalNodes + uploadedNodes
            if totalUploadNodes > 0 {
                showUploadNotification(uploadedCount: uploadedNodes, totalCount: totalUploadNodes)
            }
            if viewModel.shouldDisplaySyncBanner() && totalNodes > 0 && uploadingBannerView.alpha == 0 {
                uploadingBannerView.alpha = 1
                uploadingBannerHeight.constant = bannerHeight
            }
            reloadUploadingFilesBanner(for: totalNodes, uploadedNodes: uploadedNodes)
        }
    }
    
    func reloadUploadingFilesBanner(for totalNodes: Int, uploadedNodes: Int) {
        if totalNodes == 0 && uploadedNodes != 0 {
            uploadingFilesImageView.image = UIImage(named: "ic-action-sync-done")
            let count = totalNodes != 0 ? totalNodes: uploadedNodes
            uploadingFilesLabel.text = String(format: LocalizationConstants.AppExtension.finishedUploadingMessage, count)
            uploadingPercentageLabel.text = "100%"
            uploadingProgressView.progress = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.removeUploadingFileBanner()
                SyncBannerService.removeAllUploadedNodesFromDatabase()
            })
        } else if totalNodes != 0 {
            let progress = SyncBannerService.calculateProgress()
            let progressPercentage = progress*100.0
            uploadingFilesImageView.image = UIImage(named: "ic-action-sync-uploads")
            uploadingFilesLabel.text = String(format: LocalizationConstants.AppExtension.uploadingFiles, totalNodes)
            uploadingPercentageLabel.text = String(format: "%.2f%%", progressPercentage)
            uploadingProgressView.progress = progress
        }
    }
    
    // MARK: - Show Progress using local notification.
    
    func showUploadNotification(uploadedCount: Int, totalCount: Int) {
        guard uploadedCount > 0 else { return }
        
        // Prevent duplicates (same count and total)
        if uploadedCount == lastUploadedCount && totalCount == lastTotalCount {
            return //Skipping duplicate notification
        }
        
        lastUploadedCount = uploadedCount
        lastTotalCount = totalCount
        
        let message: String
        if uploadedCount >= totalCount {
            // Only show once
            guard !didShowFinalNotification else { return }
            message = "\(LocalizationConstants.AppExtension.finished): \(uploadedCount)/\(totalCount) \(LocalizationConstants.Accessibility.uploaded)"
            didShowFinalNotification = true
        } else {
            message = "\(uploadedCount)/\(totalCount) \(LocalizationConstants.Accessibility.uploaded)"

        }
        
        let content = UNMutableNotificationContent()
        content.title = LocalizationConstants.AppExtension.uploadingFilesTitle
        content.body = message
        content.sound = .default
        content.threadIdentifier = "UploadProgress"
        
        let request = UNNotificationRequest(identifier: "UploadProgressNotification",
                                            content: content,
                                            trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error posting notification: \(error.localizedDescription)")
            }
        }
    }
    
    func removeUploadingFileBanner() {
        self.uploadingBannerHeight.constant = 0
        self.uploadingBannerView.alpha = 0
    }
    
    @IBAction func didTapUploadListButtonAction(_ sender: Any) {
        if let listItemActionDelegate = listItemActionDelegate {
            listItemActionDelegate.showUploadingFiles()
        }
    }
}

// MARK: - Multi selection of files and folders

extension ListComponentViewController {
    func handleAddRemoveNodeList(node: ListNode) {
        if node.guid != "0" {
            var selectedMultipleItems = viewModel?.selectedMultipleItems ?? []
            if selectedMultipleItems.contains(node) {
                if let index = selectedMultipleItems.firstIndex(where: {$0 == node}) {
                    selectedMultipleItems.remove(at: index)
                }
            } else if selectedMultipleItems.count < APIConstants.multipleActionMaxSize {
                selectedMultipleItems.append(node)
            } else {
                let message = String(format: LocalizationConstants.MultipleFilesSelection.maximumFileSelectionMessage, APIConstants.multipleActionMaxSize)
                Snackbar.display(with: message,
                                 type: .approve,
                                 presentationHostViewOverride: appDelegate()?.window,
                                 finish: nil)
            }
            
            viewModel?.selectedMultipleItems = selectedMultipleItems
            updateMultiSelectionHeader()
            showElementsCount()
            if selectedMultipleItems.isEmpty {
                resetMultipleSelectionView()
            }
            collectionView?.reloadData()
        }
    }
    
    private func updateMultiSelectionHeader() {
        if let multipleSelectionHeader = self.multipleSelectionHeader {
            
            guard let viewModel = self.viewModel else { return }
            let isMultiSelectEnabled = viewModel.isMultiFileAvailable
            let isThrashedNodeAvailable = viewModel.selectedMultipleItems.contains { $0.trashed }
            if isThrashedNodeAvailable {
                multipleSelectionHeader.moreButton.isEnabled = viewModel.isTrashAvailable
            } else {
                let isFolderNodeAvailable = viewModel.selectedMultipleItems.contains { $0.isFolder }
                if isFolderNodeAvailable {
                    multipleSelectionHeader.moreButton.isEnabled = viewModel.isMultiFolderAvailable
                } else {
                    multipleSelectionHeader.moreButton.isEnabled = isMultiSelectEnabled
                }
            }
            
            multipleSelectionHeader.moveButton.isEnabled = isMultiSelectEnabled ? viewModel.checkMoveEnabled() : false
        }
    }
    
    private func showMultiSelectionHeader() {
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        if let multipleSelectionHeader = self.multipleSelectionHeader, let navBar = self.navigationViewController?.navigationBar {
            if multipleSelectionHeader.isDescendant(of: navBar) { return }
           
            multipleSelectionHeader.frame = CGRect(x: 0, y: 0, width: navBar.frame.size.width, height: navBar.frame.size.height)
            multipleSelectionHeader.applyComponentsThemes(currentTheme)
            navBar.addSubview(multipleSelectionHeader)
            showElementsCount()
            toggleInteractivePopGestureRecognizer(isEnabled: false)
            
            if viewModel is TrashViewModel || viewModel is OfflineViewModel {
                multipleSelectionHeader.moveButton.isHidden = true
            }

            multipleSelectionHeader.didSelectResetButtonAction = {[weak self] in
                guard let sSelf = self else { return }
                sSelf.resetMultipleSelectionView()
            }
            
            multipleSelectionHeader.didSelectMoreButtonAction = {[weak self] in
                guard let sSelf = self,
                      let model = sSelf.pageController?.dataSource else { return }
                
                let nodes = sSelf.viewModel?.selectedMultipleItems ?? []
                sSelf.listItemActionDelegate?.showActionSheetForMultiSelectListItem(for: nodes,
                                                                                    from: model,
                                                                                    delegate: sSelf)
            }
            
            multipleSelectionHeader.didSelectMoveButtonAction = {[weak self] in
                guard let sSelf = self,
                      let model = sSelf.pageController?.dataSource else { return }
                let connectivityService = sSelf.coordinatorServices?.connectivityService
                if connectivityService?.hasInternetConnection() == false {
                    sSelf.showToastForInternetConnectivity()
                    return
                }
              
                let nodes = sSelf.viewModel?.selectedMultipleItems ?? []
                sSelf.listItemActionDelegate?.didSelectMoveMultipleListItems(for: nodes,
                                                                             from: model,
                                                                             delegate: sSelf)
            }
        }
    }
    
    private func showToastForInternetConnectivity() {
        Snackbar.display(with: LocalizationConstants.Dialog.internetUnavailableMessage,
                         type: .approve,
                         presentationHostViewOverride: appDelegate()?.window,
                         finish: nil)
    }

    private func hideMultipleSelectionHeader() {
        if let multipleSelectionHeader = self.multipleSelectionHeader {
            multipleSelectionHeader.removeFromSuperview()
        }
    }
    
    func showElementsCount() {
        if let multipleSelectionHeader = self.multipleSelectionHeader {
            let itemsCount = String(format: LocalizationConstants.MultipleFilesSelection.multipleItemsCount, viewModel?.selectedMultipleItems.count ?? 0)
            multipleSelectionHeader.updateTitle(text: itemsCount)
        }
    }
    
    func resetMultipleSelectionView() {
        viewModel?.selectedMultipleItems.removeAll()
        listActionDelegate?.enabledLongTapGestureForMultiSelection(isShowTabbar: true)
        createButton?.isHidden = !(viewModel?.shouldDisplayCreateButton() ?? true)
        listActionButton?.isHidden = !(viewModel?.shouldDisplayListActionButton() ?? true)
        hideMultipleSelectionHeader()
        viewModel?.isMultipleFileSelectionEnabled = false
        toggleInteractivePopGestureRecognizer(isEnabled: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {[weak self] in
            guard let sSelf = self else { return }
            sSelf.collectionView.reloadData()
        })
    }
    
    private func toggleInteractivePopGestureRecognizer(isEnabled: Bool) {
        if let navigationViewController = self.navigationViewController {
            navigationViewController.interactivePopGestureRecognizer?.isEnabled = isEnabled
        }
    }
}

// MARK: - Storyboard Instantiable

extension ListComponentViewController: StoryboardInstantiable {}
