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

enum Event {

    enum Action: String, CaseIterable {
        case discardCaptures = "event_discard_capture"
        case filePreview = "event_file_preview"
        case download = "event_download"
        case addFavorite = "event_add_to_favorites"
        case removeFavorite = "event_remove_from_favorite"
        case renameNode = "event_rename"
        case moveToFolder = "event_move"
        case markOffline = "event_Make_available_offline"
        case removeOffline = "event_remove_offline"
        case moveTrash = "event_move_to_trash"
        case changeTheme = "event_change_theme"
        case createFolder = "event_new_folder"
        case uploadMedia = "event_upload_photos_or_videos"
        case createMedia = "event_take_a_photo_or_video"
        case uploadFiles = "event_upload_files"
        case appLaunched = "event_app_launched"
        case searchFacets = "event_search_facets"
        case permanentlyDelete = "event_permanently_delete"
        case restore = "event_restore"
        case scanDocuments = "event_scan_documents"
        case createdDateRange = "event_due_date"
        case radio = "event_status"
        case text = "event_task_name"
        case taskFilterReset = "event_reset"
        case taskComplete = "event_task_complete"
        case createTask = "event_create_task"
        case updateTask = "event_update_task_details"
        case deleteTaskAttachment = "event_delete_task_attachment"
        case editTask = "event_edit_task"
        case doneTask = "event_done_task"
        case uploadTaskAttachment = "event_upload_task_attachment"
        case taskTakePhoto = "event_task_upload_photos_or_videos"
        case taskUploadPhoto = "event_task_take_a_photo_or_video"
        case taskUploadFile = "event_task_upload_files"

    }

    enum API: String {
        case apiNewFolder = "event_api_new_folder"
        case apiUploadMedia = "event_api_upload_files"
        case apiLogin = "event_api_login"
        case apiDeleteTaskAttachment = "event_api_delete_task_attachment"
        case apiUploadTaskAttachment = "event_api_upload_task_attachment"
        case apiAssignUser = "event_api_assign_user"
        case apiSearchUser = "event_api_search_user"
    }
    
    enum Page: String {
        case recentTab = "page_view_recent"
        case favoritesTab = "page_view_favorites"
        case offlineTab = "page_view_offline"
        case browseTab = "page_view_browse"
        case personalFiles = "page_view_personal_files"
        case myLibraries = "page_view_my_libraries"
        case shared = "page_view_shared"
        case trash = "page_view_trash"
        case search = "page_view_search"
        case shareExtension = "page_view_share_extension"
        case transfers = "page_view_transfers"
        case taskTab = "page_view_tasks"
        case taskDetailScreen = "page_view_task_view"
        case taskCommentsScreen = "page_view_task_comments"
        case taskAttachmentsScreen = "page_view_attached_files"
    }
}

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
        static let eventName = "event_name"
        static let fileMimetype = "file_mimetype"
        static let fileExtension = "file_extension"
        static let previewSuccess = "success"
        static let isFile = "is_file"
        static let theme = "theme_name"
        static let facet = "facet_name"
        static let assetsCount = "numberOfAssets"
        static let fileSize = "file_size"
    }
}
