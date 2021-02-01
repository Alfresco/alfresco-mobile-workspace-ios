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

enum SettingsItemType: String {
    case account = "avatar"
    case label = "label"
    case theme = "ic-theme"
    case syncOverMobileData = "ic-sync-plan-data"
}

class SettingsItem: Equatable {
    var icon: UIImage?
    var title: String
    var subtitle: String
    var type: SettingsItemType

    init(type: SettingsItemType,
         title: String,
         subtitle: String,
         icon: UIImage? = nil) {

        self.title = title
        self.subtitle = subtitle
        self.type = type
        if icon == nil {
            self.icon = UIImage(named: type.rawValue)
        }
    }

    static func == (lhs: SettingsItem, rhs: SettingsItem) -> Bool {
        if lhs.title == rhs.title && lhs.subtitle == rhs.subtitle {
            return true
        }
        return false
    }
}
