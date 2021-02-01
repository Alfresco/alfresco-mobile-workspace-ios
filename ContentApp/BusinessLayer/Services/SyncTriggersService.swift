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

import Foundation

enum SyncTriggerType: String {
    case applicationDidFinishedLaunching
    case nodeMarkedOffline
    case nodeRemovedFromOffline
    case reachableOverWifi
    case userReAuthenticated
    case poolingTimer
    case userDidInitiateSync
}

protocol SyncTriggersServiceProtocol {
    /// Start a sync operation when a tigger is display
    /// - Parameters type:  Type of trigger
    func triggerSync(when type: SyncTriggerType)
}

class SyncTriggersService: Service, SyncTriggersServiceProtocol {

    private var tiggerType: SyncTriggerType?

    private let syncService: SyncService?
    private let accountService: AccountService?
    private var connectivityService: ConnectivityService?

    private var poolingTimer: Timer?
    private var throttleTimer: Timer?

    private var kvoSyncStatus: NSKeyValueObservation?
    private var kvoConnectivity: NSKeyValueObservation?

    deinit {
        kvoSyncStatus?.invalidate()
        kvoConnectivity?.invalidate()
        poolingTimer?.invalidate()
        throttleTimer?.invalidate()
    }

    // MARK: - Public interface

    init(syncService: SyncService?,
         accountService: AccountService?,
         connectivityService: ConnectivityService) {

        self.syncService = syncService
        self.accountService = accountService
        self.connectivityService = connectivityService
        self.startTimeTrigger()
        self.observeConnectivity()
    }

    func triggerSync(when type: SyncTriggerType) {
        guard accountService?.activeAccount != nil else { return }
        self.tiggerType = type

        if type == .userDidInitiateSync ||
            throttleTimer?.isValid == nil ||
            throttleTimer?.isValid == false {

            startThrottleTimer()
            startSyncOperation()
        }
    }

    // MARK: - Private interface

    private func startThrottleTimer() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.throttleTimer = nil
            sSelf.throttleTimer = Timer.scheduledTimer(withTimeInterval: kSyncTriggerTimerBuffer,
                                                 repeats: false,
                                                 block: { (_) in
                                                 })
        }
    }

    private func startSyncOperation() {
        let listNodeDataAccessor = ListNodeDataAccessor()
        guard let syncService = self.syncService,
              let type = self.tiggerType,
              let nodes = listNodeDataAccessor.queryMarkedOffline(),
              syncService.syncServiceStatus == .idle,
              accountService?.activeAccount != nil else { return }

        if UserProfile.getOptionToSyncOverMobileData() == false &&
            connectivityService?.status == .cellular { return }

        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] (authenticationProvider) in
            guard let sSelf = self else { return }

            if authenticationProvider.areCredentialsValid() {
                sSelf.poolingTimer?.invalidate()
                AlfrescoLog.info("-- SYNC operation started, with TRIGGER \(type.rawValue) --")
                syncService.sync(nodeList: nodes)
                sSelf.observeSyncStatusOperation()
            }
        })
    }

    private func observeSyncStatusOperation() {
        kvoSyncStatus =
            syncService?.observe(\.syncServiceStatus,
                                 options: [.new],
                                 changeHandler: { [weak self] (newValue, _) in
                                    guard let sSelf = self,
                                          newValue.syncServiceStatus == .idle
                                    else { return }

                                    sSelf.startTimeTrigger()
                                 })
    }

    private func observeConnectivity() {
        kvoConnectivity =
            connectivityService?.observe(\.status,
                                         options: [.new],
                                         changeHandler: { [weak self] (newValue, _) in
                                            guard let sSelf = self,
                                                  newValue.status == .wifi
                                            else { return }

                                            sSelf.triggerSync(when: .reachableOverWifi)
                                         })
    }

    private func startTimeTrigger() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.poolingTimer?.invalidate()
            sSelf.poolingTimer = Timer.scheduledTimer(withTimeInterval: kSyncTriggerTimer,
                                                repeats: true,
                                                block: { (_) in
                                                    sSelf.poolingTimer?.invalidate()
                                                    sSelf.triggerSync(when: .poolingTimer)
                                                })
        }
    }
}
