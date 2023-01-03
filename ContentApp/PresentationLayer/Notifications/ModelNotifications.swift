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

enum NotificationType: String {
    case preview = "preview"
    case viewer = "(viewer:view/"
    case folder
}
class ModelNotifications: NSObject {
    static let shared = ModelNotifications()
    private var filePreviewCoordinator: FilePreviewScreenCoordinator?
    private var folderDrillDownCoordinator: FolderChildrenScreenCoordinator?
    var notificationURL: String?

    func handleNotification(for url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let fragment = components.fragment else { return }

        if fragment.contains(NotificationType.preview.rawValue) { // directly open preview screen
            let urlAbsoluteString = url.absoluteString
            notificationURL = urlAbsoluteString.replacingOccurrences(of: ConfigurationKeys.fullURLSchema, with: "")
            openFilePreviewController()
        } else if fragment.contains(NotificationType.viewer.rawValue) {
            let urlAbsoluteString = url.absoluteString
            let notifiedURL = urlAbsoluteString.replacingOccurrences(of: ConfigurationKeys.fullURLSchema, with: "")
            print(notifiedURL)
            
//            let str = "abcdecd"
//            if let firstIndex = fragment.firstIndex(of: "(") {
//                let index = str.distance(from: str.startIndex, to: firstIndex)
//                print("index: ", index)   //index: 2
//            }
//            else {
//                print("symbol not found")
//            }
            
            startPrivateFileCoordinator(guid: "b7024af9-4292-412e-9fc5-1193da570579")

        } else {
            startFolderCoordinator(guid: "a0d60323-56c7-4793-8621-fc072f73c264")
        }
    }
    
    func resetNotificationURL() {
        notificationURL = nil
    }
    
    private func openFilePreviewController() {
        let topMostViewController = UIApplication.shared.topMostViewController()
        guard let node = listNodeForPreview(guid: "0"), let navigationController = topMostViewController?.navigationController else { return }
        let coordinator = FilePreviewScreenCoordinator(with: navigationController,
                                                       listNode: node,
                                                       excludedActions: [.moveTrash,
                                                                         .addFavorite,
                                                                         .removeFavorite],
                                                       shouldPreviewLatestContent: false)
        coordinator.start()
        self.filePreviewCoordinator = coordinator
    }
    
    // MARK: - Private node
    func startPrivateFileCoordinator(guid: String?) {
        let topMostViewController = UIApplication.shared.topMostViewController()
        guard let node = listNodeForPreview(guid: guid, syncStatus: .synced), let navigationController = topMostViewController?.navigationController else { return }

        let filePreviewCoordinator = FilePreviewScreenCoordinator(with: navigationController,
                                                                  listNode: node)
        filePreviewCoordinator.start()
        self.filePreviewCoordinator = filePreviewCoordinator
    }
    
    // MARK: - Private Folder
    func startFolderCoordinator(guid: String?) {
        let topMostViewController = UIApplication.shared.topMostViewController()
        guard let node = listNodeForPreview(guid: guid, nodeType: .folder), let navigationController = topMostViewController?.navigationController else { return }

        let folderDrillDownCoordinator = FolderChildrenScreenCoordinator(with: navigationController,
                                                                         listNode: node)
        folderDrillDownCoordinator.start()
        self.folderDrillDownCoordinator = folderDrillDownCoordinator
    }
    
    private func listNodeForPreview(guid: String?,
                                    nodeType: NodeType = .file,
                                    syncStatus: SyncStatus = .pending) -> ListNode? {
        return ListNode(guid: guid ?? "",
                        title: LocalizationConstants.ScreenTitles.previewCaptureAsset,
                        path: "",
                        nodeType: nodeType,
                        syncStatus: syncStatus)
    }
}

func notificationsCentre() -> ModelNotifications {
    return ModelNotifications.shared
}
