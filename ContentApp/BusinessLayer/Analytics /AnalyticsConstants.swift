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

struct AnalyticsConstants {
    
    struct CommonParameters {
        static let serverURL = "server_url"
        static let deviceName = "device_name"
        static let deviceOS = "device_os"
        static let deviceNetwork = "device_network"
        static let appVersion = "app_version"
        static let deviceID = "device_id"
    }
    
    struct Parameters {
        static let fileMimetype = "file_mimetype"
        static let fileExtension = "file_extension"
        static let previewSuccess = "success"
    }
    
    struct Events {
        static let filePreview = "Event_FilePreview"
        static let openWith = "Event_OpenWith"
    }
    
}
