//
// Copyright (C) 2005-2024 Alfresco Software Limited.
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

struct DateFormatterUtility {
    enum possibleDateFormat: String {
        case yyyMMddTHHmmssSSSZ = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        case yyyyMMddTHHmmssZ = "yyyy-MM-dd'T'HH:mm:ssZ"
        case ddMMMyyyyhhmma = "dd-MMM-yyyy hh:mm a"
        case ddMMyyyy = "dd-MM-yyyy"
        case ddMMMyyyy = "dd-MMM-yyyy"
        case yyyyMMddTHHmmssSSSZ2 = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    }
    static func formattedDateString(from dateString: String, dateTime: Bool) -> String {
        let dateFormatterWithMilliseconds = DateFormatter()
        dateFormatterWithMilliseconds.dateFormat = possibleDateFormat.yyyMMddTHHmmssSSSZ.rawValue
        dateFormatterWithMilliseconds.timeZone = TimeZone(abbreviation: "UTC")
        
        let dateFormatterWithoutMilliseconds = DateFormatter()
        dateFormatterWithoutMilliseconds.dateFormat = possibleDateFormat.yyyyMMddTHHmmssZ.rawValue
        dateFormatterWithoutMilliseconds.timeZone = TimeZone(abbreviation: "UTC")
        
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = dateTime ? possibleDateFormat.ddMMMyyyyhhmma.rawValue : possibleDateFormat.ddMMyyyy.rawValue
        outputDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let dateWithMilliseconds = dateFormatterWithMilliseconds.date(from: dateString) {
            return outputDateFormatter.string(from: dateWithMilliseconds)
        } else if let dateWithoutMilliseconds = dateFormatterWithoutMilliseconds.date(from: dateString) {
            return outputDateFormatter.string(from: dateWithoutMilliseconds)
        } else {
            return ""
        }
    }
    static func dateToString(with format: possibleDateFormat, and dateValue: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: dateValue)
    }
}
