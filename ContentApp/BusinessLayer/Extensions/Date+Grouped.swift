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

extension Date {
    var calendar: Calendar { Calendar.current }
    var components: Set<Calendar.Component> { [.year, .month, .day, .weekOfYear] }
    var todayDateComponents: DateComponents { calendar.dateComponents(components, from: Date()) }
    var dateComponents: DateComponents { calendar.dateComponents(components, from: self) }

    var isInToday: Bool { calendar.isDateInToday(self) }
    var isInYesterday: Bool { calendar.isDateInYesterday(self) }

    var isInThisWeek: Bool {
        guard let selfWeekOfYear = dateComponents.weekOfYear,
            let todayWeekOfYear = todayDateComponents.weekOfYear else {
                return false
        }
        return selfWeekOfYear == todayWeekOfYear
    }

    var isInLastWeek: Bool {
        var selfDateComponent = calendar.dateComponents(components, from: self)
        guard let selfDay = selfDateComponent.day else {
            return false
        }

        selfDateComponent.day = selfDay + 7
        if let dateInThisWeek = calendar.date(from: selfDateComponent) {
            return dateInThisWeek.isInThisWeek
        }
        return false
    }

    var isInThisMonth: Bool {
        guard let selfYear = dateComponents.year,
            let todayYear = todayDateComponents.year,
            let selfMonth = dateComponents.month,
            let todayMonth = todayDateComponents.month  else {
                return false
        }
        return selfYear == todayYear && selfMonth == todayMonth
    }
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
