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
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var applicationCoordinator: ApplicationCoordinator?
    var orientationLock = UIInterfaceOrientationMask.all

    var enterInBackgroundTimestamp: TimeInterval?
    var enterInForegroundTimestamp: TimeInterval?

    var backgroundTask: BGAppRefreshTask?
    var backgroundCompletionHandler: (() -> Void)?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let applicationCoordinator = ApplicationCoordinator(window: window)

        self.window = window
        self.applicationCoordinator = applicationCoordinator
        let repository = applicationCoordinator.repository

        if let themingService = repository.service(of: MaterialDesignThemingService.identifier) as? MaterialDesignThemingService {
            window.backgroundColor = themingService.activeTheme?.surfaceColor
        }

        applicationCoordinator.start()

        FirebaseApp.configure()

        let connectivityService = repository.service(of: ConnectivityService.identifier) as? ConnectivityService
        connectivityService?.startNetworkReachabilityObserver()

        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.alfresco.contentapp.sync",
                                        using: nil) { task in
            if let task = task as? BGAppRefreshTask {
                self.handleSyncRefresh(task: task)
            }
        }

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let repository = applicationCoordinator?.repository

        let themingService = repository?.service(of: MaterialDesignThemingService.identifier) as? MaterialDesignThemingService
        themingService?.activateAutoTheme(for: UIScreen.main.traitCollection.userInterfaceStyle)

        let accountService = repository?.service(of: AccountService.identifier) as? AccountService
        accountService?.createTicketForCurrentAccount()

        let syncTriggerService = repository?.service(of: SyncTriggersService.identifier) as? SyncTriggersService

        enterInForegroundTimestamp = Date().timeIntervalSince1970

        if let enterInForegroundTimestamp = self.enterInForegroundTimestamp,
           let enterInBackgroundTimestamp = self.enterInBackgroundTimestamp {

            let interval = enterInForegroundTimestamp - enterInBackgroundTimestamp
            syncTriggerService?.triggerSync(for: .applicationDidFinishedLaunching,
                                            in: interval)

            self.enterInForegroundTimestamp = nil
            self.enterInForegroundTimestamp = nil
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        enterInBackgroundTimestamp = Date().timeIntervalSince1970
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let accountService = applicationCoordinator?.repository.service(of: AccountService.identifier) as? AccountService
        if let aimsAccount = accountService?.activeAccount as? AIMSAccount {
            if let session = aimsAccount.session.session {
                return session.resumeExternalUserAgentFlow(with: url)
            }
        }

        return false
    }

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleSyncRefresh()
    }

    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        backgroundCompletionHandler = completionHandler
    }

    func scheduleSyncRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.alfresco.contentapp.sync")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 2 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }

        print("Task submitted")
    }

    func handleSyncRefresh(task: BGAppRefreshTask) {
        scheduleSyncRefresh()

        let repository = applicationCoordinator?.repository
        let syncService = repository?.service(of: SyncService.identifier) as? SyncService
        syncService?.delegate = self

        let listNodeDataAccessor = ListNodeDataAccessor()
        if let nodes = listNodeDataAccessor.queryMarkedOffline() {
            syncService?.sync(nodeList: nodes)
        }

        task.expirationHandler = {
            syncService?.stopSync()
        }

        backgroundTask = task
    }
}

extension AppDelegate: SyncServiceDelegate {
    func syncDidStarted() {
        // Do nothing
    }

    func syncDidFinished() {
        backgroundTask?.setTaskCompleted(success: true)
    }
}
