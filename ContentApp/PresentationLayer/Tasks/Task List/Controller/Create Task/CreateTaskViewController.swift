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
import MaterialComponents

class CreateTaskViewController: SystemSearchViewController {

    private let searchButtonAspectRatio: CGFloat = 30.0
    var viewModel: CreateTaskViewModel { return controller.viewModel }
    lazy var controller: CreateTaskController = { return CreateTaskController( currentTheme: coordinatorServices?.themingService?.activeTheme) }()
    
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        AlfrescoLog.debug("Jai Shri Ram. JHMPPWPBJASHJH")
        
        navigationController?.navigationBar.barTintColor = UIColor.green
        viewModel.services = coordinatorServices ?? CoordinatorServices()
        addBackButton()
    }
    
    private func addBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.accessibilityIdentifier = "backButton"
        backButton.frame = CGRect(x: 0.0, y: 0.0,
                                    width: searchButtonAspectRatio,
                                    height: searchButtonAspectRatio)
        backButton.imageView?.contentMode = .scaleAspectFill
        backButton.layer.masksToBounds = true
        backButton.addTarget(self,
                               action: #selector(backButtonTapped),
                               for: UIControl.Event.touchUpInside)
        backButton.setImage(UIImage(named: "ic-close"),
                              for: .normal)

        let searchBarButtonItem = UIBarButtonItem(customView: backButton)
        searchBarButtonItem.accessibilityIdentifier = "backBarButton"
        let currWidth = searchBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: searchButtonAspectRatio)
        currWidth?.isActive = true
        let currHeight = searchBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: searchButtonAspectRatio)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = searchBarButtonItem
    }
}
