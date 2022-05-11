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
import MaterialComponents.MaterialActivityIndicator
import MaterialComponents.MaterialProgressView
import Micro
import MobileCoreServices

class ListComponentViewController: SystemThemableViewController {
    @IBOutlet weak var collectionView: PageFetchableCollectionView!
    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListTitle: UILabel!
    @IBOutlet weak var emptyListSubtitle: UILabel!
    @IBOutlet weak var emptyListImageView: UIImageView!
    @IBOutlet weak var progressView: MDCProgressView!
    @IBOutlet weak var uploadButton: MDCButton!
    @IBOutlet weak var cancelButton: MDCButton!
    @IBOutlet weak var uploadFilesView: UIView!
    
    var refreshControl: UIRefreshControl?
    var pageController: ListPageController?
    var viewModel: ListComponentViewModel?
    var dataSource: ListComponentDataSource?
    
    weak var listActionDelegate: ListComponentActionDelegate?
    weak var listItemActionDelegate: ListItemActionDelegate?
    private var kvoConnectivity: NSKeyValueObservation?
    private let listBottomInset: CGFloat = 70.0
    weak var fileManagerDelegate: FileManagerAssetDelegate?
    var fileManagerDataSource: FileManagerDataSource?

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure collection view data source and delegate
        guard let viewModel = self.viewModel else { return }
        let services = coordinatorServices
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
        uploadFilesView.isHidden = !viewModel.shouldDisplayListActionButton()
        
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
        observeConnectivity()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handleConnectivity()
        collectionView.reloadData()
        
        let activeTheme = coordinatorServices.themingService?.activeTheme
        progressView.progressTintColor = activeTheme?.primaryT1Color
        progressView.trackTintColor = activeTheme?.primary30T1Color
    }
    
    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
        progressView.progressTintColor = coordinatorServices.themingService?.activeTheme?.primaryT1Color
        progressView.trackTintColor =
        coordinatorServices.themingService?.activeTheme?.primary30T1Color
    }
    
    @IBAction func uploadButtonAction(_ sender: Any) {
        if let decoded = UserDefaultsModel.value(for: KeyConstants.AppGroup.sharedFiles) as? Data {
            if let decodedURLs = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as? [URL] {
                fileManagerDataSource?.fetchSelectedAssets(for: decodedURLs, and: fileManagerDelegate)
            }
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        let notificationName = Notification.Name(rawValue: KeyConstants.Notification.dismissAppExtensionNotification)
        let notification = Notification(name: notificationName)
        NotificationCenter.default.post(notification)
    }
    
    // MARK: - Public interface
    
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        
        guard let currentTheme = coordinatorServices.themingService?.activeTheme,
              let bigButtonScheme = coordinatorServices.themingService?.containerScheming(for: .loginBigButton),
              let buttonScheme = coordinatorServices.themingService?.containerScheming(for: .dialogButton)
        else { return }
        emptyListTitle.applyeStyleHeadline6OnSurface(theme: currentTheme)
        emptyListTitle.textAlignment = .center
        emptyListSubtitle.applyStyleBody2OnSurface60(theme: currentTheme)
        emptyListSubtitle.textAlignment = .center
        refreshControl?.tintColor = currentTheme.primaryT1Color
        
        uploadFilesView.backgroundColor = currentTheme.surfaceColor
        uploadButton.applyContainedTheme(withScheme: buttonScheme)
        uploadButton.isUppercaseTitle = false
        uploadButton.setTitle(LocalizationConstants.AppExtension.upload, for: .normal)
        uploadButton.layer.cornerRadius = UIConstants.cornerRadiusDialog
        uploadButton.setShadowColor(.clear, for: .normal)
        
        cancelButton.applyContainedTheme(withScheme: bigButtonScheme)
        cancelButton.setBackgroundColor(currentTheme.onSurface5Color, for: .normal)
        cancelButton.isUppercaseTitle = false
        cancelButton.setShadowColor(.clear, for: .normal)
        cancelButton.setTitle(LocalizationConstants.General.cancel, for: .normal)
        cancelButton.setTitleColor(currentTheme.onSurfaceColor, for: .normal)
        cancelButton.layer.cornerRadius = UIConstants.cornerRadiusDialog
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
                            if viewModel.shouldPreviewNode(at: context.indexPath) == false { return }
                            if node.trashed == false {
                                sSelf.listItemActionDelegate?.showPreview(for: node,
                                                                          from: model)
                                sSelf.listActionDelegate?.elementTapped(node: node)
                            }
                        }
                    }
            }
        }
        
        self.forceRefresh(with: indexPaths)
    }
    
    private func forceRefresh(with indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            self.forceDisplayRefresh(for: indexPath)
        }
    }
    
    // MARK: Connectivity Helpers
    
    private func observeConnectivity() {
        let connectivityService = coordinatorServices.connectivityService
        kvoConnectivity = connectivityService?.observe(\.status,
                                                       options: [.new],
                                                       changeHandler: { [weak self] (_, _) in
                                                        guard let sSelf = self else { return }
                                                        sSelf.handleConnectivity()
                                                        sSelf.collectionView.reloadData()
                                                       })
    }
    
    private func handleConnectivity() {
        let connectivityService = coordinatorServices.connectivityService
        if connectivityService?.hasInternetConnection() == false {
            didUpdateList(error: NSError(), pagination: nil)
            
            if viewModel?.shouldDisplayPullToRefreshOffline() == false {
                refreshControl?.removeFromSuperview()
            }
        } else {
            if let refreshControl = self.refreshControl, refreshControl.superview == nil {
                collectionView.addSubview(refreshControl)
            }
        }
        uploadButton.isEnabled = connectivityService?.hasInternetConnection() ?? false
    }
    
    internal func isPaginationEnabled() -> Bool {
        guard let isPaginationEnabled = pageController?.isPaginationEnabled() else { return true }
        return isPaginationEnabled
    }
}

// MARK: - ListElementCollectionViewCell Delegate

extension ListComponentViewController: ListElementCollectionViewCellDelegate {
    func moreButtonTapped(for element: ListNode?, in cell: ListElementCollectionViewCell) {
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
                       pagination: Pagination?) {
        guard let model = pageController?.dataSource else { return }
        
        // When no error or pagination information is present just perform a data source reload
        // as this might be a filter action
        if error == nil && pagination == nil {
            reloadDataSource()
            return
        }
        uploadButton.isHidden = !(viewModel?.shouldDisplayListActionButton() ?? false)
        let isListEmpty = model.isEmpty()
        emptyListView.isHidden = !isListEmpty
        if isListEmpty {
            let emptyList = viewModel?.emptyList()
            emptyListImageView.image = emptyList?.icon
            emptyListTitle.text = emptyList?.title
            emptyListSubtitle.text = emptyList?.description
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
            listActionDelegate?.didUpdateList(in: self, error: error, pagination: pagination)
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
        uploadButton.isEnabled = enable
    }
}

// MARK: - ListComponentDataSourceDelegate

extension ListComponentViewController: ListComponentDataSourceDelegate {
    func shouldDisplayListLoadingIndicator() -> Bool {
        guard let displayLoadingIndicator = pageController?.shouldDisplayNextPageLoadingIndicator else { return false }
        return displayLoadingIndicator
    }
}

// MARK: - Storyboard Instantiable

extension ListComponentViewController: StoryboardInstantiable {}

