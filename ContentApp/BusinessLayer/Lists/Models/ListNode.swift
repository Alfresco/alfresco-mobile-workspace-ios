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
import AlfrescoContent
import ObjectBox
import DeepDiff

enum NodeType: String {
    case site = "st:site"
    case folder = "cm:folder"
    case file = "cm:content"
    case fileLink = "app:filelink"
    case folderLink = "app:folderlink"
    case unknown = ""

    func plainType() -> String {
        switch self {
        case .file:
            return "file"
        case .folder:
            return "folder"
        case .site:
            return "site"
        default:
            return ""
        }
    }
}

enum AllowableOperationsType: String {
    case update
    case create
    case updatePermissions
    case delete
    case unknown
}

enum SyncStatus: String {
    case pending
    case inProgress
    case synced
    case error
    case undefined
}

enum MarkedForStatus: String {
    case upload
    case download
    case removal
    case undefined
}

enum SiteRole: String {
    case manager = "SiteManager"
    case collaborator = "SiteCollaborator"
    case contributor = "SiteContributor"
    case consumer = "SiteConsumer"
    case unknown = "unknown"
}

let listNodeSectionIdentifier = "list-section"

typealias CreatedNodeType = (String, String, String)

class ListNode: Hashable, Entity, DiffAware {
    var id: Id = 0 // swiftlint:disable:this identifier_name
    var parentGuid: String?
    var guid = ""
    var siteID = ""
    var destination: String?
    var mimeType: String?
    var title = ""
    var path = ""
    var modifiedAt: Date?
    var favorite: Bool?
    var trashed = false
    var markedAsOffline = false
    var isFile = false
    var isFolder = false
    var uploadLocalPath: String?

    // objectbox: convert = { "default": ".unknown" }
    var nodeType: NodeType = .unknown
    // objectbox: convert = { "default": ".unknown" }
    var siteRole: SiteRole = .unknown
    // objectbox: convert = { "default": ".undefined" }
    var syncStatus: SyncStatus = .undefined
    // objectbox: convert = { "default": ".undefined" }
    var markedFor: MarkedForStatus = .undefined
    // objectbox: convert = { "dbType": "String", "converter": "AllowableOperationsConverter" }
    var allowableOperations: [AllowableOperationsType] = [.unknown]

    // MARK: - Init

    init(guid: String,
         siteID: String = "",
         parentGuid: String? = nil,
         mimeType: String? = nil,
         title: String,
         path: String,
         modifiedAt: Date? = nil,
         nodeType: NodeType,
         favorite: Bool? = nil,
         syncStatus: SyncStatus = .undefined,
         markedOfflineStatus: MarkedForStatus = .undefined,
         allowableOperations: [String] = [],
         siteRole: String? = nil,
         trashed: Bool = false,
         destination: String? = nil,
         isFile: Bool = false,
         isFolder: Bool = false,
         uploadLocalPath: String = "") {
        self.guid = guid
        self.siteID = siteID
        self.parentGuid = parentGuid
        self.mimeType = mimeType
        self.title = title
        self.path = path
        self.modifiedAt = modifiedAt
        self.nodeType = nodeType
        self.favorite = favorite
        self.syncStatus = syncStatus
        self.markedFor = markedOfflineStatus
        self.allowableOperations = parse(allowableOperations)
        self.siteRole = parse(siteRole)
        self.trashed = trashed
        self.destination = destination
        self.isFile = isFile
        self.isFolder = isFolder
        self.uploadLocalPath = uploadLocalPath
    }

    // Default initializer required by ObjectBox
    init() {}

    // MARK: - Public Helpers

    func update(with newVersion: ListNode) {
        parentGuid = newVersion.parentGuid
        siteID = newVersion.siteID
        destination = newVersion.destination
        mimeType = newVersion.mimeType
        title = newVersion.title
        path = newVersion.path
        modifiedAt = newVersion.modifiedAt
        favorite = newVersion.favorite
        nodeType = newVersion.nodeType
        allowableOperations = newVersion.allowableOperations
        syncStatus = newVersion.syncStatus
        markedAsOffline = newVersion.markedAsOffline
        markedFor = newVersion.markedFor
        isFile = newVersion.isFile
        isFolder = newVersion.isFolder
        uploadLocalPath = newVersion.uploadLocalPath
    }

    static func == (lhs: ListNode, rhs: ListNode) -> Bool {
        return lhs.guid == rhs.guid &&
            lhs.id == rhs.id
    }

