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

struct KeyConstants {
    struct Disk {
        static let avatar = "avatar"
        static let mediaFilesFolder = "MediaFiles"
        static let uploadsFolder = "Uploads"
    }

    struct Save {
        static let authSettingsParameters = "kSaveAuthSettingsParameters"
        static let themeMode = "kSaveThemeMode"
        static let activeAccountIdentifier = "kActiveAccountIdentifier"
        static let recentSearches = "kSaveRecentSearchesArray"
        static let displayProfileName = "kSaveDiplayProfileName"
        static let emailProfile = "kSaveEmailProfile"
        static let personalFilesID = "kSavePersonalFilesID"
        static let allowSyncOverCellularData = "kSaveAllowSyncOverCellularData"
        static let allowOnceSyncOverCellularData = "kSaveAllowOnceSyncOverCellularData"
        static let toCameraRoll = "com.apple.UIKit.activity.SaveToCameraRoll"
    }

    struct Notification {
        static let showLoginScreen = "kShowLoginScreenNotification"
        static let unauthorizedRequest = "kAPIUnauthorizedRequestNotification"
        static let reSignin = "kReSignInNotification"
    }
    
    struct AdvanceSearch {
        static let fetchAdvanceSearchFromServer = "fetchAdvanceSearchFromServer"
        static let configFile = "advance-search-config"
        static let configFileExtension = "json"
        static let lastAPICallTime = "advance-search-api-call-time"
    }
    
    struct AppGroup {
        static let name = "group.com.alfresco.contentapp.Share"
        static let accessGroup = "W8N95J537P.com.alfresco.sharedItems"
        static let service = "alfrescoAppFamilyService"
        static let appURLString = "ShareExtension://"
        static let sharedFiles = "sharedFiles"
    }
}
