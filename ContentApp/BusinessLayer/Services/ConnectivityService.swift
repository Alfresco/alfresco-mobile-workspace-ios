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
import Alamofire

enum ConnectivityStatus {
    case unknown
    case noConnection
    case wifi
    case cellular
}

protocol ConnectivityServiceService {
    /// Status used to display ConnectionType
    var status: ConnectivityStatus { get }

    /// Start an observer to trigger ConnectionType was changed
    func startNetworkReachabilityObserver()
}

class ConnectivityService: Service, ConnectivityServiceService {

    private let network: NetworkReachabilityManager?
    private let syncTriggerService: SyncTriggersService?

    var status: ConnectivityStatus {
        if NetworkReachabilityManager()?.isReachable == false {
            return .noConnection
        }
        if NetworkReachabilityManager()?.isReachableOnEthernetOrWiFi == true {
            return .wifi
        }
        if NetworkReachabilityManager()?.isReachableOnWWAN == true {
            return .cellular
        }
        return .unknown
    }

    // MARK: - Public interface

    init(with syncTriggerService: SyncTriggersService?) {
        self.syncTriggerService = syncTriggerService
        self.network = NetworkReachabilityManager()
    }

    func startNetworkReachabilityObserver() {
        network?.listener = { status in
            switch status {
            case .reachable(NetworkReachabilityManager.ConnectionType.ethernetOrWiFi):
                self.triggerSync()
            default:
                break
            }
        }
        network?.startListening()
    }

    // MARK: - Private interface

    private func triggerSync() {
        syncTriggerService?.triggerSync(when: .connectedToWIFI)
    }
}
