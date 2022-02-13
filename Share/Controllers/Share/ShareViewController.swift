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
import Social
import MobileCoreServices
import UniformTypeIdentifiers
import AlfrescoAuth
import AlfrescoCore
import AlfrescoContent
import JWTDecode
import FastCoding
import MaterialComponents.MaterialDialogs
import MaterialComponents.MaterialProgressView
import Micro

@objc(ShareExtensionViewController)
class ShareViewController: UIViewController {
    @IBOutlet weak var collectionView: PageFetchableCollectionView!
    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListTitle: UILabel!
    @IBOutlet weak var emptyListSubtitle: UILabel!
    @IBOutlet weak var emptyListImageView: UIImageView!

    lazy var viewModel = ShareViewModel()
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressView: MDCProgressView!
        
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        activateTheme()
        setupProgressView()
        applyComponentsThemes()
        applyLocalization()
        registerNotifications()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.checkForUserSession()
        }
    }
    
    private func activateTheme() {
        let themingService = viewModel.repository.service(of: MaterialDesignThemingService.identifier) as? MaterialDesignThemingService
        themingService?.activateAutoTheme(for: UIScreen.main.traitCollection.userInterfaceStyle)
    }
    
    private func registerNotifications() {
        // unauthorized Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleUnauthorizedAPIAccess(notification:)),
                                               name: Notification.Name(KeyConstants.Notification.unauthorizedRequest),
                                               object: nil)
        
        // ReSignIn Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleReSignIn(notification:)),
                                               name: Notification.Name(KeyConstants.Notification.reSignin),
                                               object: nil)
    }
        
    private func setupProgressView() {
        progressView.progress = 0
        progressView.mode = .indeterminate
        view.bringSubviewToFront(progressView)
        progressView.alpha = 0
    }
    
    private func startLoading() {
        progressView.alpha = 1
        progressView.startAnimating()
        progressView.setHidden(false, animated: false)
    }

    private func stopLoading() {
        progressView.stopAnimating()
        progressView.setHidden(true, animated: false)
    }

    private func applyComponentsThemes() {
        guard let currentTheme = self.viewModel.themingService?.activeTheme else { return }
        view.backgroundColor = currentTheme.surfaceColor
        headerView.backgroundColor = currentTheme.surfaceColor
        backButton.tintColor = currentTheme.onSurfaceColor
        titleLabel.applyeStyleHeadline6OnSurface(theme: currentTheme)
        titleLabel.textAlignment = .center
    }
    
    private func applyLocalization() {
        if viewModel.browseType == .personalFiles {
            titleLabel.text = LocalizationConstants.BrowseStaticList.personalFiles
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        if viewModel.browseType == .personalFiles {
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Check for user session
    func checkForUserSession() {
        startLoading()
        if let activeAccountIdentifier = UserDefaultsModel.value(for: KeyConstants.Save.activeAccountIdentifier) as? String {
            let parameters = AuthenticationParameters.parameters(for: activeAccountIdentifier)

            // Check account type whether it's Basic or AIMS
            if let activeAccountPassword = Keychain.string(forKey: activeAccountIdentifier) {
                let basicAuthCredential = BasicAuthCredential(username: activeAccountIdentifier, password: activeAccountPassword)
                let account = BasicAuthAccount(with: parameters, credential: basicAuthCredential)
                registerAndPresent(account: account)
            } else if let activeAccountSessionData = Keychain.data(forKey: "\(activeAccountIdentifier)-\(String(describing: AlfrescoAuthSession.self))"),
                let activeAccountCredentialData = Keychain.data(forKey: "\(activeAccountIdentifier)-\(String(describing: AlfrescoCredential.self))") {
                do {
                    let decoder = JSONDecoder()
                    if let aimsSession = FastCoder.object(with: activeAccountSessionData) as? AlfrescoAuthSession {
                        let aimsCredential = try decoder.decode(AlfrescoCredential.self, from: activeAccountCredentialData)
                        let accountSession = AIMSSession(with: aimsSession, parameters: parameters, credential: aimsCredential)
                        let account = AIMSAccount(with: accountSession)
                        registerAndPresent(account: account)
                    }
                } catch {
                    AlfrescoLog.error("Unable to deserialize session information")
                }
            } else {
                showAlertToRegisterInTheApp()
            }
        } else {
            showAlertToRegisterInTheApp()
        }
    }
    
    private func showAlertToRegisterInTheApp() {
        stopLoading()
        let title = LocalizationConstants.Dialog.sessionUnavailableTitle
        let message = LocalizationConstants.Dialog.sessionUnavailableMessage
        let confirmAction = MDCAlertAction(title: LocalizationConstants.General.ok) { [weak self] _ in
            guard let sSelf = self else { return }
            sSelf.openMainApp()
        }
        confirmAction.accessibilityIdentifier = "confirmActionButton"
        _ = self.showDialog(title: title,
                                       message: message,
                                       actions: [confirmAction],
                                       completionHandler: {})
    }
    
    private func openMainApp() {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: { _ in
            guard let url = URL(string: KeyConstants.AppGroup.appURLString) else { return }
            _ = self.openURL(url)
        })
    }
    
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
    
    private func registerAndPresent(account: AccountProtocol) {
        stopLoading()
        AlfrescoContentAPI.basePath = account.apiBasePath
        self.viewModel.accountService?.register(account: account)
        self.viewModel.accountService?.activeAccount = account
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            self.refreshList()
        }
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        print("loginButtonAction")
        let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "BrowseViewController") as? BrowseViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
            
    private func handleSharedFile() {
        // extracting the path to the URL that is being shared
        let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        let contentType = kUTTypeData as String
        for provider in attachments {
            // Check if the content type is the same as we expected
            if provider.hasItemConformingToTypeIdentifier(contentType) {
                provider.loadItem(forTypeIdentifier: contentType,
                                  options: nil) { [unowned self] (data, error) in
                    // Handle the error here if you want
                    guard error == nil else { return }
                    
                    if let url = data as? URL,
                       let imageData = try? Data(contentsOf: url) {
                        //self.save(imageData, key: "imageData", value: imageData)
                      //  self.viewModel.appURLString += "imageData"
                    } else {
                        // Handle this situation as you prefer
                        fatalError("Impossible to save image")
                    }
                }}
        }
    }
}

