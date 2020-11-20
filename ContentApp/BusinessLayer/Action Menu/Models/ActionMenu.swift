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

import UIKit

class ActionMenu {
    var title: String
    var type: ActionMenuType {
        didSet {
            self.icon = UIImage(named: self.type.rawValue) ?? UIImage()
        }
    }
    var icon: UIImage

    init(title: String, type: ActionMenuType, icon: UIImage? = nil) {
        self.title = title
        self.type = type
        if let icon = icon {
            self.icon = icon
        } else {
            self.icon = UIImage(named: self.type.rawValue) ?? UIImage()
        }
    }

    static private var mapExtensions: [ActionMenuType: (String, String, String)] {
        return [.createMSExcel: ("xlsx", "cm:content", "excel"),
                .createMSWord: ("docx", "cm:content", "word"),
                .createMSPowerPoint: ("pptx", "cm:content", "powerpoint")]
    }

    func getExtension() -> String {
        if let ext = ActionMenu.mapExtensions[self.type] {
            return ext.0
        }
        return ""
    }

    func getNodeType() -> String {
        if let ext = ActionMenu.mapExtensions[self.type] {
            return ext.1
        }
        return ""
    }

    func getTemplateBundlePath() -> String {
        guard let obj = ActionMenu.mapExtensions[self.type] else { return "" }
        if let filePath = Bundle.main.path(forResource: obj.2, ofType: obj.0) {
            return filePath
        }
        return ""
    }
}

enum ActionMenuType: String {
    // MARK: - Generic
    case placeholder = "ic-placeholder"
    case node = "ic-node"
    case more = "ic-action-more"

    // MARK: - Nodes
    case addFavorite = "ic-action-outline-favorite"
    case removeFavorite = "ic-action-fill-favorite"
    case moveTrash = "ic-action-delete"
    case download = "ic-action-download"
    case restore = "ic-restore"
    case permanentlyDelete = "ic-action-delete-forever"

    // MARK: - Create
    case createMSExcel = "ic-ms_spreadsheet"
    case createMSWord = "ic-ms_document"
    case createMSPowerPoint = "ic-ms_presentation"
}
