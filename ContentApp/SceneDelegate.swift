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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var applicationCoordinator: ApplicationCoordinator?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let applicationCoordinator = ApplicationCoordinator(window: window)
        let repository = applicationCoordinator.repository

        if let themingService = repository.service(of: MaterialDesignThemingService.identifier) as? MaterialDesignThemingService {
            window.backgroundColor = themingService.activeTheme?.surfaceColor
        }

        applicationCoordinator.start()

        let connectivityService = repository.service(of: ConnectivityService.identifier) as? ConnectivityService
        connectivityService?.startNetworkReachabilityObserver()

        self.window = window
        self.applicationCoordinator = applicationCoordinator

        // Legacy call sites read the window and coordinator through appDelegate().
        appDelegate()?.window = window
        appDelegate()?.applicationCoordinator = applicationCoordinator

        if let url = connectionOptions.urlContexts.first?.url {
            _ = appDelegate()?.application(UIApplication.shared, open: url, options: [:])
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        _ = appDelegate()?.application(UIApplication.shared, open: url, options: [:])
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        appDelegate()?.applicationDidBecomeActive(UIApplication.shared)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        appDelegate()?.applicationDidEnterBackground(UIApplication.shared)
    }
}