// MARK: - Notifications
extension ShareViewController {
    @objc private func handleUnauthorizedAPIAccess(notification: Notification) {
        let title = LocalizationConstants.Dialog.sessionExpiredTitle
        let message = LocalizationConstants.Dialog.sessionExpiredMessage

        let confirmAction = MDCAlertAction(title: LocalizationConstants.Buttons.signin) { [weak self] _ in
            guard let sSelf = self else { return }
            sSelf.viewModel.accountService?.activeAccount?.reSignIn(onViewController: self)
        }
        confirmAction.accessibilityIdentifier = "confirmActionButton"
        
        let cancelAction = MDCAlertAction(title: LocalizationConstants.General.cancel) { _ in
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
        cancelAction.accessibilityIdentifier = "cancelActionButton"

        _ = self.showDialog(title: title,
                                       message: message,
                                       actions: [confirmAction, cancelAction],
                                       completionHandler: {})
    }
    
    @objc private func handleReSignIn(notification: Notification) {
        self.refreshList()
    }
}

// MARK: - APIs for Files and Folder
extension ShareViewController {
    private func showAlertInternetUnavailable() {
        let title = LocalizationConstants.Dialog.internetUnavailableTitle
        let message = LocalizationConstants.Dialog.internetUnavailableMessage
        let confirmAction = MDCAlertAction(title: LocalizationConstants.General.ok) { [weak self] _ in
            guard let sSelf = self else { return }
            sSelf.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
        confirmAction.accessibilityIdentifier = "confirmActionButton"
        _ = self.showDialog(title: title,
                                       message: message,
                                       actions: [confirmAction],
                                       completionHandler: {})
    }
    
    func refreshList() {
        viewModel.currentPage = 1
        viewModel.hasMoreItems = true
        viewModel.shouldRefreshList = true
        fetchNextPage()
    }
    
    func fetchNextPage() {
        let connectivityService = ApplicationBootstrap.shared().repository.service(of: ConnectivityService.identifier) as? ConnectivityService
        if connectivityService?.hasInternetConnection() == false {
            showAlertInternetUnavailable()
            return
        }

        if viewModel.hasMoreItems && !viewModel.requestInProgress {
            if viewModel.shouldRefreshList {
                viewModel.pageSkipCount = 0
                viewModel.shouldRefreshList = false
            } else {
                viewModel.pageSkipCount = viewModel.rawListNodes.isEmpty ? 0 : viewModel.rawListNodes.count
            }
            let nextPage = RequestPagination(maxItems: APIConstants.pageSize,
                                             skipCount: viewModel.pageSkipCount)
            viewModel.requestInProgress = true
            viewModel.fetchItems(with: nextPage) { [weak self] paginatedResponse in
                guard let sSelf = self else { return }
                print("Paginated response: \(paginatedResponse)")
                sSelf.handlePaginatedResponse(response: paginatedResponse)
            }
        }
    }
   
    // MARK: - Private interface
    private func handlePaginatedResponse(response: PaginatedResponse) {
        viewModel.requestInProgress = false
        if let error = response.error {
            update(with: [],
                   pagination: nil,
                   error: error)
        } else if let skipCount = response.responsePagination?.skipCount {
            let results = response.results
            viewModel.hasMoreItems =
                (Int64(results.count) + skipCount) == response.responsePagination?.totalItems ? false : true

            if response.requestPagination != nil && viewModel.hasMoreItems {
                incrementPage(for: response.requestPagination)
            }

            viewModel.totalItems = response.responsePagination?.maxItems ?? 0
            update(with: results,
                   pagination: response.responsePagination,
                   error: nil)
        }
    }
    
    private func update(with results: [ListNode],
                        pagination: Pagination?,
                        error: Error?) {
        if !results.isEmpty {
            if pagination?.skipCount != 0 {
                addNewResults(results: results, pagination: pagination)
            } else {
                addResults(results: results, pagination: pagination)
            }
        } else if pagination?.skipCount == 0 || error == nil {
            self.viewModel.rawListNodes = []
            if let totalItems = pagination?.totalItems {
                viewModel.shouldDisplayNextPageLoadingIndicator =
                (Int64(self.viewModel.rawListNodes.count) >= totalItems) ? false : true
            }
        }
        self.didUpdateList(error: error,
                                pagination: pagination)
    }

    private final func incrementPage(for paginationRequest: RequestPagination?) {
        if let pageSkipCount = paginationRequest?.skipCount {
            viewModel.currentPage = pageSkipCount / APIConstants.pageSize + 1
        }
    }
    
    private func addNewResults(results: [ListNode],
                               pagination: Pagination?) {
        if !results.isEmpty {
            let olderElementsSet = Set(self.viewModel.rawListNodes)
            let newElementsSet = Set(results)

            if !newElementsSet.isSubset(of: olderElementsSet) {
                self.viewModel.rawListNodes.append(contentsOf: results)
            }

            if let totalItems = pagination?.totalItems {
                // Because the list node collection could mutate in certain situations: upload,
                // consider counts past the raw collection size
                viewModel.shouldDisplayNextPageLoadingIndicator =
                (Int64(self.viewModel.rawListNodes.count) >= totalItems) ? false : true
            }
        }
    }

    private func addResults(results: [ListNode],
                            pagination: Pagination?) {
        if !results.isEmpty {
            self.viewModel.rawListNodes = results

            if let totalItems = pagination?.totalItems {
                // Because the list node collection could mutate in certain situations: upload,
                // consider counts past the raw collection size
                viewModel.shouldDisplayNextPageLoadingIndicator =
                    (Int64(results.count) >= totalItems) ? false : true
            }
        }
    }
}

extension ShareViewController {
    func didUpdateList(error: Error?,
                       pagination: Pagination?) {
        // When no error or pagination information is present just perform a data source reload
        // as this might be a filter action
        if error == nil && pagination == nil {
            reloadDataSource()
            return
        }
        
        let isListEmpty = viewModel.isEmpty()
        emptyListView.isHidden = !isListEmpty
        if isListEmpty {
            let emptyList = viewModel.emptyList()
            emptyListImageView.image = emptyList.icon
            emptyListTitle.text = emptyList.title
            emptyListSubtitle.text = emptyList.description
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
            self.stopLoading()
        } else {
            stopLoadingAndScrollToTop()
        }
    }

    func forceDisplayRefresh(for indexPath: IndexPath) {
        if viewModel.listNodes().indices.contains(indexPath.row) {
            collectionView.reloadItems(at: [indexPath])
        }
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
    
    private func reloadDataSource() {
        /*
        var indexPaths: [IndexPath] = []
        dataSource.state = forEach(viewModel.listNodes()) { listNode in
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
                            } else {
                                sSelf.listItemActionDelegate?.showActionSheetForListItem(for: node,
                                                                                         from: model,
                                                                                         delegate: sSelf)
                            }
                        }
                    }
            }
        }
        
        self.forceRefresh(with: indexPaths)
        */
    }
}
