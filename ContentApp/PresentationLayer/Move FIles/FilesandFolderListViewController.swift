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

class FilesandFolderListViewController: SystemThemableViewController {
    private let searchButtonAspectRatio: CGFloat = 30.0
    private var browseTopLevelFolderScreenCoordinator: BrowseTopLevelFolderScreenCoordinator?
    
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        activateTheme()
        showPersonalFiles()
    }
    
    private func activateTheme() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.hidesBackButton = true
    }
    
    // MARK: - Show Personal Files
    func showPersonalFiles() {
        if let navigationViewController = self.navigationController {
            let browseNode = BrowseNode(type: .personalFiles)
            let staticFolderScreenCoordinator =
            BrowseTopLevelFolderScreenCoordinator(with: navigationViewController,
                                                  browseNode: browseNode)
            appDelegate()?.isMoveFilesAndFolderFlow = true
            staticFolderScreenCoordinator.start()
            self.browseTopLevelFolderScreenCoordinator = staticFolderScreenCoordinator
        }
    }
    
}

// MARK: - Storyboard Instantiable

extension FilesandFolderListViewController: StoryboardInstantiable {}
