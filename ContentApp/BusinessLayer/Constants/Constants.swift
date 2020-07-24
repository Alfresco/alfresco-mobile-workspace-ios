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

// MARK: - Save Objects Keys
let kSaveAuthSettingsParameters = "kSaveAuthSettingsParameters"
let kSaveThemeMode = "kSaveThemeMode"
let kActiveAccountIdentifier = "kActiveAccountIdentifier"
let kProfileAvatarImageFileName = "avatar"
let kSaveDiplayProfileName = "kSaveDiplayProfileName"
let kSaveEmailProfile = "kSaveEmailProfile"
let kSaveRecentSearchesArray = "kSaveRecentSearchesArray"

// MARK: - API Paths
let kAPIPathVersion = "alfresco/versions/1"
let kAPIPathBase = "api/-default-/public"
let kAPIPathMe = "-me-"
let kAPIPathGetProfile = "\(kAPIPathBase)/\(kAPIPathVersion)/people/-me-"
let kAPIPathGetAvatarProfile = "\(kAPIPathVersion)/people/-me-/avatar"
let kWhereFavoritesFileFolderCondition = "(EXISTS(target/file) OR EXISTS(target/folder))"
let kWhereFavoritesSiteCondition = "(EXISTS(target/site))"

// MARK: - Notification Keys
let kShowLoginScreenNotification = "kShowLoginScreenNotification"
let kAPIUnauthorizedRequestNotification = "kAPIUnauthorizedRequestNotification"

// MARK: - Animations Time
let kAnimationSplashScreenLogo = 2.0
let kAnimationSplashScreenContainerViews = 1.5

// MARK: - Timers
let kAIMSAccessTokenRefreshTimeBuffer = 20.0
let kSessionExpirationTimeIntervalCheck = 20
let kSearchTimerBuffer = 0.7

// MARK: - Error codes
let kLoginAIMSCancelWebViewErrorCode = -3

// MARK: - Height&Widhts

let accountSettingsButtonHeight: CGFloat = 30.0
let listItemNodeCellHeight: CGFloat = 64.0
let listSectionCellHeight: CGFloat = 56.0
let listSiteCellHeight: CGFloat = 48.0
let recentSearchCellHeight: CGFloat = 48.0
let chipSearchCellMinimHeight: CGFloat = 32.0
let chipSearchCellMinimWidth: CGFloat = 52.0

// MARK: -
let kDefaultLoginUnsecuredPort = "80"
let kDefaultLoginSecuredPort = "443"
let kPushAnimation = (UIDevice.current.userInterfaceIdiom != .pad)
let kWindow =  UIApplication.shared.windows[0]

// MARK: - Search related
let kMaxElemetsInRecentSearchesArray = 15
let kMinCharactersForLiveSearch = 3
let kListPageSize = 25
