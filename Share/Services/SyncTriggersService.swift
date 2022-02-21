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
import MaterialComponents.MaterialDialogs
import UIKit

enum SyncTriggerType: String {
    case applicationDidFinishedLaunching
    case nodeMarkedOffline
    case nodeRemovedFromOffline
    case userReAuthenticated
    case userDidInitiateSync
    case userDidInitiateUploadTransfer
}

protocol SyncTriggersServiceProtocol {

    /// Register observers and timers for triggers
    func registerTriggers()

    /// Invalidate all the triggers
    func invalidateTriggers()

    /// Start a sync operation when a tigger is display
    /// - Parameters type:  Type of trigger
    /// - Parameters interval: 
    func triggerSync(for type: SyncTriggerType, in interval: TimeInterval)
}

class SyncTriggersService: Service, SyncTriggersServiceProtocol {

    private let syncService: SyncService?
    private let accountService: AccountService?
    private var connectivityService: ConnectivityService?

    private var poolingTimer: Timer?
    private let poolingTimerBuffer = 15 * 60.0
    private var debounceTimer: Timer?
    private let debounceTimerBuffer = 10.0

    private var kvoSyncStatus: NSKeyValueObservation?
    private var kvoConnectivity: NSKeyValueObservation?

    private var syncDidTriedToStartOnConnectivity = false
    private var syncDidTriedToStartWhenSyncing = false

    deinit {
        kvoSyncStatus?.invalidate()
        kvoConnectivity?.invalidate()
        poolingTimer?.invalidate()
        debounceTimer?.invalidate()
    }

    // MARK: - Public interface

    init(syncService: SyncService?,
         accountService: AccountService?,
         connectivityService: ConnectivityService) {

        self.syncService = syncService
        self.accountService = accountService
        self.connectivityService = connectivityService

        self.registerTriggers()
    }

    func registerTriggers() {
        observeSyncStatusOperation()
        observeConnectivity()
    }

    func invalidateTriggers() {
        kvoSyncStatus?.invalidate()
        kvoConnectivity?.invalidate()
        invalidateAllTimers()
    }

    func triggerSync(for type: SyncTriggerType, in interval: TimeInterval = 0) {
        guard accountService?.activeAccount != nil else { return }

        if type == .applicationDidFinishedLaunching &&
            interval > poolingTimerBuffer {
            startSyncOperation()
        }

        if type == .nodeMarkedOffline ||
            type == .nodeRemovedFromOffline {
            syncDidTriedToStartWhenSyncing = true
            startDebounceTimer()
        }

        if type == .userDidInitiateSync ||
            type == .userReAuthenticated ||
            type == .userDidInitiateUploadTransfer {
            startSyncOperation()
        }
    }
    
    func showOverrideSyncOnAlfrescoMobileAppDialog(for type: SyncTriggerType, on controller: UIViewController?) {
        DispatchQueue.main.async {
            if let presentationContext = controller {
                let title = LocalizationConstants.AppExtension.upload
                let message = LocalizationConstants.AppExtension.overrideSyncOnAlfrescoAppDataMessage

                let confirmAction = MDCAlertAction(title: LocalizationConstants.General.ok) { [weak self] _ in
                    guard let sSelf = self else { return }
                    UserProfile.allowOnceSyncOverCellularData = true
                    sSelf.triggerSync(for: type)
                    presentationContext.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                }
                confirmAction.accessibilityIdentifier = "confirmActionButton"
                _ = presentationContext.showDialog(title: title,
                                                   message: message,
                                                   actions: [confirmAction],
                                                   completionHandler: {})
            }
        }
    }

    // MARK: - Timers

    private func startDebounceTimer() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.debounceTimer?.invalidate()
            sSelf.debounceTimer =
                Timer.scheduledTimer(withTimeInterval: sSelf.debounceTimerBuffer,
                                     repeats: false,
                                     block: { (_) in
                                        guard let sSelf = self else { return }
                                        sSelf.debounceTimer?.invalidate()
                                        sSelf.startSyncOperation()
                                     })
        }
    }

    private func startPoolingTrigger() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.poolingTimer?.invalidate()
            sSelf.poolingTimer =
                Timer.scheduledTimer(withTimeInterval: sSelf.poolingTimerBuffer,
                                     repeats: true,
                                     block: { (_) in
                                        guard let sSelf = self else { return }
                                        sSelf.poolingTimer?.invalidate()
                                        sSelf.startSyncOperation()
                                     })
        }
    }

    private func invalidateAllTimers() {
        poolingTimer?.invalidate()
        debounceTimer?.invalidate()
    }

    // MARK: - KVO

    private func observeSyncStatusOperation() {
        kvoSyncStatus =
            syncService?.observe(\.syncServiceStatus,
                                 options: [.new],
                                 changeHandler: { [weak self] (newValue, _) in
                                    guard let sSelf = self,
                                          newValue.syncServiceStatus == .idle
                                    else { return }
                                    if sSelf.syncDidTriedToStartWhenSyncing {
                                        sSelf.startSyncOperation()
                                    }
                                    sSelf.startPoolingTrigger()
                                 })
    }

    private func observeConnectivity() {
        kvoConnectivity =
            connectivityService?.observe(\.status,
                                         options: [.new],
                                         changeHandler: { [weak self] (_, _) in
                                            guard let sSelf = self else { return }
                                            sSelf.connectivityStatusChanged()
                                         })
    }

    // MARK: - Private Interface

    private func startSyncOperation() {
        let listNodeDataAccessor = ListNodeDataAccessor()
        let nodes = listNodeDataAccessor.queryMarkedOffline()

        guard let syncService = self.syncService,
              accountService?.activeAccount != nil else { return }

        if isSyncAllowedOverConnectivity() == false {
            syncDidTriedToStartOnConnectivity = true
            return
        }

        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] (authenticationProvider) in
            guard let sSelf = self else { return }

            if authenticationProvider.areCredentialsValid() {
                UserProfile.allowOnceSyncOverCellularData = false
                sSelf.invalidateAllTimers()
                sSelf.syncDidTriedToStartOnConnectivity = false
                sSelf.syncDidTriedToStartWhenSyncing = false
                syncService.sync(nodeList: nodes)
            }
        })
    }

    private func connectivityStatusChanged() {
        switch connectivityService?.status {
        case .wifi, .cellular:
            if isSyncAllowedOverConnectivity() {
                if syncDidTriedToStartOnConnectivity == true {
                    startSyncOperation()
                }
            } else {
                syncService?.stopSync()
            }
        default:
            invalidateAllTimers()
            syncService?.stopSync()
        }
    }

    private func isSyncAllowedOverConnectivity() -> Bool {
        guard connectivityService?.status == .cellular else { return true }
        if UserProfile.allowSyncOverCellularData ||
            UserProfile.allowOnceSyncOverCellularData {
            return true
        }
        return false
    }
}
