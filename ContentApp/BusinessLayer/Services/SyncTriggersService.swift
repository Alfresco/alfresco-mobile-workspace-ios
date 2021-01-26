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

enum SyncTriggersType: String {
    case applicationDidOpening
    case markedNodeOffline
    case removeNodeOffline
    case connectedToWIFI
    case userReAuthenticated
    case timer
    case syncButtonTapped
}

protocol SyncTriggersServiceProtocol {
    /// Start a sync operation when a tigger is display
    /// - Parameters type:  Type of trigger
    func triggerSync(when type: SyncTriggersType)
}

class SyncTriggersService: Service, SyncTriggersServiceProtocol {

    private let syncService: SyncService?
    private let accountService: AccountService?
    private var triggerTimer: Timer?
    private var throttleTimer: Timer?
    private var kvoSyncStatus: NSKeyValueObservation?
    private var tiggerType: SyncTriggersType?

    deinit {
        kvoSyncStatus?.invalidate()
        triggerTimer?.invalidate()
        throttleTimer?.invalidate()
    }

    // MARK: - Public interface

    init(syncService: SyncService?,
         accountService: AccountService?) {
        self.syncService = syncService
        self.accountService = accountService
        self.startTimeTrigger()
    }

    func triggerSync(when type: SyncTriggersType) {
        guard accountService?.activeAccount != nil else { return }
        self.tiggerType = type

        if type == .syncButtonTapped ||
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
        guard let syncService = self.syncService,
              let type = self.tiggerType else { return }
        let listNodeDataAccessor = ListNodeDataAccessor()

        if let nodes = listNodeDataAccessor.queryMarkedOffline(),
           syncService.syncServiceStatus == .idle &&
            accountService?.activeAccount != nil {

            triggerTimer?.invalidate()
            AlfrescoLog.info("--- SYNC operation started, with TRIGGER \(type.rawValue) ---")
            syncService.sync(nodeList: nodes)
            observeSyncStatusOperation()
        }
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

    private func startTimeTrigger() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.triggerTimer?.invalidate()
            sSelf.triggerTimer = Timer.scheduledTimer(withTimeInterval: kSyncTriggerTimer,
                                                repeats: true,
                                                block: { (_) in
                                                    sSelf.triggerTimer?.invalidate()
                                                    sSelf.triggerSync(when: .timer)
                                                })
        }

    }
}
