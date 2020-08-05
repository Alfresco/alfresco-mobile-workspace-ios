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

struct LocalizationConstants {
    static let copyright = NSLocalizedString("copyrightFormat", comment: "")
    static let productName = NSLocalizedString("productName", comment: "")

    struct Buttons {
        static let connect = NSLocalizedString("connectButton", comment: "")
        static let advancedSetting = NSLocalizedString("advancedSettingButton", comment: "")
        static let needHelp = NSLocalizedString("needHelpButton", comment: "")
        static let resetToDefault = NSLocalizedString("resetToDefaultButton", comment: "")
        static let save = NSLocalizedString("saveButton", comment: "")
        static let signin = NSLocalizedString("signin", comment: "")
        static let signInWithSSO = NSLocalizedString("signInWithSSO", comment: "")
        static let snackbarConfirmation = "x"
        static let signOut = NSLocalizedString("signOut", comment: "")
        static let retry = NSLocalizedString("retry", comment: "")
        static let yes = NSLocalizedString("yes", comment: "")
        static let cancel = NSLocalizedString("cancel", comment: "")
    }

    struct TextFieldPlaceholders {
        static let connect = NSLocalizedString("loginConnectTextFieldPlaceholder", comment: "")
        static let port = NSLocalizedString("loginPortTextFieldPlaceholder", comment: "")
        static let serviceDocuments = NSLocalizedString("loginServiceDocumentsTextFieldPlaceholder", comment: "")
        static let realm = NSLocalizedString("loginRealmTextFieldPlaceholder", comment: "")
        static let clientID = NSLocalizedString("loginClientIDTextFieldPlaceholder", comment: "")
        static let username = NSLocalizedString("loginUsernameTextFieldPlaceholder", comment: "")
        static let repository = NSLocalizedString("loginRepositoryTextFieldPlaceholder", comment: "")
        static let password = NSLocalizedString("loginPasswordTextFieldPlaceholder", comment: "")
    }

    struct Labels {
        static let transportProtocol = NSLocalizedString("loginTransportProtocolLabel", comment: "")
        static let https = NSLocalizedString("https", comment: "")
        static let alfrescoContentServicesSettings = NSLocalizedString("alfrescoContentServicesSettings", comment: "")
        static let authentication = NSLocalizedString("authentication", comment: "")
        static let infoBasicAuthConnectTo = NSLocalizedString("infoBasicAuthConnectTo", comment: "")
        static let infoAimsConnectTo = NSLocalizedString("infoAimsConnectTo", comment: "")
        static let allowSSO = NSLocalizedString("loginAllowSSO", comment: "")
        static let needHelpTitle = NSLocalizedString("needHelpTitle", comment: "")
        static let conneting = NSLocalizedString("connecting", comment: "")
        static let signingIn = NSLocalizedString("signingIn", comment: "")
    }

    struct ScreenTitles {
        static let advancedSettings = NSLocalizedString("advancedSettings", comment: "")
        static let settings = NSLocalizedString("settings", comment: "")
        static let recent = NSLocalizedString("recent", comment: "")
        static let favorites = NSLocalizedString("favorites", comment: "")
        static let browse = NSLocalizedString("browse", comment: "")
    }

    struct Textviews {
        static let serviceURLHint = NSLocalizedString("serviceURLHint", comment: "")
        static let advancedSettingsHint = NSLocalizedString("advancedSettingsHint", comment: "")
        static let ssoHint = NSLocalizedString("ssoHint", comment: "")
    }

    struct Errors {
        static let generic = NSLocalizedString("loginGenericErrorText", comment: "")
        static let noAuthAlfrescoURL = NSLocalizedString("loginErrorNoAuthAlfrescoURL", comment: "")
        static let checkConnectURL = NSLocalizedString("loginErrorCheckConnectURL", comment: "")
        static let wrongCredentials = NSLocalizedString("loginErrorWrongCredentialProvided", comment: "")
        static let saveSettings = NSLocalizedString("loginApprovedSaveSettings", comment: "")
        static let serviceDocumentEmpty = NSLocalizedString("loginWarningServiceDocumetEmptyText", comment: "")
        static let noLongerAuthenticated = NSLocalizedString("loginNoLongerAuthenticatedText", comment: "")
    }

    struct Theme {
        static let theme = NSLocalizedString("theme", comment: "")
        static let auto = NSLocalizedString("auto", comment: "")
        static let dark = NSLocalizedString("dark", comment: "")
        static let light = NSLocalizedString("light", comment: "")
    }

    struct Settings {
        static let failedProfileInfo = NSLocalizedString("failedProfileInfo", comment: "")
        static let appVersion = NSLocalizedString("appVersion", comment: "")
        static let signOutConfirmation = NSLocalizedString("signOutConfirmation", comment: "")
    }

    struct Search {
        static let title = NSLocalizedString("emptyListTitle", comment: "")
        static let subtitle = NSLocalizedString("emptyListSubtitle", comment: "")
        static let searching = NSLocalizedString("searching", comment: "")
        static let noRecentSearch = NSLocalizedString("noRecentSearch", comment: "")
        static let recentSearch = NSLocalizedString("recentSearch", comment: "")
        static let filterFiles = NSLocalizedString("filterFiles", comment: "")
        static let filterFolders = NSLocalizedString("filterFolders", comment: "")
        static let filterLibraries = NSLocalizedString("filterLibraries", comment: "")
        static let filterFoldersAndFiles = NSLocalizedString("filterfoldersAndFiles", comment: "")
    }

    struct GroupListSection {
        static let today = NSLocalizedString("today", comment: "")
        static let yesterday = NSLocalizedString("yesterday", comment: "")
        static let thisWeek = NSLocalizedString("thisWeek", comment: "")
        static let lastWeek = NSLocalizedString("lastWeek", comment: "")
        static let thisMonth = NSLocalizedString("thisMonth", comment: "")
        static let older = NSLocalizedString("older", comment: "")
    }

    struct BrowseStaticList {
        static let personalFiles = NSLocalizedString("browse-personalFiles", comment: "")
        static let myLibraries = NSLocalizedString("browse-myLibraries", comment: "")
        static let shared = NSLocalizedString("browse-shared", comment: "")
        static let trash = NSLocalizedString("browse-trash", comment: "")
    }
}
