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

struct APIConstants {
    static let minimumVersion = "5.2.2"
    static let me = "-me-" // swiftlint:disable:this identifier_name
    static let my = "-my-" // swiftlint:disable:this identifier_name
    static let daysModifiedInterval = 30
    static let pageSize = 25

    struct Path {
        static let version = "alfresco/versions/1"
        static let base = "api/-default-/public"
        static let isContentServiceAvailable = "service/api/server"
        static let relativeSites = "documentLibrary"
        static let getNodeContent = "\(APIConstants.Path.version)/nodes/%@/content?attachment=false&alf_ticket=%@"
        static let getRenditionContent = "\(APIConstants.Path.version)/nodes/%@/renditions/%@/content?attachment=false&alf_ticket=%@"
        static let getProfile = "\(APIConstants.Path.base)/\(APIConstants.Path.version)/people/-me-"
    }

    struct Include {
        static let path = "path"
        static let isFavorite = "isFavorite"
        static let allowableOperations = "allowableOperations"
        static let properties = "properties"
    }

    struct QuerryConditions {
        static let whereFavoritesFileFolder = "(EXISTS(target/file) OR EXISTS(target/folder))"
        static let whereFavoritesSite = "(EXISTS(target/site))"
    }
}
