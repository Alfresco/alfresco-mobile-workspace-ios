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

class BasicAuthScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var basicAuthViewController: BasicAuthViewController?

    init(with presenter: UINavigationController) {
        self.presenter = presenter
    }

    func start() {
        let viewController = BasicAuthViewController.instantiateViewController()
        basicAuthViewController = viewController
        basicAuthViewController?.themingService = self.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        basicAuthViewController?.viewModel = BasicAuthViewModel(with: self.serviceRepository.service(of: LoginService.serviceIdentifier) as? LoginService)
        presenter.pushViewController(viewController, animated: kPushAnimation)
    }
}
