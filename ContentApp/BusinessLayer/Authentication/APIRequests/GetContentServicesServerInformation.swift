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
import AlfrescoCore

struct GetContentServicesServerInformation: APIRequest {
    typealias Response = VersionContentService

    var path: String {
        return APIConstants.Path.isContentServiceAvailable
    }

    var method: HttpMethod {
        return .get
    }

    var headers: [String: String] {
        return [:]
    }

    var parameters: [String: String] {
        return [:]
    }
}

public struct VersionContentService: Codable {
    private var version: String?
    private let data: [String: String]

    enum CodingKeys: String, CodingKey {
        case data
        case version
    }

    public init(version: String, data: [String: String]) {
        self.version = version
        self.data = data
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try values.decode([String: String].self, forKey: .data)
        self.version = ""
        if let version = data[CodingKeys.version.rawValue] {
            self.version = version
        }
    }

    func isVersionOverMinium() -> Bool {
        guard let version = self.version?.split(separator: " ").first else {
            return false
        }
        let comparison = String(version).versionCompare(APIConstants.minimumVersion)
        if comparison == .orderedDescending || comparison == .orderedSame {
            return true
        }
        return false
    }
}
