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

class ActionMenuScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var actionMenuViewController: ActionMenuViewController?
    private let actionMenuViewModel: ActionMenuViewModel
    private let nodeActionViewModel: NodeActionsViewModel

    init(with presenter: UINavigationController,
         actionMenuViewModel: ActionMenuViewModel,
         nodeActionViewModel: NodeActionsViewModel) {
        self.presenter = presenter
        self.actionMenuViewModel = actionMenuViewModel
        self.nodeActionViewModel = nodeActionViewModel
    }

    func start() {
        let themingService = repository.service(of: MaterialDesignThemingService.identifier) as? MaterialDesignThemingService
        let viewController = ActionMenuViewController.instantiateViewController()
        let bottomSheet = MDCBottomSheetController(contentViewController: viewController)

        viewController.themingService = themingService
        viewController.actionMenuModel = actionMenuViewModel
        viewController.nodeActionsModel = nodeActionViewModel
        presenter.present(bottomSheet, animated: true, completion: nil)
        actionMenuViewController = viewController
    }
}
