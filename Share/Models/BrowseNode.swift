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

enum BrowseType: String {
    case personalFiles = "PersonalFiles"
    case myLibraries = "MyLibraries"
}

struct BrowseNode {
    var title: String
    var icon: String
    var type: BrowseType
    var accessibilityId: String?

    init(type: BrowseType) {
        self.type = type
        switch type {
        case .personalFiles:
            self.title = LocalizationConstants.BrowseStaticList.personalFiles
            self.icon = "ic-personal_files"
            self.accessibilityId = "personal-files"
        case .myLibraries:
            self.title = LocalizationConstants.BrowseStaticList.myLibraries
            self.icon = "ic-my_libraries"
            self.accessibilityId = "my-libraries"
        }
    }
}
