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
import MaterialComponents.MaterialDialogs
import AlfrescoAuth
import AlfrescoCore
import AlfrescoContent

class BrowseViewController: UIViewController {
    lazy var viewModel = BrowseViewModel()
    var paginationEnabled = true
    var currentPage = 1
    var pageSkipCount = 0
    var totalItems: Int64 = 0
    var hasMoreItems = true
    var shouldDisplayNextPageLoadingIndicator = false
    private var shouldRefreshList = true
    private var requestInProgress = false

    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshList()
    }
    
    func refreshList() {
        currentPage = 1
        hasMoreItems = true
        shouldRefreshList = true
        fetchNextPage()
    }
    
    func fetchNextPage() {
        let connectivityService = ApplicationBootstrap.shared().repository.service(of: ConnectivityService.identifier) as? ConnectivityService
        if connectivityService?.hasInternetConnection() == false {
            showAlertInternetUnavailable()
            return
        }

        if hasMoreItems && !requestInProgress {
            if shouldRefreshList {
                pageSkipCount = 0
                shouldRefreshList = false
            } else {
                pageSkipCount = viewModel.rawListNodes.isEmpty ? 0 : viewModel.rawListNodes.count
            }
            let nextPage = RequestPagination(maxItems: APIConstants.pageSize,
                                             skipCount: pageSkipCount)
            requestInProgress = true
            viewModel.fetchItems(with: nextPage) { [weak self] paginatedResponse in
                guard let sSelf = self else { return }
                print("Paginated response: \(paginatedResponse)")
                //sSelf.handlePaginatedResponse(response: paginatedResponse)
            }
        }
    }
    
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
}
