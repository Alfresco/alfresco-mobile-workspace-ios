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
    var sourceNodeToMove: [ListNode]?
    var didSelectDismissAction: ((String?) -> Void)?

    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleFilesFolderMoveFinishedNotification(notification:)),
                                               name: Notification.Name(KeyConstants.Notification.moveFileFolderFinished),
                                               object: nil)
        self.navigationController?.presentationController?.delegate = self
        activateTheme()
        showPersonalFiles()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
            staticFolderScreenCoordinator.sourceNodeToMove = sourceNodeToMove
            staticFolderScreenCoordinator.start()
            self.browseTopLevelFolderScreenCoordinator = staticFolderScreenCoordinator
        }
    }
    
    @objc private func handleFilesFolderMoveFinishedNotification(notification: Notification) {
        guard let id = notification.userInfo!["id"] else { return }
        let folderId: String = "\(id)"
        resetMoveFilesAndFolderFlow()
        self.didSelectDismissAction?(folderId)
        self.dismiss(animated: true, completion: nil)
    }
}

extension FilesandFolderListViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        resetMoveFilesAndFolderFlow()
    }
    
    func resetMoveFilesAndFolderFlow() {
        appDelegate()?.isMoveFilesAndFolderFlow = false
        appDelegate()?.isAPSAttachmentFlow = false
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Storyboard Instantiable

extension FilesandFolderListViewController: StoryboardInstantiable {}
