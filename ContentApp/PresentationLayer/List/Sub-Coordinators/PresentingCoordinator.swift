//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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

class PresentingCoordinator: Coordinator {
    internal var filePreviewCoordinator: FilePreviewScreenCoordinator?
    internal var folderDrillDownCoordinator: FolderChildrenScreenCoordinator?
    private var offlineFolderChildrenScreenCoordinator: OfflineFolderChildrenScreenCoordinator?

    func start() {
        // To be overriden in child classes
    }

    func startFileCoordinator(for node: ListNode,
                              presenter: UINavigationController,
                              isScannedDocument: Bool = false) {
        let isNodeOffline = isNodeOffline(node: node)
        if isNodeOffline {
            let coordinator = FilePreviewScreenCoordinator(with: presenter,
                                                           listNode: node,
                                                           excludedActions: [.moveTrash,
                                                                             .addFavorite,
                                                                             .removeFavorite,
                                                                             .renameNode,
                                                                             .more,
                                                                             .moveToFolder],
                                                           shouldPreviewLatestContent: false)
            coordinator.start()
            self.filePreviewCoordinator = coordinator
        } else {
            let filePreviewCoordinator = FilePreviewScreenCoordinator(with: presenter,
                                                                      listNode: node,
                                                                      isScannedDocument: isScannedDocument)
            filePreviewCoordinator.start()
            self.filePreviewCoordinator = filePreviewCoordinator
        }
    }

    func startFolderCoordinator(for node: ListNode,
                                presenter: UINavigationController,
                                sourceNodeToMove: [ListNode]?) {
        let isNodeOffline = isNodeOffline(node: node)
        if isNodeOffline {
            let coordinator = OfflineFolderChildrenScreenCoordinator(with: presenter,
                                                                     listNode: node)
            coordinator.start()
            self.offlineFolderChildrenScreenCoordinator = coordinator
        } else {
            let folderDrillDownCoordinator = FolderChildrenScreenCoordinator(with: presenter,
                                                                             listNode: node)
            folderDrillDownCoordinator.sourceNodeToMove = sourceNodeToMove
            folderDrillDownCoordinator.start()
            self.folderDrillDownCoordinator = folderDrillDownCoordinator
        }
    }
}
