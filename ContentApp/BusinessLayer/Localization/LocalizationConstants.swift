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

    struct General {
        static let retry = NSLocalizedString("retry", comment: "")
        static let yes = NSLocalizedString("yes", comment: "")
        static let ok = NSLocalizedString("ok", comment: "") // swiftlint:disable:this identifier_name
        static let later = NSLocalizedString("later", comment: "")
        static let cancel = NSLocalizedString("cancel", comment: "")
        static let delete = NSLocalizedString("delete", comment: "")
        static let create = NSLocalizedString("create", comment: "")
        static let save = NSLocalizedString("save", comment: "")
        static let discard = NSLocalizedString("discard", comment: "")
        static let done = NSLocalizedString("done", comment: "")
        static let rename = NSLocalizedString("rename", comment: "")
        static let update = NSLocalizedString("update", comment: "")
        static let edit = NSLocalizedString("edit", comment: "")
    }

    struct Buttons {
        static let connect = NSLocalizedString("connect", comment: "")
        static let advancedSetting = NSLocalizedString("advanced-settings", comment: "")
        static let needHelp = NSLocalizedString("need-help", comment: "")
        static let needHelpAlfresco = NSLocalizedString("need-help-alfresco", comment: "")
        static let resetToDefault = NSLocalizedString("reset-to-default", comment: "")
        static let signin = NSLocalizedString("sign-in", comment: "")
        static let signInWithSSO = NSLocalizedString("sign-in-with-sso", comment: "")
        static let signOut = NSLocalizedString("sign-out", comment: "")
        static let syncAll = NSLocalizedString("sync-all", comment: "")
        static let moveHere = NSLocalizedString("action-menu-move-folder", comment: "")
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
        static let filename = NSLocalizedString("file-name", comment: "")
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
        static let syncing = NSLocalizedString("syncing", comment: "")
        static let syncFailed = NSLocalizedString("sync-failed", comment: "")
    }

    struct ScreenTitles {
        static let advancedSettings = NSLocalizedString("advanced-settings", comment: "")
        static let settings = NSLocalizedString("settings", comment: "")
        static let recent = NSLocalizedString("recent", comment: "")
        static let favorites = NSLocalizedString("favorites", comment: "")
        static let browse = NSLocalizedString("browse", comment: "")
        static let offline = NSLocalizedString("offline", comment: "")
        static let previewCaptureAsset = NSLocalizedString("preview-capture-asset", comment: "")
        static let galleryUpload = NSLocalizedString("gallery-upload", comment: "")
        static let transferFiles = NSLocalizedString("transfer-files", comment: "")
        static let tasks = NSLocalizedString("tasks-title", comment: "")
        static let workflows = NSLocalizedString("workflows-title", comment: "")
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
        static let errorGeneric = NSLocalizedString("error-generic", comment: "")
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
        static let errorEmptyFileName = NSLocalizedString("error-file-name-empty", comment: "")
    }

    struct Approved {
        static let saveSettings = NSLocalizedString("approved-login-save-settings", comment: "")
        static let addedFavorites = NSLocalizedString("approved-added-favorites", comment: "")
        static let removedFavorites = NSLocalizedString("approved-removed-favorites", comment: "")
        static let multipleItemsRemovedFavorites = NSLocalizedString("multiple-items-removed-favorites", comment: "")
        static let multipleItemsAdddedFavorites = NSLocalizedString("multiple-items-added-favorites", comment: "")
        static let movedTrash = NSLocalizedString("approved-moved-trash", comment: "")
        static let movedMultipleItemsToTrash = NSLocalizedString("approved-multiple-moved-to-trash", comment: "")
        static let restored = NSLocalizedString("approved-restored", comment: "")
        static let deleted = NSLocalizedString("approved-deleted", comment: "")
        static let created = NSLocalizedString("approved-created", comment: "")
        static let markOffline = NSLocalizedString("approved-mark-offline", comment: "")
        static let removeOffline = NSLocalizedString("approved-remove-offline", comment: "")
        static let uploadMedia = NSLocalizedString("approved-upload-media", comment: "")
        static let movedFileFolderSuccess = NSLocalizedString("approved-moved-folder", comment: "")
        static let updated = NSLocalizedString("approved-update", comment: "")
        static let uploadDocument = NSLocalizedString("approved-upload-scanned-document", comment: "")
        static let movedMultipleFileFolderSuccess = NSLocalizedString("approved-moved-multiple-files-to-folder", comment: "")
        static let markOfflineMultipleNodes = NSLocalizedString("approved-multiple-mark-offline", comment: "")
        static let removeOfflineMultipleNodes = NSLocalizedString("approved-multiple-remove-offline", comment: "")
        static let multipleRestored = NSLocalizedString("multiple-items-restored", comment: "")
        static let multipleDeleted = NSLocalizedString("multiple-items-deleted", comment: "")
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
        static let syncDataPlanTitle = NSLocalizedString("sync-data-title", comment: "")
        static let syncOnlyWifi = NSLocalizedString("sync-only-wifi", comment: "")
        static let syncWifiAndCellularData = NSLocalizedString("sync-wifi-cellular-data", comment: "")
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
    
    struct AdvanceSearch {
        static let title = NSLocalizedString("advance-search", comment: "")
        static let enter = NSLocalizedString("enter", comment: "")
        static let apply = NSLocalizedString("apply", comment: "")
        static let reset = NSLocalizedString("reset", comment: "")
        static let fromKeyword = NSLocalizedString("from-keyword", comment: "")
        static let toKeyword = NSLocalizedString("to-keyword", comment: "")
        static let invalidFormat = NSLocalizedString("invalid-format", comment: "")
        static let errorRequiredValue = NSLocalizedString("required-value", comment: "")
        static let searchPlaceholder = NSLocalizedString("APP.SEARCH.FIELD.PLACEHOLDER", comment: "")
        static let fileSizeUnit = NSLocalizedString("file-size-unit", comment: "")
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
        static let markOffline = NSLocalizedString("action-menu-mark-offline", comment: "")
        static let removeOffline = NSLocalizedString("action-menu-remove-offline", comment: "")
        static let createMedia = NSLocalizedString("action-menu-create-media", comment: "")
        static let uploadMedia = NSLocalizedString("action-menu-upload-media", comment: "")
        static let createSingleMedia = NSLocalizedString("action-menu-create-single-media", comment: "")
        static let uploadSingleMedia = NSLocalizedString("action-menu-upload-single-media", comment: "")
        static let uploadFiles = NSLocalizedString("action-menu-upload-files", comment: "")
        static let moveToFolder = NSLocalizedString("action-menu-move-folder", comment: "")
        static let renameNode = NSLocalizedString("action-menu-rename-node", comment: "")
        static let scanDocuments = NSLocalizedString("action-menu-scan-documents", comment: "")
        static let actionUnavailableTitle = NSLocalizedString("action-unavailable-title", comment: "")
        static let actionUnavailableMessage = NSLocalizedString("action-unavailable-message", comment: "")
    }

    struct Dialog {
        static let deleteTitle = NSLocalizedString("dialog-delete-title", comment: "")
        static let deleteMessage = NSLocalizedString("dialog-delete-message", comment: "")
        static let downloadMessage = NSLocalizedString("dialog-download-message", comment: "")
        static let uploadMessage = NSLocalizedString("dialog-upload-message", comment: "")
        static let sessionExpiredTitle =  NSLocalizedString("dialog-session-expired-title", comment: "")
        static let sessionExpiredMessage =  NSLocalizedString("dialog-session-expired-message", comment: "")
        static let overrideSyncCellularDataTitle =  NSLocalizedString("dialog-override-sync-cellular-data-title", comment: "")
        
        static let overrideSyncCellularDataMessage =  NSLocalizedString("dialog-override-sync-cellular-data-message", comment: "")
        static let discardCapturedAssetsTitle = NSLocalizedString("dialog-discard-captures-title", comment: "")
        static let discardCapturedAssetsMessage = NSLocalizedString("dialog-discard-captures-message", comment: "")
        static let sessionUnavailableTitle =  NSLocalizedString("dialog-session-unavailable-title", comment: "")
        static let sessionUnavailableMessage =  NSLocalizedString("dialog-session-unavailable-message", comment: "")
        static let internetUnavailableTitle =  NSLocalizedString("dialog-internet-unavailable-title", comment: "")
        static let internetUnavailableMessage =  NSLocalizedString("dialog-internet-unavailable-message", comment: "")
        static let discardScanFilesTitle = NSLocalizedString("dialog-discard-scanner-title", comment: "")
        static let discardScanFilesMessage = NSLocalizedString("dialog-discard-scanner-message", comment: "")
        static let completeTaskTitle =  NSLocalizedString("complete-task-dialog-title", comment: "")
        static let completeTaskMessage =  NSLocalizedString("complete-task-dialog-message", comment: "")
        static let confirmTitle =  NSLocalizedString("confirm-title", comment: "")
        static let completeTaskWhileAttachmentsInProgress =  NSLocalizedString("complete-task-dialog-message-attachments-in-progress", comment: "")
        static let multiDeleteMessage = NSLocalizedString("dialog-multi-delete-message", comment: "")
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
        static let offlineTitle = NSLocalizedString("empty-offline-title", comment: "")
        static let offlineDescription = NSLocalizedString("empty-offline-description", comment: "")
        static let galleryTitle = NSLocalizedString("empty-gallery-title", comment: "")
        static let galleryDescription = NSLocalizedString("empty-gallery-description", comment: "")
        static let uploadsTitle = NSLocalizedString("empty-uploads-title", comment: "")
        static let uploadsDescription = NSLocalizedString("empty-uploads-description", comment: "")
    }

    struct PrivacySettings {
        static let privacyButton = NSLocalizedString("privacy-button", comment: "")
        static let privacyPhotosTitle = NSLocalizedString("privacy-photos-title", comment: "")
        static let privacyPhotosDescription = NSLocalizedString("privacy-photos-description", comment: "")
        static let privacyCameraTitle = NSLocalizedString("privacy-camera-title", comment: "")
        static let privacyCameraDescription = NSLocalizedString("privacy-camera-description", comment: "")
    }
    
    struct Camera {
        static let photoMode = NSLocalizedString("photo-mode", comment: "")
        static let videoMode = NSLocalizedString("video-mode", comment: "")
        static let autoFlash = NSLocalizedString("auto-flash", comment: "")
        static let onFlash = NSLocalizedString("on-flash", comment: "")
        static let offFlash = NSLocalizedString("off-flash", comment: "")
    }
    
    struct Alert {
        static let alertTitle = NSLocalizedString("alert-title", comment: "")
        static let cameraUnavailable = NSLocalizedString("camera-unavailable", comment: "")
        static let searchMoveWarning = NSLocalizedString("search_move_warning", comment: "")
    }
    
    struct AppExtension {
        static let saveToAlfresco = NSLocalizedString("save-to-alfresco", comment: "")
        static let upload = NSLocalizedString("upload", comment: "")
        static let overrideSyncOnAlfrescoAppDataMessage =  NSLocalizedString("dialog-override-sync-alfresco-app-message", comment: "")
        static let uploadingFiles = NSLocalizedString("dialog-uploading-message", comment: "")
        static let uploadingTitle = NSLocalizedString("uploading-title", comment: "")
        static let waitingTitle = NSLocalizedString("waiting-title", comment: "")
        static let finishedUploadingMessage = NSLocalizedString("dialog-finished-uploading-message", comment: "")
        static let unsupportedFileFormat = NSLocalizedString("unsupported-file-format", comment: "")
    }
    
    struct Tasks {
        static let noTasksFound = NSLocalizedString("no-tasks-found", comment: "")
        static let createTaskMessage = NSLocalizedString("create-task-message", comment: "")
        static let low = NSLocalizedString("low", comment: "")
        static let medium = NSLocalizedString("medium", comment: "")
        static let high = NSLocalizedString("high", comment: "")
        static let notConfiguredMessage = NSLocalizedString("task-service-not-configured-message", comment: "")
        static let taskDetailTitle = NSLocalizedString("task-detail-title", comment: "")
        static let active = NSLocalizedString("active-title", comment: "")
        static let completed = NSLocalizedString("completed-title", comment: "")
        static let status = NSLocalizedString("status-title", comment: "")
        static let identifier = NSLocalizedString("identifier-title", comment: "")
        static let addCommentPlaceholder = NSLocalizedString("add-comment-placeholder", comment: "")
        static let commentsTitle = NSLocalizedString("comments-title", comment: "")
        static let multipleCommentTitle = NSLocalizedString("title-multiple-comment", comment: "")
        static let attachedFilesTitle = NSLocalizedString("attached-files-title", comment: "")
        static let multipleAttachmentsTitle = NSLocalizedString("title-multiple-attachments", comment: "")
        static let viewAllTitle = NSLocalizedString("view-all-title", comment: "")
        static let readMore = NSLocalizedString("read-more", comment: "")
        static let noAttachedFilesPlaceholder = NSLocalizedString("no-attached-files-placeholder", comment: "")
        static let send = NSLocalizedString("send-title", comment: "")
        static let noDueDate = NSLocalizedString("no-due-date", comment: "")
        static let completeTitle = NSLocalizedString("complete-title", comment: "")
        static let noDescription = NSLocalizedString("no-description", comment: "")
        static let newTask = NSLocalizedString("new-task", comment: "")
        static let editTask = NSLocalizedString("edit-task", comment: "")
        static let nextTitle = NSLocalizedString("next-title", comment: "")
    }
    
    struct Accessibility {
        static let userProfile = NSLocalizedString("user-profile", comment: "")
        static let resetFilters = NSLocalizedString("reset-filters", comment: "")
        static let tasksCollection = NSLocalizedString("tasks-filter-collection", comment: "")
        static let tasksCollectionHint = NSLocalizedString("tasks-filter-collection-hint", comment: "")
        static let priority = NSLocalizedString("priority", comment: "")
        static let title = NSLocalizedString("title", comment: "")
        static let assignee = NSLocalizedString("assignee", comment: "")
        static let closeButton = NSLocalizedString("close-button", comment: "")
        static let listOption = NSLocalizedString("list-option", comment: "")
        static let dueDate = NSLocalizedString("due-date", comment: "")
        static let back = NSLocalizedString("back-title", comment: "")
        static let date = NSLocalizedString("date-title", comment: "")
        static let userName = NSLocalizedString("user-name", comment: "")
        static let commentTitle = NSLocalizedString("comment-title", comment: "")
        static let sendButton = NSLocalizedString("send-button", comment: "")
        static let descriptionTitle = NSLocalizedString("description-title", comment: "")
        static let createTask = NSLocalizedString("create-task", comment: "")
        static let editNameAndDescription = NSLocalizedString("edit-name-description", comment: "")
        static let connectToTextField = NSLocalizedString("connect-to-textfield", comment: "")
        static let copyright = NSLocalizedString("copyright", comment: "")
        static let more = NSLocalizedString("more", comment: "")
        static let header = NSLocalizedString("header", comment: "")
        static let syncStatus = NSLocalizedString("sync-status", comment: "")
        static let markedForOffline = NSLocalizedString("marked-for-offline", comment: "")
        static let error = NSLocalizedString("error", comment: "")
        static let pending = NSLocalizedString("pending", comment: "")
        static let inProgress = NSLocalizedString("in-progress", comment: "")
        static let downloaded = NSLocalizedString("downloaded", comment: "")
        static let uploaded = NSLocalizedString("uploaded", comment: "")
        static let undefined = NSLocalizedString("undefined", comment: "")
        static let searchTitle = NSLocalizedString("search-title", comment: "")
        static let subTitle = NSLocalizedString("subtitle", comment: "")
        static let flashMode = NSLocalizedString("flash-mode", comment: "")
        static let switchCamera = NSLocalizedString("switch-camera", comment: "")
        static let shutterButton = NSLocalizedString("shutter", comment: "")
        static let download = NSLocalizedString("download", comment: "")
        static let selected = NSLocalizedString("selected", comment: "")
        static let startWorkflow = NSLocalizedString("start-workflow", comment: "")
        static let checkBox = NSLocalizedString("check-box-multi-select", comment: "")
    }
    
    struct EditTask {
        static let taskTitle = NSLocalizedString("task-title", comment: "")
        static let nameAndDescription = NSLocalizedString("name-and-description", comment: "")
        static let byName = NSLocalizedString("by-name", comment: "")
        static let byEmail = NSLocalizedString("by-email", comment: "")
        static let meTitle = NSLocalizedString("me-title", comment: "")
        static let searchPlaceholder = NSLocalizedString("search-placeholder", comment: "")
        static let discardEditTaskAlertMessage = NSLocalizedString("dialog-discard-edit-task-message", comment: "")
        static let deleteAttachmentAlertTitle = NSLocalizedString("delete-attachment-alert-title", comment: "")
        static let addAttachments = NSLocalizedString("add-attachments", comment: "")
        static let errorFileSizeExceeds = NSLocalizedString("file-size-exceed-error", comment: "")
    }
    
    struct Workflows {
        static let noWorkflowFound = NSLocalizedString("no-workflow-found", comment: "")
        static let startWorkflowMessage = NSLocalizedString("start-workflow-message", comment: "")
        static let notConfiguredMessage = NSLocalizedString("workflows-not-configured-message", comment: "")
        static let allTitle = NSLocalizedString("all-title", comment: "")
        static let filterOptions = NSLocalizedString("filter-options", comment: "")
        static let selectWorkflow = NSLocalizedString("select-workflow", comment: "")
        static let workflowTitle = NSLocalizedString("workflow-title", comment: "")
        static let individualTitle = NSLocalizedString("individual-title", comment: "")
        static let groupTitle = NSLocalizedString("group-title", comment: "")
        static let warningUploadingInQueue = NSLocalizedString("warning-message-uploading-in-progress", comment: "")
        static let placeholderSearchUser = NSLocalizedString("search-user", comment: "")
        static let placeholderSearchGroup = NSLocalizedString("search-group", comment: "")
        static let warningTitle = NSLocalizedString("warning-title", comment: "")
        static let attachmentInProgressWarning = NSLocalizedString("workflow-attachment-in-progress-warning-message", comment: "")
        static let selectAssigneeMessage = NSLocalizedString("please-select-assignee", comment: "")
        static let workflowsUnavailableTitle = NSLocalizedString("workflows_unavailable_title", comment: "")
        static let workflowsUnavailableMessage = NSLocalizedString("workflow_unavailable_message", comment: "")
        static let approveTitle = NSLocalizedString("text_approve", comment: "")
        static let rejectTitle = NSLocalizedString("text_reject", comment: "")
        static let reApprovalTitle = NSLocalizedString("text_send_approval_again", comment: "")
        static let stopApproval = NSLocalizedString("text_stop_approval_request", comment: "")
        static let selectAssignee = NSLocalizedString("select-assignee", comment: "")
        static let startDate = NSLocalizedString("start-date-title", comment: "")
        static let startedBy = NSLocalizedString("started-by", comment: "")
        static let selectStatusMessage = NSLocalizedString("please-select-status", comment: "")
        static let claimTitle = NSLocalizedString("claim-title", comment: "")
        static let releaseTitle = NSLocalizedString("release-title", comment: "")
        static let createdDate = NSLocalizedString("created_date", comment: "")
        static let noneTitle = NSLocalizedString("None", comment: "")
        static let actions = NSLocalizedString("actions", comment: "")
        static let attachFilesDescription = NSLocalizedString("empty-attachFiles-description", comment: "")
        static let noFolderAttached = NSLocalizedString("no-folder-attached", comment: "")
        static let multipleFolder = NSLocalizedString("multiple-folder", comment: "")
        static let select = NSLocalizedString("select", comment: "")
        static let info = NSLocalizedString("info", comment: "")
        static let complete = NSLocalizedString("complete", comment: "")
        static let noName = NSLocalizedString("no-name", comment: "")
        static let enterAtleastCharacters = NSLocalizedString("enter-atleast-characters", comment: "")
        static let enterMaximumCharacters = NSLocalizedString("enter-maximum-characters", comment: "")
        static let cannotBeLessThan = NSLocalizedString("cannot-be-less-than", comment: "")
        static let cannotBeGreaterThan = NSLocalizedString("cannot-be-greater-than", comment: "")
        static let useADifferentNumberFormat = NSLocalizedString("use-a-different-number-format", comment: "")
        static let notAbleToAttachTheSelectedContent = NSLocalizedString("not-able-to-attach-the-selected-content-in-this-form", comment: "")
        static let maximumFileSizeForUploads = NSLocalizedString("maximum-file-size-for-uploads", comment: "")
        static let hasInvalidUrl = NSLocalizedString("has-invalid-url", comment: "")
    }
    
    struct MultipleFilesSelection {
        static let multipleItemsCount = NSLocalizedString("multiple-selected-items-count", comment: "")
        static let maximumFileSelectionMessage = NSLocalizedString("maximum-items-selection-message", comment: "")
    }
}
