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
import MaterialComponents.MaterialBottomSheet

class MultipleFileActionMenuScreenCoordinator: NSObject, Coordinator {
    private let presenter: UINavigationController
    private var actionMenuViewController: MultipleSelectionActionMenuViewController?
    private let actionMenuViewModel: MultipleSelectionActionMenuViewModel
    private let dismissHandler: () -> Void
    private var listNodes: [ListNode]

    init(with presenter: UINavigationController,
         actionMenuViewModel: MultipleSelectionActionMenuViewModel,
         listNodes: [ListNode],
         dismissHandler: @escaping () -> Void = {}) {
        self.presenter = presenter
        self.actionMenuViewModel = actionMenuViewModel
        self.listNodes = listNodes
        self.dismissHandler = dismissHandler
    }

    func start() {
        
        let viewController = MultipleSelectionActionMenuViewController.instantiateViewController()
        let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.delegate = self
        viewController.coordinatorServices = coordinatorServices
        viewController.actionMenuModel = actionMenuViewModel
        presenter.present(bottomSheet, animated: true, completion: nil)
        actionMenuViewController = viewController
    }
}

extension MultipleFileActionMenuScreenCoordinator: MDCBottomSheetControllerDelegate {
    func bottomSheetControllerStateChanged(_ controller: MDCBottomSheetController,
                                           state: MDCSheetState) {
        if state == .closed {
            dismissHandler()
        }
    }

    func bottomSheetControllerDidDismissBottomSheet(_ controller: MDCBottomSheetController) {
        dismissHandler()
    }
}
