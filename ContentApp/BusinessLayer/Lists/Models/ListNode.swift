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

enum SiteRole: String {
    case manager = "SiteManager"
    case collaborator = "SiteCollaborator"
    case contributor = "SiteContributor"
    case consumer = "SiteConsumer"
    case unknown = "unknown"
}

typealias CreatedNodeType = (String, String, String)

class ListNode: Hashable, Entity {
    var id: Id = 0 // swiftlint:disable:this identifier_name
    var parentGuid: String?
    var guid: String
    var siteID: String
    var destination: String?
    var mimeType: String?
    var title: String
    var path: String
    var modifiedAt: Date?
    var favorite: Bool?
    var trashed: Bool?
    var offline: Bool?

    // objectbox: convert = { "default": ".unknown" }
    var nodeType: NodeType
    // objectbox: convert = { "default": ".unknown" }
    var siteRole: SiteRole = .unknown
    // objectbox: convert = { "dbType": "String", "converter": "AllowableOperationsConverter" }
    var allowableOperations: [AllowableOperationsType] = []

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
         allowableOperations: [String]? = nil,
         siteRole: String? = nil,
         trashed: Bool = false,
         offline: Bool = false,
         destionation: String? = nil) {

        self.guid = guid
        self.siteID = siteID
        self.parentGuid = parentGuid
        self.mimeType = mimeType
        self.title = title
        self.path = path
        self.modifiedAt = modifiedAt
        self.nodeType = nodeType
        self.favorite = favorite
        self.offline = offline
        self.allowableOperations = parse(allowableOperations)
        self.siteRole = parse(siteRole)
        self.trashed = trashed
        self.destination = destionation
    }

    init() {
        guid = ""
        siteID = ""
        title = ""
        path = ""
        nodeType = .unknown
        allowableOperations = []
        siteRole = .unknown
    }

    // MARK: - Public Helpers

    static func == (lhs: ListNode, rhs: ListNode) -> Bool {
        return lhs.guid == rhs.guid
    }

    func shouldUpdate() -> Bool {
        if self.trashed == true {
            return false
        }
        if self.nodeType == .site {
            if self.favorite == nil {
                return true
            }
        }

        if self.nodeType == .file || self.nodeType == .folder {
            if self.favorite == nil {
                return true
            }
        }
        return false
    }

    func isMarkedOffline() -> Bool {
        let dataAccessor = ListNodeDataAccessor()
        return dataAccessor.isNodeMarkedAsOffline(node: self)
    }

    func hasPersmission(to type: AllowableOperationsType) -> Bool {
        return allowableOperations.contains(type)
    }

    func hasPermissionToCreate() -> Bool {
        if self.nodeType == .folder {
            return hasPersmission(to: .create)
        } else if self.nodeType == .site {
            return !(hasRole(to: .consumer) || hasRole(to: .unknown))
        }
        return false
    }

    func hasRole(to type: SiteRole) -> Bool {
        return siteRole == type
    }

    func truncateTailTitle() -> String {
        let text = self.title.prefix(kTruncateLimitTitleInSnackbar)
        if text == self.title {
            return String(text)
        }
        return text + "..."
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(guid)
    }

    // MARK: - Creation

    static private var mapExtensions: [ActionMenuType: CreatedNodeType] {
        return [.createMSExcel: ("xlsx", "cm:content", "excel"),
                .createMSWord: ("docx", "cm:content", "word"),
                .createMSPowerPoint: ("pptx", "cm:content", "powerpoint"),
                .createFolder: ("", "cm:folder", "")]
    }

    static func getExtension(from type: ActionMenuType?) -> String? {
        guard let type = type else { return nil }
        if let ext = ListNode.mapExtensions[type], ext.0 != "" {
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

    private func parse(_ allowableOperations: [String]?) -> [AllowableOperationsType] {
        guard let allowableOperations = allowableOperations else { return [] }
        var allowableOperationsTypes = [AllowableOperationsType]()

        _ = allowableOperations.map {
            allowableOperationsTypes.append(AllowableOperationsType(rawValue: $0) ?? .unknown)
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
