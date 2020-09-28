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
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var applicationCoordinator: ApplicationCoordinator?
    var allowedOrientation: UIInterfaceOrientationMask = .portrait

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let applicationCoordinator = ApplicationCoordinator(window: window)

        self.window = window
        self.applicationCoordinator = applicationCoordinator
        if let themingService = applicationCoordinator.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService {
            window.backgroundColor = themingService.activeTheme?.backgroundColor
        }

        applicationCoordinator.start()

        FirebaseApp.configure()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let themingService = applicationCoordinator?.serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService
        themingService?.activateAutoTheme(for: UIScreen.main.traitCollection.userInterfaceStyle)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        let accountService = applicationCoordinator?.serviceRepository.service(of: AccountService.serviceIdentifier) as? AccountService
        accountService?.activeAccount?.createTicket()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let authenticationService = self.applicationCoordinator?.serviceRepository.service(of: AuthenticationService.serviceIdentifier) as? AuthenticationService
        return authenticationService?.resumeExternalUserAgentFlow(with: url) ?? false
    }

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return allowedOrientation
        }
        return .all
    }
}
