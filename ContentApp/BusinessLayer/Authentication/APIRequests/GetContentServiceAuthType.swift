//
// Copyright (C) 2005-2024 Alfresco Software Limited.
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

struct GetContentServiceAuthType: APIRequest {
    typealias Response = AppConfigDetails

    var path: String {
        return APIConstants.Path.appConfig
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

struct AppConfigDetails: Codable {
    let oauth2: OAuth2Data?
    let mobileSettings: MobileSettings?
}

struct OAuth2Data: Codable {
    let host: String?
    let clientId: String?
    let secret: String?
    let scope: String?
    let implicitFlow: Bool?
    let codeFlow: Bool?
    let silentLogin: Bool?
    let publicUrls: [String]?
    let redirectSilentIframeUri: String?
    let redirectUri: String?
    let logoutUrl: String?
    let logoutParameters: [String]?
    let redirectUriLogout: String?
    let audience: String?
    let skipIssuerCheck: Bool?
    let strictDiscoveryDocumentValidation: Bool?
    let authType: String?
}

struct MobileSettings: Codable {
    let host: String?
    let https: Bool
    let port: Int
    let realm: String?
    let contentServicePath: String?
    let secret: String?
    let scope: String?
    let audience: String?
    let iOS: iOSData?
}

struct iOSData: Codable {
    let redirectUri: String?
    let clientId: String?
}
