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

protocol NavigationURLProtocol {
    var url: URL? { get }
    var route: NavigationRoute? { get }

    var queryItems: [URLQueryItem] { get }
}

struct NavigationURL: NavigationURLProtocol {
    var route: NavigationRoute?

    var url: URL? {
        guard let route = self.route else { return nil }
        if let url = URL(string: route) {
            return url
        } else {
            var allowedCharacters = CharacterSet()
            allowedCharacters.formUnion(.urlHostAllowed)
            allowedCharacters.formUnion(.urlPathAllowed)
            let escapedURLString = route.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
            return URL(string: escapedURLString ?? "")
        }
    }

    var queryItems: [URLQueryItem] {
        guard let route = self.route else { return [] }
        return URLComponents(string: route)?.queryItems ?? []
    }

    init(route: NavigationRoute) {
        self.route = route
    }
}
