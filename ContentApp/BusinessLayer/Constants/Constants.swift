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
let kAIMSAccessTokenRefreshTimeBuffer = 20.0
let kActiveAccountIdentifier = "kActiveAccountIdentifier"

let kAnimationSplashScreenLogo = 2.0
let kAnimationSplashScreenContainerViews = 1.5
let kPushAnimation = (UIDevice.current.userInterfaceIdiom != .pad)

let kSessionExpirationTimeIntervalCheck = 20
let kLoginAIMSCancelWebViewErrorCode = -3
let kShowLoginScreenNotification = "kShowLoginScreenNotification"

let kAPIUnauthorizedRequestNotification = "kAPIUnauthorizedRequestNotification"
let kAPIPathGetProfile = "\(kAPIPathBase))/people/-me-"
let kAPIPathGetAvatarProfile = "alfresco/versions/1/people/-me-/avatar"
let kAPIPathBase = "api/-default-/public"
let kAPIPathMe = "-me-"
