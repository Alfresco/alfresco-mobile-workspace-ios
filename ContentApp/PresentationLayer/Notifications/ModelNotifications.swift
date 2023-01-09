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
import MaterialComponents

// MARK: - Notification Type
enum NotificationType: String {
    case preview = "preview"
    case viewer = "(viewer:view/"
    case folder
    case none
}

// MARK: - Model Notification
class ModelNotifications: NSObject {
    static let shared = ModelNotifications()
    private var filePreviewCoordinator: FilePreviewScreenCoordinator?
    private var folderDrillDownCoordinator: FolderChildrenScreenCoordinator?
    var notificationType: NotificationType?
    private var notificationURL: String?
    private var guid: String?

    func handleNotification(for url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let fragment = components.fragment else { return }

        if fragment.contains(NotificationType.preview.rawValue) {
            notificationType = .preview
            notificationURL = removedURLSchema(from: url)
            notificationURL = checkForValidURL(with: notificationURL)
        } else if fragment.contains(NotificationType.viewer.rawValue) {
            notificationType = .viewer
            let notifiedURL = removedURLSchema(from: url)
            let urlArray = notifiedURL.components(separatedBy: NotificationType.viewer.rawValue)
            if urlArray.count > 1 {
                let firstObject = urlArray[1]
                let idArray = firstObject.components(separatedBy: ")")
                if !idArray.isEmpty {
                    guid = idArray.first
                }
            }
        } else {
            notificationType = .folder
            let notifiedURL = removedURLSchema(from: url)
            let urlArray = notifiedURL.components(separatedBy: "/")
            guid = urlArray.last
        }
        checkForRedirectionURL()
    }
    
    private func removedURLSchema(from url: URL) -> String {
        let urlAbsoluteString = url.absoluteString
        let notifiedURL = urlAbsoluteString.replacingOccurrences(of: ConfigurationKeys.fullURLSchema, with: "")
        return notifiedURL
    }
    
    private func checkForValidURL(with notifiedURL: String?) -> String? {
        let urlArray = notifiedURL?.components(separatedBy: "https") ?? []
        if urlArray.count > 1 {
            let firstIndex = urlArray.first
            let secondIndex = urlArray[1]
            let startIndex = secondIndex.prefix(1)
            if String(startIndex) != ":" {
                return String(format: "https:%@", secondIndex)
            }
        }
        
        return notifiedURL
    }
    
    func resetNotificationURL() {
        notificationType = NotificationType.none
        notificationURL = nil
        guid = nil
    }
    
    func checkForRedirectionURL() {
        if notificationType == NotificationType.preview {
            openFilePreviewController()
        } else if notificationType == NotificationType.viewer {
            startPrivateFileCoordinator()
        } else if notificationType == NotificationType.folder {
            startFolderCoordinator()
        }
    }
    
    private func openFilePreviewController() {
        let topMostViewController = UIApplication.shared.topMostViewController()
        if topMostViewController is MDCAlertController {
            topMostViewController?.dismiss(animated: true, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.openFilePreviewController()
                 }
            })
        }
        
        guard let node = listNodeForPreview(guid: "0"), let navigationController = topMostViewController?.navigationController else { return }
        let coordinator = FilePreviewScreenCoordinator(with: navigationController,
                                                       listNode: node,
                                                       excludedActions: [.moveTrash,
                                                                         .addFavorite,
                                                                         .removeFavorite],
                                                       shouldPreviewLatestContent: false,
                                                       publicPreviewURL: notificationURL)
        coordinator.start()
        self.filePreviewCoordinator = coordinator
        resetNotificationURL()
    }
    
    // MARK: - Private node
    func startPrivateFileCoordinator() {
        let topMostViewController = UIApplication.shared.topMostViewController()
        guard let node = listNodeForPreview(guid: guid, syncStatus: .synced), let navigationController = topMostViewController?.navigationController else { return }

        let filePreviewCoordinator = FilePreviewScreenCoordinator(with: navigationController,
                                                                  listNode: node)
        filePreviewCoordinator.start()
        self.filePreviewCoordinator = filePreviewCoordinator
        resetNotificationURL()
    }
    
    // MARK: - Private Folder
    func startFolderCoordinator() {
        let topMostViewController = UIApplication.shared.topMostViewController()
        guard let node = listNodeForPreview(guid: guid, nodeType: .folder), let navigationController = topMostViewController?.navigationController else { return }

        let folderDrillDownCoordinator = FolderChildrenScreenCoordinator(with: navigationController,
                                                                         listNode: node)
        folderDrillDownCoordinator.start()
        self.folderDrillDownCoordinator = folderDrillDownCoordinator
        resetNotificationURL()
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
