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
import MaterialComponents.MaterialDialogs

class CreateNodeSheetCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var createNodeSheetViewController: CreateNodeSheetViewControler?
    private let actionMenu: ActionMenu
    private let parentListNode: ListNode
    private weak var createNodeViewModelDelegate: CreateNodeViewModelDelegate?
    private var dialogTransitionController: MDCDialogTransitionController

    init(with presenter: UINavigationController,
         actionMenu: ActionMenu,
         parentListNode: ListNode,
         createNodeViewModelDelegate: CreateNodeViewModelDelegate?) {

        self.presenter = presenter
        self.actionMenu = actionMenu
        self.parentListNode = parentListNode
        self.createNodeViewModelDelegate = createNodeViewModelDelegate
        self.dialogTransitionController = MDCDialogTransitionController()
    }

    func start() {
        let viewController = CreateNodeSheetViewControler.instantiateViewController()
        let extractedExpr = CreateNodeViewModel(with: actionMenu,
                                                parentListNode: parentListNode,
                                                coordinatorServices: coordinatorServices,
                                                delegate: createNodeViewModelDelegate)
        let createNodeViewModel = extractedExpr

        viewController.coordinatorServices = coordinatorServices
        viewController.createNodeViewModel = createNodeViewModel
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = dialogTransitionController
        viewController.mdc_dialogPresentationController?.dismissOnBackgroundTap = false
        createNodeSheetViewController = viewController
        presenter.present(viewController, animated: true)
    }
}
