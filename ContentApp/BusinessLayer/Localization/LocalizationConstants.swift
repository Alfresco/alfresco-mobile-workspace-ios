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
    static let copyright = NSLocalizedString("copyright-format", comment: "")
    static let productName = NSLocalizedString("product-name", comment: "")

    struct Buttons {
        static let connect = NSLocalizedString("connect", comment: "")
        static let advancedSetting = NSLocalizedString("advanced-settings", comment: "")
        static let needHelp = NSLocalizedString("need-help", comment: "")
        static let resetToDefault = NSLocalizedString("reset-to-default", comment: "")
        static let save = NSLocalizedString("save", comment: "")
        static let signin = NSLocalizedString("sign-in", comment: "")
        static let signInWithSSO = NSLocalizedString("sign-in-with-sso", comment: "")
        static let snackbarConfirmation = "x"
        static let signOut = NSLocalizedString("sign-out", comment: "")
        static let retry = NSLocalizedString("retry", comment: "")
        static let yes = NSLocalizedString("yes", comment: "")
        static let cancel = NSLocalizedString("cancel", comment: "")
    }

    struct TextFieldPlaceholders {
        static let connect = NSLocalizedString("connect-to", comment: "")
        static let port = NSLocalizedString("port", comment: "")
        static let path = NSLocalizedString("path", comment: "")
        static let realm = NSLocalizedString("realm", comment: "")
        static let clientID = NSLocalizedString("client-id", comment: "")
        static let username = NSLocalizedString("username-or-email", comment: "")
        static let repository = NSLocalizedString("content-services-url", comment: "")
        static let password = NSLocalizedString("password", comment: "")
    }

    struct Labels {
        static let transportProtocol = NSLocalizedString("transport-protocol", comment: "")
        static let https = NSLocalizedString("https", comment: "")
        static let AlfrescoContentSettings = NSLocalizedString("alfresco-content-settings", comment: "")
        static let authentication = NSLocalizedString("authentication", comment: "")
        static let infoBasicAuthConnectTo = NSLocalizedString("info-connect-to", comment: "")
        static let infoAimsConnectTo = NSLocalizedString("info-aims-connect-to", comment: "")
        static let allowSSO = NSLocalizedString("login-allow-sso", comment: "")
        static let needHelpTitle = NSLocalizedString("help", comment: "")
        static let conneting = NSLocalizedString("connecting", comment: "")
        static let signingIn = NSLocalizedString("signing-in", comment: "")
        static let sessionExpiredTitle =  NSLocalizedString("session-expired", comment: "")
        static let sesssionExpiredMessage =  NSLocalizedString("sesssion-expired-message", comment: "")
    }

    struct ScreenTitles {
        static let advancedSettings = NSLocalizedString("advanced-settings", comment: "")
        static let settings = NSLocalizedString("settings", comment: "")
        static let recent = NSLocalizedString("recent", comment: "")
        static let favorites = NSLocalizedString("favorites", comment: "")
        static let browse = NSLocalizedString("browse", comment: "")
    }

    struct Textviews {
        static let serviceURLHint = NSLocalizedString("help-service-url-hint", comment: "")
        static let advancedSettingsHint = NSLocalizedString("help-advanced-settings-hint", comment: "")
        static let ssoHint = NSLocalizedString("help-sso-hint", comment: "")
    }

    struct Errors {
        static let generic = NSLocalizedString("error-login-generic", comment: "")
        static let noAuthAlfrescoURL = NSLocalizedString("error-login-alfresco-url", comment: "")
        static let checkConnectURL = NSLocalizedString("error-login-check-connect-url", comment: "")
        static let wrongCredentials = NSLocalizedString("error-login-wrong-credential", comment: "")
        static let saveSettings = NSLocalizedString("approved-login-save-settings", comment: "")
        static let pathEmpty = NSLocalizedString("warning-login-path-empty", comment: "")
        static let noLongerAuthenticated = NSLocalizedString("error-logjn-no-longer-authenticated", comment: "")
        static let somethingWentWrong = NSLocalizedString("error-something-went-wrong", comment: "")
    }

    struct Theme {
        static let theme = NSLocalizedString("theme", comment: "")
        static let auto = NSLocalizedString("auto", comment: "")
        static let dark = NSLocalizedString("dark", comment: "")
        static let light = NSLocalizedString("light", comment: "")
    }

    struct Settings {
        static let failedProfileInfo = NSLocalizedString("failed-profile-info", comment: "")
        static let appVersion = NSLocalizedString("app-version", comment: "")
        static let signOutConfirmation = NSLocalizedString("sign-out-confirmation", comment: "")
    }

    struct Search {
        static let title = NSLocalizedString("empty-list", comment: "")
        static let subtitle = NSLocalizedString("empty-list-subtitle", comment: "")
        static let searching = NSLocalizedString("searching", comment: "")
        static let noRecentSearch = NSLocalizedString("no-recent-search", comment: "")
        static let recentSearch = NSLocalizedString("recent-search", comment: "")
        static let filterFiles = NSLocalizedString("files", comment: "")
        static let filterFolders = NSLocalizedString("folders", comment: "")
        static let filterLibraries = NSLocalizedString("libraries", comment: "")
        static let filterFoldersAndFiles = NSLocalizedString("file-and-folders", comment: "")
        static let searchIn = NSLocalizedString("search-in", comment: "")
    }

    struct GroupListSection {
        static let today = NSLocalizedString("today", comment: "")
        static let yesterday = NSLocalizedString("yesterday", comment: "")
        static let thisWeek = NSLocalizedString("this-week", comment: "")
        static let lastWeek = NSLocalizedString("last-week", comment: "")
        static let thisMonth = NSLocalizedString("this-month", comment: "")
        static let older = NSLocalizedString("older", comment: "")
    }

    struct BrowseStaticList {
        static let personalFiles = NSLocalizedString("personal-files", comment: "")
        static let myLibraries = NSLocalizedString("my-libraries", comment: "")
        static let shared = NSLocalizedString("shared", comment: "")
        static let trash = NSLocalizedString("trash", comment: "")
    }

    struct FilePreview {
        static let noPreview = NSLocalizedString("no-preview", comment: "")
        static let passwordPromptTitle = NSLocalizedString("password-prompt", comment: "")
        static let passwordPromptMessage = NSLocalizedString("password-prompt-message", comment: "")
        static let passwordPromptFailTitle = NSLocalizedString("password-prompt-fail", comment: "")
        static let passwordPromptFailMessage = NSLocalizedString("password-prompt-fail-message", comment: "")
        static let passwordPromptSubmit = NSLocalizedString("password-prompt-submit", comment: "")
        static let preparingPreviewMessage = NSLocalizedString("preparing-preview-message", comment: "")
        static let loadingPreviewMessage = NSLocalizedString("loading-preview-message", comment: "")
    }

    struct ActionMenu {
        static let addFavorite = NSLocalizedString("action-menu-add-favorite", comment: "")
        static let removeFavorite = NSLocalizedString("action-menu-remove-favorite", comment: "")
        static let delete = NSLocalizedString("action-menu-delete", comment: "")
    }
}
