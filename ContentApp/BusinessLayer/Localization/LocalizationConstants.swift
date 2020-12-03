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
        static let needHelpAlfresco = NSLocalizedString("need-help-alfresco", comment: "")
        static let resetToDefault = NSLocalizedString("reset-to-default", comment: "")
        static let save = NSLocalizedString("save", comment: "")
        static let signin = NSLocalizedString("sign-in", comment: "")
        static let signInWithSSO = NSLocalizedString("sign-in-with-sso", comment: "")
        static let snackbarConfirmation = "x"
        static let signOut = NSLocalizedString("sign-out", comment: "")
        static let retry = NSLocalizedString("retry", comment: "")
        static let yes = NSLocalizedString("yes", comment: "")
        static let cancel = NSLocalizedString("cancel", comment: "")
        static let delete = NSLocalizedString("delete", comment: "")
        static let create = NSLocalizedString("create", comment: "")
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
        static let description = NSLocalizedString("description", comment: "")
        static let name = NSLocalizedString("name", comment: "")
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
        static let howToConnectTitle = NSLocalizedString("how-to-connect-to-alfresco", comment: "")
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

    struct Help {
        static let connectTitleSection1 = NSLocalizedString("help-connect-title-section1", comment: "")
        static let connectSection1Paragraph = NSLocalizedString("help-connect-section1-paragraph", comment: "")
        static let connectTitleSection2 = NSLocalizedString("help-connect-title-section2", comment: "")
        static let connectSection2Paragraph = NSLocalizedString("help-connect-section2-paragraph", comment: "")
        static let advancedSettingsTitleSection1 = NSLocalizedString("help-advanced-settings-title-section1", comment: "")
        static let advancedSettingsSection1Paragraph = NSLocalizedString("help-advanced-settings-section1-paragraph", comment: "")
        static let ssoTitleSection1 = NSLocalizedString("help-sso-title-section1", comment: "")
        static let ssoSection1Paragraph = NSLocalizedString("help-sso-section1-paragraph", comment: "")
    }

    struct Errors {
        static let generic = NSLocalizedString("error-login-generic", comment: "")
        static let noAuthAlfrescoURL = NSLocalizedString("error-login-alfresco-url", comment: "")
        static let checkConnectURL = NSLocalizedString("error-login-check-connect-url", comment: "")
        static let wrongCredentials = NSLocalizedString("error-login-wrong-credential", comment: "")
        static let pathEmpty = NSLocalizedString("warning-login-path-empty", comment: "")
        static let noLongerAuthenticated = NSLocalizedString("error-logjn-no-longer-authenticated", comment: "")
        static let somethingWentWrong = NSLocalizedString("error-something-went-wrong", comment: "")
        static let errorUnknown = NSLocalizedString("error-unknown", comment: "")
        static let errorTimeout = NSLocalizedString("error-timeout", comment: "")
        static let errorFolderSameName = NSLocalizedString("error-folder-same-name", comment: "")
        static let errorNodeNameSpecialCharacters = NSLocalizedString("error-node-name-special-characters", comment: "")
        static let errorFolderNameEndPeriod = NSLocalizedString("error-folder-name-end-period", comment: "")
        static let errorFolderNameContainOnlySpaces = NSLocalizedString("error-folder-name-contain-only-spaces", comment: "")

    }

    struct Approved {
        static let saveSettings = NSLocalizedString("approved-login-save-settings", comment: "")
        static let addedFavorites = NSLocalizedString("approved-added-favorites", comment: "")
        static let removedFavorites = NSLocalizedString("approved-removed-favorites", comment: "")
        static let movedTrash = NSLocalizedString("approved-moved-trash", comment: "")
        static let restored = NSLocalizedString("approved-restored", comment: "")
        static let deleted = NSLocalizedString("approved-deleted", comment: "")
        static let created = NSLocalizedString("approved-created", comment: "")
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
        static let moveTrash = NSLocalizedString("action-menu-move-trash", comment: "")
        static let download = NSLocalizedString("action-menu-download", comment: "")
        static let restore = NSLocalizedString("action-menu-restore", comment: "")
        static let permanentlyDelete = NSLocalizedString("action-menu-permanently-delete", comment: "")
        static let createMSword = NSLocalizedString("action-menu-create-ms-word", comment: "")
        static let createMSexcel = NSLocalizedString("action-menu-create-ms-excel", comment: "")
        static let createMSpowerpoint = NSLocalizedString("action-menu-create-ms-powerpoint", comment: "")
        static let createFolder = NSLocalizedString("action-menu-create-folder", comment: "")
    }

    struct NodeActionsDialog {
        static let deleteTitle = NSLocalizedString("dialog-delete-title", comment: "")
        static let deleteMessage = NSLocalizedString("dialog-delete-message", comment: "")
        static let downloadMessage = NSLocalizedString("dialog-download-message", comment: "")
        static let uploadMessage = NSLocalizedString("dialog-upload-message", comment: "")
    }

    struct EmptyLists {
        static let recentsTitle = NSLocalizedString("empty-recent-title", comment: "")
        static let recentsDescription = NSLocalizedString("empty-recent-description", comment: "")
        static let favoritesFilesFoldersTitle = NSLocalizedString("empty-favorites-files-folders-title", comment: "")
        static let favoritesLibrariesTitle = NSLocalizedString("empty-favorites-libraries-title", comment: "")
        static let favoritesDescription = NSLocalizedString("empty-favorites-description", comment: "")
        static let folderTitle = NSLocalizedString("empty-folder-title", comment: "")
        static let folderDescription = NSLocalizedString("empty-folder-description", comment: "")
        static let searchTitle = NSLocalizedString("empty-search-title", comment: "")
        static let searchDescription = NSLocalizedString("empty-search-description", comment: "")
    }

    struct PrivacySettings {
        static let privacyPhotosTitle = NSLocalizedString("privacy-photos-title", comment: "")
        static let privacyPhotosDescription = NSLocalizedString("privacy-photos-description", comment: "")
        static let privacyButton = NSLocalizedString("privacy-button", comment: "")
    }
}