    static func compareContent(_ a: ListNode, _ b: ListNode) -> Bool { // swiftlint:disable:this identifier_name
        return a.markedFor == b.markedFor &&
            a.syncStatus == b.syncStatus &&
            a.modifiedAt == b.modifiedAt &&
            a.favorite == b.favorite &&
            a.allowableOperations == b.allowableOperations &&
            a.markedAsOffline == b.markedAsOffline
    }

    func shouldUpdate() -> Bool {
        if trashed == true {
            return false
        }

        if favorite == nil {
            return true
        }

        switch nodeType {
        case .site: break
        default:
            if allowableOperations.count == 1  &&
                allowableOperations.first == AllowableOperationsType.unknown {
                return true
            }
        }
        return false
    }

    func removeAllowableOperationUnknown() {
        if allowableOperations.count == 1 &&
            allowableOperations.first == AllowableOperationsType.unknown {
            allowableOperations.removeFirst()
        }
    }

    func isMarkedOffline() -> Bool {
        let dataAccessor = ListNodeDataAccessor()
        return dataAccessor.isNodeMarkedAsOffline(node: self)
    }

    func hasSyncStatus() -> SyncStatus {
        let dataAccessor = ListNodeDataAccessor()
        return dataAccessor.syncStatus(for: self)
    }

    func hasPersmission(to type: AllowableOperationsType) -> Bool {
        return allowableOperations.contains(type)
    }

    func hasPermissionToCreate() -> Bool {
        if nodeType == .folder {
            return hasPersmission(to: .create)
        } else if nodeType == .site {
            return !(hasRole(to: .consumer) || hasRole(to: .unknown))
        }
        return false
    }

    func hasRole(to type: SiteRole) -> Bool {
        return siteRole == type
    }

    func truncateTailTitle() -> String {
        let limitCharacters = 20
        let text = title.prefix(limitCharacters)
        if text == title {
            return String(text)
        }
        return text + "..."
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(guid)
    }

    func isAFileType() -> Bool {
        switch nodeType {
        case .file, .fileLink:
            return true
        default:
            return isFile
        }
    }

    func isAFolderType() -> Bool {
        switch nodeType {
        case .folder, .folderLink:
            return true
        default:
            return isFolder
        }
    }

    // MARK: - Creation

    static private var mapExtensions: [ActionMenuType: CreatedNodeType] {
        return [.createMSExcel: ("xlsx", "cm:content", "excel"),
                .createMSWord: ("docx", "cm:content", "word"),
                .createMSPowerPoint: ("pptx", "cm:content", "powerpoint"),
                .createFolder: ("", "cm:folder", ""),
                .createMedia: ("", "cm:content", ""),
                .uploadMedia: ("", "cm:content", "")]
    }

    static func getExtension(from type: ActionMenuType?) -> String? {
        guard let type = type else { return nil }
        if let ext = ListNode.mapExtensions[type], !ext.0.isEmpty {
            return  "." + ext.0
        }
        return nil
    }

    static func nodeType(from type: ActionMenuType?) -> String? {
        guard let type = type else { return nil }
        if let ext = ListNode.mapExtensions[type] {
            return ext.1
        }
        return nil
    }

    static func templateFileBundlePath(from type: ActionMenuType?) -> String? {
        guard  let type = type,
               let ext = ListNode.mapExtensions[type] else { return nil }
        if let filePath = Bundle.main.path(forResource: ext.2, ofType: ext.0) {
            return filePath
        }
        return nil
    }

    // MARK: - Private Helpers

    private func parse(_ allowableOperations: [String]) -> [AllowableOperationsType] {
        guard !allowableOperations.isEmpty else { return [.unknown] }
        var allowableOperationsTypes = [AllowableOperationsType]()

        _ = allowableOperations.map {
            if let type = AllowableOperationsType(rawValue: $0) {
                allowableOperationsTypes.append(type)
            }
        }

        return allowableOperationsTypes
    }

    private func parse(_ siteRole: String?) -> SiteRole {
        guard let siteRole = siteRole else { return .unknown}
        return SiteRole(rawValue: siteRole) ?? .unknown
    }
}

class AllowableOperationsConverter {
    static func convert(_ enumerated: [AllowableOperationsType]) -> String {
        var convertedString = ""
        _ = enumerated.enumerated().map {(index, element) in
            if index == enumerated.count - 1 {
                convertedString.append(String(format: "%@", element.rawValue))
            } else {
                convertedString.append(String(format: "%@,", element.rawValue))
            }
        }

        return convertedString
    }

    static func convert(_ string: String?) -> [AllowableOperationsType] {
        guard let string = string else { return [AllowableOperationsType.unknown] }
        var operations: [AllowableOperationsType] = []
        _ = string.split(separator: ",").map {
            operations.append(AllowableOperationsType(rawValue: String($0)) ?? .unknown)
        }

        return operations
    }
}
