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

@objc enum ConnectivityStatus: Int, CustomStringConvertible {
    case unknown
    case noConnection
    case wifi
    case cellular
    
    var description: String {
        get {
            switch self {
            case .unknown:
                return "unknown"
            case .noConnection:
                return "noConnection"
            case .wifi:
                return "wifi"
            case .cellular:
                return "cellular"
            }
        }
    }
}

protocol ConnectivityServiceProtocol {

    /// Start an observer to trigger ConnectionType was changed
    func startNetworkReachabilityObserver()
}

@objc class ConnectivityService: NSObject, Service, ConnectivityServiceProtocol {

    private let reachabilityManager: NetworkReachabilityManager?
    @objc dynamic var status: ConnectivityStatus

    // MARK: - Public interface

    override init() {
        self.reachabilityManager = NetworkReachabilityManager()

        if NetworkReachabilityManager()?.isReachable == false {
            self.status =  .noConnection
        } else if NetworkReachabilityManager()?.isReachableOnEthernetOrWiFi == true {
            self.status = .wifi
        } else if NetworkReachabilityManager()?.isReachableOnWWAN == true {
            self.status = .cellular
        } else {
            self.status = .unknown
        }
    }

    func hasInternetConnection() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }

    func startNetworkReachabilityObserver() {
        reachabilityManager?.listener = { status in
            switch status {
            case .reachable(NetworkReachabilityManager.ConnectionType.ethernetOrWiFi):
                self.status = .wifi
            case .reachable(NetworkReachabilityManager.ConnectionType.wwan):
                self.status = .cellular
            case .notReachable:
                self.status = .noConnection
            default:
                self.status = .unknown
            }
        }
        reachabilityManager?.startListening()
    }
}
