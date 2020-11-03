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
import AlfrescoCore
import MaterialComponents.MaterialDialogs

class ApplicationCoordinator: Coordinator {
    let window: UIWindow
    var rootViewController: UINavigationController
    var splashScreenCoordinator: SplashScreenCoordinator

    init(window: UIWindow) {
        self.window = window
        rootViewController = UINavigationController()
        splashScreenCoordinator = SplashScreenCoordinator.init(with: rootViewController)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleUnauthorizedAPIAccess(notification:)),
                                               name: Notification.Name(kAPIUnauthorizedRequestNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.loadSplashScreenCoordinator(notification:)),
                                               name: Notification.Name(kShowLoginScreenNotification),
                                               object: nil)
    }

    func start() {
        window.rootViewController = rootViewController

        let options: UIView.AnimationOptions = .transitionCrossDissolve
        let duration: TimeInterval = 0.25
        UIView.transition(with: window,
                          duration: duration,
                          options: options,
                          animations: {},
                          completion: nil)

        splashScreenCoordinator.start()
        window.makeKeyAndVisible()
    }

    @objc private func handleUnauthorizedAPIAccess(notification: Notification) {
        let viewController =
            (window.rootViewController?.presentedViewController ?? window.rootViewController) as?
            SystemThemableViewController

        let title = LocalizationConstants.Labels.sessionExpiredTitle
        let message = LocalizationConstants.Labels.sesssionExpiredMessage

        let confirmAction = MDCAlertAction(title: LocalizationConstants.Buttons.signin) { [weak self] _ in
            guard let sSelf = self else { return }
            let accountService = sSelf.repository.service(of: AccountService.identifier) as? AccountService
            if let viewController = viewController {
                accountService?.activeAccount?.reSignIn(onViewController: viewController)
            }
        }
        let cancelAction = MDCAlertAction(title: LocalizationConstants.Buttons.cancel) { _ in }

        _ = viewController?.showDialog(title: title,
                                       message: message,
                                       actions: [confirmAction, cancelAction],
                                       completionHandler: {})
    }

    @objc private func loadSplashScreenCoordinator(notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
            guard let sSelf = self else { return }

            sSelf.rootViewController = UINavigationController()
            sSelf.splashScreenCoordinator =
                SplashScreenCoordinator.init(with: sSelf.rootViewController)

            sSelf.start()
        })
    }
}
