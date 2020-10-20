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

enum GroupedListType {
    case none
    case today
    case yesterday
    case thisWeek
    case lastWeek
    case thisMonth
    case older
}

class GroupedList {
    var titleGroup: String
    var type: GroupedListType
    var list: [ListNode]

    init(type: GroupedListType, list: [ListNode]) {
        self.type = type
        self.list = list
        switch type {
        case .today:
            titleGroup = LocalizationConstants.GroupListSection.today
        case .yesterday:
            titleGroup = LocalizationConstants.GroupListSection.yesterday
        case .thisWeek:
            titleGroup = LocalizationConstants.GroupListSection.thisWeek
        case .lastWeek:
            titleGroup = LocalizationConstants.GroupListSection.lastWeek
        case .thisMonth:
            titleGroup = LocalizationConstants.GroupListSection.thisMonth
        case .older:
            titleGroup = LocalizationConstants.GroupListSection.older
        default:
            titleGroup = ""
        }
    }
}
