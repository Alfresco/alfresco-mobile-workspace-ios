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

protocol BrowseScreenCoordinatorDelegate: AnyObject {
    func showTopLevelFolderScreen(from browseNode: BrowseNode)
}

class BrowseScreenCoordinator: PresentingCoordinator,
                               ListCoordinatorProtocol {
    private let presenter: UINavigationController
    private var browseNode: BrowseNode
    private var browseViewController: BrowseViewController?
    private var navigationViewController: UINavigationController?
    private var browseTopLevelFolderScreenCoordinator: BrowseTopLevelFolderScreenCoordinator?
    var nodeActionsModel: NodeActionsViewModel?
    private var createNodeSheetCoordinator: CreateNodeSheetCoordinator?
    
    init(with presenter: UINavigationController, browseNode: BrowseNode) {
        self.presenter = presenter
        self.browseNode = browseNode
    }

    override func start() {
        let viewModelFactory = BrowseViewModelFactory(services: coordinatorServices)
        let browseDataSource = viewModelFactory.browseDataSource()

        let viewController = BrowseViewController.instantiateViewController()
        viewController.title = LocalizationConstants.ScreenTitles.browse

        let searchViewModel = browseDataSource.globalSearchViewModel
        let browseViewModel = browseDataSource.browseViewModel
        let searchPageController = ListPageController(dataSource: searchViewModel.searchModel,
                                                      services: coordinatorServices)
        viewController.searchPageController = searchPageController

        viewController.listViewModel = browseViewModel
        viewController.searchViewModel = searchViewModel

        viewController.coordinatorServices = coordinatorServices
        viewController.browseScreenCoordinatorDelegate = self
        viewController.listItemActionDelegate = self

        self.navigationViewController = self.presenter
        self.browseViewController = viewController
        self.presenter.pushViewController(viewController, animated: false)
    }

    func scrollToTopOrPopToRoot() {
        navigationViewController?.popToRootViewController(animated: true)
        browseViewController?.cancelSearchMode()
    }
}

extension BrowseScreenCoordinator: BrowseScreenCoordinatorDelegate {
    func showTopLevelFolderScreen(from browseNode: BrowseNode) {
        if let navigationViewController = self.navigationViewController {
            let staticFolderScreenCoordinator =
                BrowseTopLevelFolderScreenCoordinator(with: navigationViewController,
                                                      browseNode: browseNode)
            staticFolderScreenCoordinator.start()
            self.browseTopLevelFolderScreenCoordinator = staticFolderScreenCoordinator
        }
    }
}

extension BrowseScreenCoordinator: ListItemActionDelegate {
    func showPreview(for node: ListNode,
                     from dataSource: ListComponentModelProtocol) {
    }
    func showNodeCreationDialog(with actionMenu: ActionMenu,
                                delegate: CreateNodeViewModelDelegate?) {
    }
    
    func showActionSheetForMultiSelectListItem(for nodes: [ListNode],
                                               from dataSource: ListComponentModelProtocol,
                                               delegate: NodeActionsViewModelDelegate) {
        // do nothing
    }
}
