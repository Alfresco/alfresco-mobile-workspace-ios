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

enum SplitTimerFormatType {
    case minutesAndSeconds
}

extension Double {
    func split(by type: SplitTimerFormatType) -> String {
        switch type {
        case .minutesAndSeconds:
            let mins = self / 60
            let secs = self.truncatingRemainder(dividingBy: 60)
            let timeformatter = NumberFormatter()
            timeformatter.minimumIntegerDigits = 2
            timeformatter.minimumFractionDigits = 0
            timeformatter.roundingMode = .down
            guard let minsStr = timeformatter.string(from: NSNumber(value: mins)),
                  let secsStr = timeformatter.string(from: NSNumber(value: secs))
            else { return "00:00" }
            let time = "\(minsStr):\(secsStr)".replacingOccurrences(of: "-", with: "")
            if time.contains("NaN") {
                return "00:00"
            }
            return time
        }
    }

}
