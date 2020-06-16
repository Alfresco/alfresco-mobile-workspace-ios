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
import UIKit

let kSaveAuthSettingsParameters = "kSaveAuthSettingsParameters"
let kSaveThemeMode = "kSaveThemeMode"
let kDefaultLoginUnsecuredPort = "80"
let kDefaultLoginSecuredPort = "443"
let kPathGetProfile = "api/-default-/public/alfresco/versions/1/people/-me-"
let kAIMSAccessTokenRefreshTimeBuffer = 20

let kAnimationSplashScreenLogo = 2.0
let kAnimationSplashScreenContainerViews = 1.5
let kPushAnimation = (UIDevice.current.userInterfaceIdiom != .pad)

let kSessionExpirationTimeIntervalCheck = 20
let kLoginAIMSCancelWebViewErrorCode = -3
