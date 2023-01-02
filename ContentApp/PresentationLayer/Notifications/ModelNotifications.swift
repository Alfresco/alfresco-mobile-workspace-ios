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
    var notificationURL: String?

    func handleNotification(for url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let fragment = components.fragment else { return }

        if fragment.contains(NotificationType.preview.rawValue) { // directly open preview screen
            let urlAbsoluteString = url.absoluteString
            notificationURL = urlAbsoluteString.replacingOccurrences(of: ConfigurationKeys.fullURLSchema, with: "")
            openFilePreviewController()
        }
    }
    
    func resetNotificationURL() {
        notificationURL = nil
    }
    
    private func openFilePreviewController() {
        let topMostViewController = UIApplication.shared.topMostViewController()
        guard let node = listNodeForPreview(), let navigationController = topMostViewController?.navigationController else { return }
        let coordinator = FilePreviewScreenCoordinator(with: navigationController,
                                                       listNode: node,
                                                       excludedActions: [.moveTrash,
                                                                         .addFavorite,
                                                                         .removeFavorite],
                                                       shouldPreviewLatestContent: false)
        coordinator.start()
        self.filePreviewCoordinator = coordinator
    }
    
    private func listNodeForPreview() -> ListNode? {
        return ListNode(guid: "0",
                        mimeType: nil,
                        title: LocalizationConstants.ScreenTitles.previewCaptureAsset,
                        path: "",
                        nodeType: .file,
                        syncStatus: .pending,
                        markedOfflineStatus: .upload,
                        allowableOperations: [],
                        uploadLocalPath: "")
    }
}

func notificationsCentre() -> ModelNotifications {
    return ModelNotifications.shared
}
