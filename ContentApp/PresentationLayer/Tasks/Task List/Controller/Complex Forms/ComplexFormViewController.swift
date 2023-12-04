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
    }
}
