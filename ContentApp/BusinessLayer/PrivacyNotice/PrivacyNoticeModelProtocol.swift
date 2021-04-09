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

protocol PrivacyNoticeModelProtocol {
    var title: String { get }
    var description: String { get }
}

struct PrivacyNotiveCameraModel: PrivacyNoticeModelProtocol {
    var title = LocalizationConstants.PrivacySettings.privacyCameraTitle
    var description =  LocalizationConstants.PrivacySettings.privacyCameraDescription
}

struct PrivacyNotivePhotosModel: PrivacyNoticeModelProtocol {
    var title = LocalizationConstants.PrivacySettings.privacyPhotosTitle
    var description =  LocalizationConstants.PrivacySettings.privacyPhotosDescription
}
