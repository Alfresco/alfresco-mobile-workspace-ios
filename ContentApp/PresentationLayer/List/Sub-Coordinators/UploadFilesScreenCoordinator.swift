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

class UploadFilesScreenCoordinator: PresentingCoordinator {
    private let presenter: UINavigationController
    private var uploadFilesViewController: UploadFilesViewController?
    private var model: UploadNodesModel?

    init(with presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    override func start() {
        let viewModelFactory = UploadNodesViewModelFactory(services: coordinatorServices)
        let folderChildrenDataSource = viewModelFactory.uploadNodesDataSource()
        self.model = viewModelFactory.model

        let viewController = UploadFilesViewController.instantiateViewController()
        viewController.title = LocalizationConstants.ScreenTitles.transferFiles
        AnalyticsManager.shared.pageViewEvent(for: Event.Page.transfers)
        uploadFilesViewController = viewController

        let viewModel = folderChildrenDataSource
        viewController.listViewModel = viewModel
        viewController.coordinatorServices = coordinatorServices
        presenter.pushViewController(viewController, animated: true)
    }
}
