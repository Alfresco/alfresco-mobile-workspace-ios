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

class ApplicationCoordinator: Coordinator {
    let window: UIWindow
    let rootViewController: UINavigationController
    let splashScreenCoordinator: SplashScreenCoordinator
    var loginService: LoginService
    var themeService: MaterialDesignThemingService

    init(window: UIWindow) {
        self.window = window
        self.themeService = MaterialDesignThemingService()
        themeService.activeTheme = DefaultTheme()
        self.loginService = LoginService(with: AuthSettingsParameters.parameters())
        rootViewController = UINavigationController()
        splashScreenCoordinator = SplashScreenCoordinator.init(with: rootViewController)
        splashScreenCoordinator.loginService = loginService
        splashScreenCoordinator.themeService = themeService
    }

    func start() {
        window.rootViewController = rootViewController
        splashScreenCoordinator.start()
        window.makeKeyAndVisible()
    }
}
