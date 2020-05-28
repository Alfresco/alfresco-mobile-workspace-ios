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

enum FadeAnimationType {
    case fadeIn
    case fadeOut
}

extension CALayer {
    func fadeAnimation(with type: FadeAnimationType, duration: Float, completionHandler: (() -> Void)?) {
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "opacity")

        switch type {
        case .fadeIn:
            animation.fromValue = 0.0
            animation.toValue = 1.0
        case .fadeOut:
            animation.fromValue = 1.0
            animation.toValue = 0.0
        }

        animation.duration = CFTimeInterval(duration)
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        CATransaction.setCompletionBlock {
            if let completionHandler = completionHandler {
                completionHandler()
            }
        }

        self.add(animation, forKey: "fade")
        CATransaction.commit()
    }
}
