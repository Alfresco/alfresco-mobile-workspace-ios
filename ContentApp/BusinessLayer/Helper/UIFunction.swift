//
// Copyright (C) 2005-2022 Alfresco Software Limited.
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

class UIFunction: NSObject {

    class func getKeyboardAnimationOptions(notification: Notification) -> (height: CGFloat?,
                                                                           duration: Double?,
                                                                           curve: UIView.AnimationOptions) {
        
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = (animationCurveRawNSN?.uintValue) ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        let keyboardFrameBegin = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height
        return (height: keyboardFrameBegin, duration: duration, curve: animationCurve)
    }
    
    class func currentTimeInMilliSeconds() -> String {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        let time = Int(since1970 * 1000)
        return String(time)
    }
}
