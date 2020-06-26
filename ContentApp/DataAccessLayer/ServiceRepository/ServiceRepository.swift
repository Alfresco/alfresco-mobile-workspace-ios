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

import Foundation

typealias ServiceIdentifier = String

protocol NameDescribable {
    var typeName: String { get }
    static var typeName: String { get }
}

extension NameDescribable {
    var typeName: String {
        return String(describing: type(of: self))
    }

    static var typeName: String {
        return String(describing: self)
    }
}

protocol Service: NameDescribable {
    static var serviceIdentifier: ServiceIdentifier { get }
    var serviceIdentifier: ServiceIdentifier { get }
}

extension Service {
    static var serviceIdentifier: ServiceIdentifier {
        return typeName
    }

    var serviceIdentifier: ServiceIdentifier {
        return typeName
    }
}

// MARK: - Service repository

/// Repository pattern protocol intended to host business layer services
protocol ServiceRepositoryProtocol {
    associatedtype ServiceType

    /// Registers a service with the repository based on the service's identifier.
    /// - Parameter service: service to be registered
    func register(service: ServiceType)

    /// Returns a registered service given it's service identifier string value
    /// - Parameter type: service identifier value
    func service(of type: String) -> Service?

    /// Removes a service given it's service identifier.
    /// - Parameter type: service identifier value
    func remove(service type: String)
}

class ServiceRepository: ServiceRepositoryProtocol {
    typealias ServiceType = Service

    private var services: [String: Service] = [:]

    func register(service: ServiceType) {
        services[service.serviceIdentifier] = service
    }

    func service(of type: String) -> Service? {
        return services[type]
    }

    func remove(service type: String) {
        services.removeValue(forKey: type)
    }
}
